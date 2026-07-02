// =============================================================
//  server.js — Ponto de entrada da API
//  Museu Virtual Interativo — ISPTEC 2026
//  HTTPS com mTLS (Mutual TLS) — PKI própria
// =============================================================

'use strict';

// Carrega as variáveis de ambiente ANTES de qualquer outro import
require('dotenv').config();

const compression = require('compression');
const express     = require('express');
const cors        = require('cors');
const helmet      = require('helmet');
const morgan      = require('morgan');
const path        = require('path');
const fs          = require('fs');
const https       = require('https');
const { Server }  = require('socket.io');

const { connectDB, closeDB } = require('./src/config/db');
const logger = require('./src/middleware/logger');
const { limitadorGeral, limitadorAutenticacao, limitadorUpload } = require('./src/middleware/limitador');

// ── Importar rotas ────────────────────────────────────────────
const authRoutes        = require('./src/routes/autenticacao.rotas');
const utilizadorRoutes  = require('./src/routes/utilizador.rotas');
const exposicaoRoutes   = require('./src/routes/exposicao.rotas');
const pecaRoutes        = require('./src/routes/peca.rotas');
const mediaRoutes       = require('./src/routes/media.rotas');
const fluxoRoutes       = require('./src/routes/fluxo.rotas');
const relatorioRoutes   = require('./src/routes/relatorio.rotas');
const computadorRoutes  = require('./src/routes/computador.rotas');
const conteudoRoutes   = require('./src/routes/conteudo.rotas');
const streamingRoutes  = require('./src/routes/streaming.rotas');
const uploadRoutes     = require('./src/routes/uploads');
const streamVodRoutes  = require('./src/routes/stream_vod.rotas');
const streamingAoVivoRoutes  = require('./src/routes/streaming_ao_vivo.rotas');
const downloadRoutes  = require('./src/routes/download.rotas');

const app  = express();
const PORT = process.env.PORT || 3000;

// =============================================================
//  LISTA BRANCA DE MÁQUINAS SEM CERTIFICADO
//  (para o professor adicionar máquinas durante o exame)
// =============================================================
const maquinasSemCertificadoPermitidas = new Set();

// =============================================================
//  REGISTO DE LOGS DE SEGURANÇA (NÃO-REPÚDIO)
// =============================================================
function registarLog(tipo, mensagem, dados = {}) {
  const entrada = {
    timestamp: new Date().toISOString(),
    tipo,
    mensagem,
    ...dados
  };

  try {
    const logPath = path.join(__dirname, 'logs', 'seguranca.log');
    const dir = path.dirname(logPath);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.appendFileSync(logPath, JSON.stringify(entrada) + '\n');
  } catch (e) {
    logger.error('Erro ao escrever log de segurança:', e.message);
  }
}

// =============================================================
//  MIDDLEWARE DE VERIFICAÇÃO DE CERTIFICADO
// =============================================================
function verificarCertificado(req, res, next) {
  const clienteIp = req.ip || req.connection?.remoteAddress;
  const tipoCliente = req.headers['x-client-type'];

  // Verifica se a máquina está na lista branca (sem certificado)
  if (maquinasSemCertificadoPermitidas.has(clienteIp)) {
    logger.warn(`Acesso sem certificado permitido por excepção: ${clienteIp}`);
    registarLog('AVISO', `Acesso sem certificado permitido: ${clienteIp}`);
    req.certificado = null;
    req.acessoSemCertificado = true;
    return next();
  }

  // Verifica se é um cliente Web (browser)
  // Browsers não conseguem enviar certificados de cliente via código.
  // O acesso é permitido mas registado para não-repúdio.
  if (tipoCliente === 'web') {
    logger.info(`Acesso Web (browser) permitido: ${clienteIp}`);
    registarLog('WEB', `Acesso via browser sem certificado de cliente: ${clienteIp}`, {
      userAgent: req.headers['user-agent'],
    });
    req.certificado = null;
    req.acessoSemCertificado = true;
    req.acessoWeb = true;
    return next();
  }

  // Verifica se o cliente apresentou certificado
  const cert = req.socket.getPeerCertificate();

  if (!cert || Object.keys(cert).length === 0) {
    registarLog('BLOQUEADO', `Tentativa de acesso sem certificado: ${clienteIp}`);
    return res.status(401).json({
      erro: 'Acesso negado',
      motivo: 'Certificado digital obrigatório',
      solucao: 'Contacte o administrador para obter um certificado válido'
    });
  }

  // Verifica se o certificado foi autorizado pela CA
  if (!req.socket.authorized) {
    registarLog('BLOQUEADO', `Certificado inválido de: ${clienteIp} | CN: ${cert.subject?.CN}`);
    return res.status(403).json({
      erro: 'Certificado inválido',
      motivo: 'O certificado não foi emitido por uma CA reconhecida',
      certificado: cert.subject?.CN || 'desconhecido'
    });
  }

  // Certificado válido
  const cnCert = cert.subject?.CN || 'desconhecido';
  registarLog('PERMITIDO', `Acesso com certificado: ${cnCert} | IP: ${clienteIp}`);

  req.certificado = {
    cn: cnCert,
    email: cert.subject?.emailAddress,
    emissor: cert.issuer?.CN,
    validade: cert.valid_to,
    impressaoDigital: cert.fingerprint,
  };

  next();
}

function verificarCertificadoAdmin(req, res, next) {
  verificarCertificado(req, res, () => {
    if (!req.certificado || req.certificado.cn !== 'admin') {
      return res.status(403).json({
        erro: 'Acesso negado',
        motivo: 'Esta operação requer certificado de administrador'
      });
    }
    next();
  });
}

// =============================================================
//  SEGURANÇA — Helmet define headers HTTP de segurança
// =============================================================
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  })
);

// =============================================================
//  CORS
// =============================================================
app.use(
  cors({
    origin      : process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : true,
    methods     : ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Client-Type'],
    credentials : true,
  })
);

// =============================================================
//  LOGGING DE REQUESTS (morgan)
// =============================================================
const morganFormat = process.env.NODE_ENV === 'production' ? 'combined' : 'dev';
app.use(morgan(morganFormat));

// =============================================================
//  COMPRESSÃO GZIP
// =============================================================
app.use(compression({
  level    : 6,
  threshold: 1024,
  filter   : (req, res) => {
    if (req.headers['x-no-compression']) return false;
    return compression.filter(req, res);
  },
}));

// =============================================================
//  PARSERS
// =============================================================
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// =============================================================
//  FICHEIROS ESTÁTICOS — servir uploads directamente
//  (ANTES do middleware mTLS para que Image.network funcione)
// =============================================================
const uploadDir = path.join(__dirname, process.env.UPLOAD_DIR || 'uploads');

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
  logger.info(`Pasta de uploads criada: ${uploadDir}`);
}

app.use('/uploads', express.static(uploadDir, { maxAge: '1d', etag: true }));

const subPastas = ['imagens', 'imagens_comp', 'audios', 'audios_comp', 'videos', 'videos_comp'];
subPastas.forEach((sub) => {
  const caminho = path.join(uploadDir, sub);
  if (!fs.existsSync(caminho)) fs.mkdirSync(caminho, { recursive: true });
  app.use(`/uploads/${sub}`, express.static(caminho, { maxAge: '1d', etag: true }));
});

// =============================================================
//  VERIFICAÇÃO DE CERTIFICADO — aplicada a todas as rotas da API
// =============================================================
app.use(verificarCertificado);

// =============================================================
//  ROTA DE SAÚDE (Health Check)
// =============================================================
app.get('/health', (req, res) => {
  res.json({
    status   : 'ok',
    app      : 'Museu Virtual Interativo',
    version  : '1.0.0',
    timestamp: new Date().toISOString(),
    env      : process.env.NODE_ENV,
    certificado: req.certificado,
    acesso: req.acessoSemCertificado ? 'sem certificado (excepção)' : 'com certificado válido',
  });
});

// =============================================================
//  ROTA RAIZ — Informação do servidor
// =============================================================
app.get('/', (req, res) => {
  res.json({
    servidor: 'Museu Virtual - Servidor Online',
    versao: '1.0.0',
    certificado: req.certificado,
    acesso: req.acessoSemCertificado ? 'sem certificado (excepção)' : 'com certificado válido',
    timestamp: new Date().toISOString(),
  });
});

// =============================================================
//  ROTAS ADMINISTRATIVAS (apenas com certificado admin)
// =============================================================

// Adicionar máquina sem certificado à lista branca
app.post('/admin/permitir-sem-certificado',
  verificarCertificadoAdmin,
  (req, res) => {
    const { ip } = req.body;
    if (!ip) return res.status(400).json({ erro: 'IP é obrigatório' });
    maquinasSemCertificadoPermitidas.add(ip);
    logger.warn(`Máquina sem certificado permitida: ${ip}`);
    registarLog('AVISO', `Máquina sem certificado permitida: ${ip}`);
    res.json({ sucesso: true, mensagem: `Máquina ${ip} pode ligar sem certificado` });
  }
);

// Remover máquina da lista branca
app.post('/admin/revogar-sem-certificado',
  verificarCertificadoAdmin,
  (req, res) => {
    const { ip } = req.body;
    maquinasSemCertificadoPermitidas.delete(ip);
    registarLog('AVISO', `Permissão removida para máquina: ${ip}`);
    res.json({ sucesso: true, mensagem: `Permissão removida para ${ip}` });
  }
);

// Listar máquinas na lista branca
app.get('/admin/maquinas-sem-certificado',
  verificarCertificadoAdmin,
  (req, res) => {
    res.json({
      maquinas: Array.from(maquinasSemCertificadoPermitidas),
      total: maquinasSemCertificadoPermitidas.size
    });
  }
);

// Listar logs de segurança (não-repúdio)
app.get('/admin/logs-seguranca',
  verificarCertificadoAdmin,
  (req, res) => {
    try {
      const logPath = path.join(__dirname, 'logs', 'seguranca.log');
      if (!fs.existsSync(logPath)) {
        return res.json({ total: 0, logs: [] });
      }
      const logs = fs.readFileSync(logPath, 'utf8')
        .split('\n')
        .filter(l => l.trim())
        .map(l => JSON.parse(l))
        .reverse();
      res.json({ total: logs.length, logs });
    } catch (erro) {
      res.status(500).json({ erro: erro.message });
    }
  }
);

// =============================================================
//  ROTAS DA API
// =============================================================
const API = '/api/v1';

app.use(`${API}`, limitadorGeral);

app.use(`${API}/autenticacao`, limitadorAutenticacao, authRoutes);
app.use(`${API}/utilizadores`, utilizadorRoutes);
app.use(`${API}/exposicoes`,   exposicaoRoutes);
app.use(`${API}/pecas`,        pecaRoutes);
app.use(`${API}/media`,        mediaRoutes);
app.use(`${API}/fluxo`,        fluxoRoutes);
app.use(`${API}/relatorios`,   relatorioRoutes);
app.use(`${API}/computadores`, computadorRoutes);
app.use(`${API}/conteudos`,    conteudoRoutes);
app.use(`${API}/streaming`,    streamingRoutes);
app.use(`${API}/uploads`,      uploadRoutes);
app.use(`${API}/stream`,      streamVodRoutes);
app.use(`${API}/streaming-ao-vivo`, streamingAoVivoRoutes);
app.use(`${API}/download`,    downloadRoutes);

// =============================================================
//  ROTA NÃO ENCONTRADA (404)
// =============================================================
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Rota não encontrada: ${req.method} ${req.originalUrl}`,
  });
});

// =============================================================
//  HANDLER GLOBAL DE ERROS (500)
// =============================================================
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  logger.error('Erro não tratado:', err);

  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({
      success: false,
      message: `Ficheiro demasiado grande. Máximo: ${process.env.MAX_FILE_SIZE_MB || 200} MB`,
    });
  }

  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({
      success: false,
      message: 'JSON inválido no corpo do pedido.',
    });
  }

  const statusCode = err.statusCode || err.status || 500;
  res.status(statusCode).json({
    success: false,
    message: err.message || 'Erro interno do servidor.',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
});

// =============================================================
//  INICIAR SERVIDOR HTTPS com mTLS + SOCKET.IO
// =============================================================
async function bootstrap() {
  // 1. Conectar à base de dados
  await connectDB();

  // 2. Configurar TLS
  const certsDir = path.join(__dirname, 'certs');
  const caPath = path.join(certsDir, 'ca', 'ca.crt');
  const serverKeyPath = path.join(certsDir, 'server', 'server.key');
  const serverCertPath = path.join(certsDir, 'server', 'server.crt');

  const opcoesTLS = {
    key: fs.readFileSync(serverKeyPath),
    cert: fs.readFileSync(serverCertPath),
    ca: fs.readFileSync(caPath),
    requestCert: true,
    rejectUnauthorized: false,
  };

  // 3. Criar servidor HTTPS com mTLS
  const server = https.createServer(opcoesTLS, app);

  // 4. Integrar Socket.IO no servidor HTTPS
  const io = new Server(server, {
    cors: {
      origin: process.env.CORS_ORIGIN || '*',
      methods: ['GET', 'POST'],
    },
  });

  app.set('io', io);

  const { configurarStreamingSocket } = require('./src/socket/streaming.socket');
  configurarStreamingSocket(io);

  // 5. Iniciar servidor HTTPS (mTLS) — para clientes nativos
  server.listen(PORT, () => {
    console.log('');
    console.log('============================================');
    console.log('  MUSEU VIRTUAL — SERVIDOR HTTPS com mTLS');
    console.log('============================================');
    console.log(`  URL: https://localhost:${PORT}`);
    console.log(`  Ambiente: ${process.env.NODE_ENV || 'development'}`);
    console.log(`  Base da API: https://localhost:${PORT}${API}`);
    console.log(`  Socket.IO: wss://localhost:${PORT}`);
    console.log(`  Protocolo: HTTPS com mTLS (PKI própria)`);
    console.log(`  Não-repúdio: ACTIVO`);
    console.log(`  Health: https://localhost:${PORT}/health`);
    console.log('============================================');
    console.log('');
    logger.info(`Servidor HTTPS com mTLS iniciado na porta ${PORT}`);
  });

  // 6. Servidor HTTP para desenvolvimento Web (browsers não suportam mTLS)
  const HTTP_PORT = process.env.HTTP_PORT || 3001;
  if (process.env.NODE_ENV !== 'production') {
    const http = require('http');
    const httpServer = http.createServer(app);

    // Socket.IO também no servidor HTTP para a web
    const ioHttp = new Server(httpServer, {
      cors: {
        origin: process.env.CORS_ORIGIN || '*',
        methods: ['GET', 'POST'],
      },
    });
    configurarStreamingSocket(ioHttp);
    app.set('io', ioHttp);

    httpServer.listen(HTTP_PORT, () => {
      console.log('============================================');
      console.log('  SERVIDOR HTTP (desenvolvimento Web)');
      console.log('============================================');
      console.log(`  URL: http://localhost:${HTTP_PORT}`);
      console.log(`  Base da API: http://localhost:${HTTP_PORT}${API}`);
      console.log(`  Socket.IO: ws://localhost:${HTTP_PORT}`);
      console.log(`  ⚠️  Apenas para desenvolvimento!`);
      console.log('============================================');
      console.log('');
      logger.info(`Servidor HTTP (dev/web) iniciado na porta ${HTTP_PORT}`);
    });
  }
}

bootstrap().catch((err) => {
  console.error('Falha ao iniciar o servidor:', err);
  process.exit(1);
});

// =============================================================
//  ENCERRAMENTO GRACIOSO
// =============================================================
process.on('SIGINT',  gracefulShutdown);
process.on('SIGTERM', gracefulShutdown);

async function gracefulShutdown(signal) {
  console.log(`\nSinal ${signal} recebido. A encerrar...`);
  await closeDB();
  process.exit(0);
}

module.exports = app;
