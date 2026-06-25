// =============================================================
//  src/routes/uploads.js
//  Rotas de upload com compressão automática + relatório
//  POST /uploads/imagem/:conteudo_id
//  POST /uploads/audio/:conteudo_id
//  POST /uploads/video/:conteudo_id
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const express = require('express');
const roteador = express.Router();
const multer  = require('multer');
const path    = require('path');
const fs      = require('fs');

const {
  comprimirImagem,
  comprimirAudio,
  comprimirVideo,
} = require('../middleware/compressao.middleware');

const ConteudoRepositorio = require('../repository/conteudo.repositorio');

// ── Configuração do multer ──────────────────────────────────
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const tipo = file.mimetype.startsWith('image/') ? 'uploads\\imagens' :
                 file.mimetype.startsWith('audio/') ? 'uploads\\audios' :
                 'uploads\\videos';
    const pasta = path.join(__dirname, '../..', tipo);
    if (!fs.existsSync(pasta)) fs.mkdirSync(pasta, { recursive: true });
    cb(null, pasta);
  },
  filename: (req, file, cb) => {
    const nomeBase = `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    cb(null, nomeBase + path.extname(file.originalname));
  },
});

const filtroFicheiros = (req, file, cb) => {
  const tiposPermitidos = [
    'image/jpeg', 'image/png', 'image/webp',
    'audio/mpeg', 'audio/mp3', 'audio/ogg', 'audio/aac', 'audio/wav',
    'video/mp4', 'video/webm', 'video/ogg', 'video/quicktime',
    'application/octet-stream',
  ];
  if (tiposPermitidos.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error(`Tipo de ficheiro não permitido: ${file.mimetype}`));
  }
};

const upload = multer({
  storage,
  fileFilter: filtroFicheiros,
  limits: { fileSize: 500 * 1024 * 1024 },
});

// ─── POST /uploads/imagem/:conteudo_id ──────────────────────
roteador.post('/imagem/:conteudo_id',
  upload.single('ficheiro'),
  async (req, res, next) => {
    try {
      if (!req.file) {
        return res.status(400).json({ sucesso: false, mensagem: 'Nenhum ficheiro enviado.' });
      }

      const conteudo = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);
      if (!conteudo) {
        return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });
      }

      const nomeBase = path.basename(req.file.filename, path.extname(req.file.filename));
      const relatorio = await comprimirImagem(req.file.path, nomeBase);

      const baseUrl = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
      const imagemUrl = `${baseUrl}/uploads/imagens_comp/${relatorio.ficheiro_final}`;

      const relatorioJson = JSON.stringify(relatorio);
      await ConteudoRepositorio.actualizarImagemComRelatorio(
        req.params.conteudo_id, imagemUrl, relatorioJson
      );

      const actualizado = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);

      const io = req.app.get('io');
      if (io) io.emit('conteudo_atualizado', actualizado);

      res.json({
        sucesso: true,
        mensagem: 'Imagem enviada e comprimida.',
        dados: actualizado,
        relatorio_compressao: relatorio,
      });
    } catch (erro) { next(erro); }
  }
);

// ─── POST /uploads/audio/:conteudo_id ───────────────────────
roteador.post('/audio/:conteudo_id',
  upload.single('ficheiro'),
  async (req, res, next) => {
    try {
      if (!req.file) {
        return res.status(400).json({ sucesso: false, mensagem: 'Nenhum ficheiro enviado.' });
      }

      const conteudo = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);
      if (!conteudo) {
        return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });
      }

      const nomeBase = path.basename(req.file.filename, path.extname(req.file.filename));
      const relatorio = await comprimirAudio(req.file.path, nomeBase);

      const baseUrl = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
      const audioUrl = `${baseUrl}/uploads/audios_comp/${relatorio.ficheiro_final}`;

      const relatorioJson = JSON.stringify(relatorio);
      await ConteudoRepositorio.actualizarAudioComRelatorio(
        req.params.conteudo_id, audioUrl, relatorioJson
      );

      const actualizado = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);

      const io = req.app.get('io');
      if (io) io.emit('conteudo_atualizado', actualizado);

      res.json({
        sucesso: true,
        mensagem: 'Áudio enviado e comprimido.',
        dados: actualizado,
        relatorio_compressao: relatorio,
      });
    } catch (erro) { next(erro); }
  }
);

// ─── POST /uploads/video/:conteudo_id ───────────────────────
roteador.post('/video/:conteudo_id',
  upload.single('ficheiro'),
  async (req, res, next) => {
    try {
      if (!req.file) {
        return res.status(400).json({ sucesso: false, mensagem: 'Nenhum ficheiro enviado.' });
      }

      const conteudo = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);
      if (!conteudo) {
        return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });
      }

      const nomeBase = path.basename(req.file.filename, path.extname(req.file.filename));
      const relatorio = await comprimirVideo(req.file.path, nomeBase);

      const baseUrl = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
      const videoUrl = `${baseUrl}/uploads/videos_comp/${relatorio.ficheiro_final}`;

      const relatorioJson = JSON.stringify(relatorio);
      await ConteudoRepositorio.actualizarVideoComRelatorio(
        req.params.conteudo_id, videoUrl, relatorioJson
      );

      const actualizado = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);

      const io = req.app.get('io');
      if (io) io.emit('conteudo_atualizado', actualizado);

      res.json({
        sucesso: true,
        mensagem: 'Vídeo enviado e comprimido.',
        dados: actualizado,
        relatorio_compressao: relatorio,
      });
    } catch (erro) { next(erro); }
  }
);

// ─── GET /uploads/relatorio ─────────────────────────────────────
// Retorna o histórico de todas as compressões (para demonstrar ao professor)
roteador.get('/relatorio',
  (req, res, next) => {
    try {
      const logPath = path.join(__dirname, '..', '..', 'logs', 'compressao.log');

      if (!fs.existsSync(logPath)) {
        return res.json({ sucesso: true, total: 0, compressoes: [] });
      }

      const linhas = fs.readFileSync(logPath, 'utf8')
        .split('\n')
        .filter(l => l.trim())
        .map(l => JSON.parse(l));

      res.json({
        sucesso: true,
        total: linhas.length,
        compressoes: linhas.reverse(),
      });
    } catch (erro) { next(erro); }
  }
);

module.exports = roteador;
