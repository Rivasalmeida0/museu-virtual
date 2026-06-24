// =============================================================
//  server.js — Ponto de entrada da API
//  Museu Virtual Interativo — ISPTEC 2026
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

const { connectDB } = require('./src/config/db');
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
const http   = require('http');
const { Server } = require('socket.io');

const app  = express();
const PORT = process.env.PORT || 3000;

// =============================================================
//  SEGURANÇA — Helmet define headers HTTP de segurança
// =============================================================
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' }, // permite servir media
  })
);

// =============================================================
//  CORS
// =============================================================
app.use(
  cors({
    origin      : process.env.CORS_ORIGIN || '*',
    methods     : ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials : true,
  })
);

// =============================================================
//  LOGGING DE REQUESTS (morgan)
// =============================================================
// Em produção: formato compacto; em desenvolvimento: colorido
const morganFormat = process.env.NODE_ENV === 'production' ? 'combined' : 'dev';
app.use(morgan(morganFormat));

// =============================================================
//  COMPRESSÃO GZIP — todas as respostas > 1KB
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
// =============================================================
const uploadDir = path.join(__dirname, process.env.UPLOAD_DIR || 'uploads');

// Cria a pasta de uploads se não existir
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
  logger.info(`Pasta de uploads criada: ${uploadDir}`);
}

// Servir todos os uploads (originais e comprimidos)
app.use('/uploads', express.static(uploadDir, { maxAge: '1d', etag: true }));

// Servir cada subpasta individualmente para garantir acesso directo
const subPastas = ['imagens', 'imagens_comp', 'audios', 'audios_comp', 'videos', 'videos_comp'];
subPastas.forEach((sub) => {
  const caminho = path.join(uploadDir, sub);
  if (!fs.existsSync(caminho)) fs.mkdirSync(caminho, { recursive: true });
  app.use(`/uploads/${sub}`, express.static(caminho, { maxAge: '1d', etag: true }));
});

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
  });
});

// =============================================================
//  ROTAS DA API
// =============================================================
const API = '/api/v1';

app.use(`${API}`, limitadorGeral);

app.use(`${API}/autenticacao`, limitadorAutenticacao, authRoutes);       // /api/v1/autenticacao
app.use(`${API}/utilizadores`, utilizadorRoutes);  // /api/v1/utilizadores
app.use(`${API}/exposicoes`,   exposicaoRoutes);   // /api/v1/exposicoes
app.use(`${API}/pecas`,        pecaRoutes);        // /api/v1/pecas
app.use(`${API}/media`,        mediaRoutes);       // /api/v1/media
app.use(`${API}/fluxo`,        fluxoRoutes);       // /api/v1/fluxo
app.use(`${API}/relatorios`,   relatorioRoutes);   // /api/v1/relatorios
app.use(`${API}/computadores`, computadorRoutes);  // /api/v1/computadores
app.use(`${API}/conteudos`,    conteudoRoutes);    // /api/v1/conteudos
app.use(`${API}/streaming`,    streamingRoutes);   // /api/v1/streaming
app.use(`${API}/uploads`,      uploadRoutes);      // /api/v1/uploads
app.use(`${API}/stream`,      streamVodRoutes);    // /api/v1/stream/video/:filename
app.use(`${API}/streaming-ao-vivo`, streamingAoVivoRoutes); // /api/v1/streaming-ao-vivo
app.use(`${API}/download`,    downloadRoutes);     // /api/v1/download/video/:filename

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

  // Erros de validação do Multer (upload)
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({
      success: false,
      message: `Ficheiro demasiado grande. Máximo: ${process.env.MAX_FILE_SIZE_MB || 200} MB`,
    });
  }

  // Erros de sintaxe no JSON do body
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
//  INICIAR SERVIDOR (HTTP + SOCKET.IO)
// =============================================================
async function bootstrap() {
  // 1. Conectar à base de dados
  await connectDB();

  // 2. Criar servidor HTTP e integrar Socket.IO
  const server = http.createServer(app);
  const io = new Server(server, {
    cors: {
      origin: process.env.CORS_ORIGIN || '*',
      methods: ['GET', 'POST'],
    },
  });

  // Disponibilizar io para os controladores via app
  app.set('io', io);

  const { configurarStreamingSocket } = require('./src/socket/streaming.socket');
  configurarStreamingSocket(io);

  // 3. Iniciar servidor
  server.listen(PORT, () => {
    console.log('');
    console.log('🏛️   Museu Virtual Interativo — API');
    logger.info(`Servidor a correr em http://localhost:${PORT}`);
    console.log(`🌍   Ambiente: ${process.env.NODE_ENV || 'development'}`);
    console.log(`📡   Base da API: http://localhost:${PORT}${API}`);
    console.log(`🔌   Socket.IO streaming: ws://localhost:${PORT}`);
    console.log(`❤️   Health check: http://localhost:${PORT}/health`);
    console.log('');
  });
}

// Capturar erros de inicialização
bootstrap().catch((err) => {
  console.error('❌  Falha ao iniciar o servidor:', err);
  process.exit(1);
});

// =============================================================
//  ENCERRAMENTO GRACIOSO
// =============================================================
const { closeDB } = require('./src/config/db');

process.on('SIGINT',  gracefulShutdown);
process.on('SIGTERM', gracefulShutdown);

async function gracefulShutdown(signal) {
  console.log(`\n🛑  Sinal ${signal} recebido. A encerrar...`);
  await closeDB();
  process.exit(0);
}

module.exports = app; // exportar para testes (Jest/Supertest)
