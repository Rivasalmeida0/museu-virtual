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
  comprimirVideoHevc,
  comprimirVideoVp9,
  comprimirAudioOgg,
} = require('../middleware/compressao.middleware');

const {
  processarTudo,
} = require('../middleware/compressao.completa.middleware');

const ConteudoRepositorio = require('../repository/conteudo.repositorio');
const { gerarThumbnail } = require('../service/thumbnail.servico');

// ── Configuração do multer ──────────────────────────────────
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const tipo = file.mimetype.startsWith('image/') ? path.join('uploads', 'imagens') :
                 file.mimetype.startsWith('audio/') ? path.join('uploads', 'audios') :
                 path.join('uploads', 'videos');
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

      const imagemUrl = `/uploads/imagens_comp/${relatorio.ficheiro_final}`;

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

      const audioUrl = `/uploads/audios_comp/${relatorio.ficheiro_final}`;

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

      const videoUrl = `/uploads/videos_comp/${relatorio.ficheiro_final}`;

      const relatorioJson = JSON.stringify(relatorio);
      await ConteudoRepositorio.actualizarVideoComRelatorio(
        req.params.conteudo_id, videoUrl, relatorioJson
      );

      // Gerar Thumbnail
      try {
        const videoPathAbs = path.join(__dirname, '../..', relatorio.caminho_final);
        const thumbnailName = `thumb_${nomeBase}.jpg`;
        const thumbnailUrl = await gerarThumbnail(videoPathAbs, thumbnailName);
        await ConteudoRepositorio.actualizarImagem(req.params.conteudo_id, thumbnailUrl);
      } catch (errThumb) {
        console.error('Erro ao gerar thumbnail automático:', errThumb);
      }

      const actualizado = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);

      const io = req.app.get('io');
      if (io) io.emit('conteudo_atualizado', actualizado);

      res.json({
        sucesso: true,
        mensagem: 'Vídeo enviado, comprimido e thumbnail gerado.',
        dados: actualizado,
        relatorio_compressao: relatorio,
      });
    } catch (erro) { next(erro); }
  }
);

// ─── POST /uploads/video/hevc/:conteudo_id ──────────────────────
roteador.post('/video/hevc/:conteudo_id',
  upload.single('ficheiro'),
  async (req, res, next) => {
    try {
      if (!req.file) return res.status(400).json({ sucesso: false, mensagem: 'Nenhum ficheiro enviado.' });

      const conteudo = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);
      if (!conteudo) return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });

      const nomeBase = path.basename(req.file.filename, path.extname(req.file.filename));
      const relatorio = await comprimirVideoHevc(req.file.path, nomeBase);

      const videoUrl = `/uploads/videos_comp/${relatorio.ficheiro_final}`;

      await ConteudoRepositorio.actualizarVideoComRelatorio(
        req.params.conteudo_id, videoUrl, JSON.stringify(relatorio)
      );

      // Gerar Thumbnail
      try {
        const videoPathAbs = path.join(__dirname, '../..', relatorio.caminho_final);
        const thumbnailName = `thumb_${nomeBase}.jpg`;
        const thumbnailUrl = await gerarThumbnail(videoPathAbs, thumbnailName);
        await ConteudoRepositorio.actualizarImagem(req.params.conteudo_id, thumbnailUrl);
      } catch (errThumb) {
        console.error('Erro ao gerar thumbnail automático (HEVC):', errThumb);
      }

      const actualizado = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);

      const io = req.app.get('io');
      if (io) io.emit('conteudo_atualizado', actualizado);

      res.json({
        sucesso: true,
        mensagem: 'Vídeo enviado, comprimido (H.265/HEVC) e thumbnail gerado.',
        dados: actualizado,
        relatorio_compressao: relatorio,
      });
    } catch (erro) { next(erro); }
  }
);

// ─── POST /uploads/video/vp9/:conteudo_id ──────────────────────
roteador.post('/video/vp9/:conteudo_id',
  upload.single('ficheiro'),
  async (req, res, next) => {
    try {
      if (!req.file) return res.status(400).json({ sucesso: false, mensagem: 'Nenhum ficheiro enviado.' });

      const conteudo = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);
      if (!conteudo) return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });

      const nomeBase = path.basename(req.file.filename, path.extname(req.file.filename));
      const relatorio = await comprimirVideoVp9(req.file.path, nomeBase);

      const videoUrl = `/uploads/videos_comp/${relatorio.ficheiro_final}`;

      await ConteudoRepositorio.actualizarVideoComRelatorio(
        req.params.conteudo_id, videoUrl, JSON.stringify(relatorio)
      );

      // Gerar Thumbnail
      try {
        const videoPathAbs = path.join(__dirname, '../..', relatorio.caminho_final);
        const thumbnailName = `thumb_${nomeBase}.jpg`;
        const thumbnailUrl = await gerarThumbnail(videoPathAbs, thumbnailName);
        await ConteudoRepositorio.actualizarImagem(req.params.conteudo_id, thumbnailUrl);
      } catch (errThumb) {
        console.error('Erro ao gerar thumbnail automático (VP9):', errThumb);
      }

      const actualizado = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);

      const io = req.app.get('io');
      if (io) io.emit('conteudo_atualizado', actualizado);

      res.json({
        sucesso: true,
        mensagem: 'Vídeo enviado, comprimido (VP9/WebM) e thumbnail gerado.',
        dados: actualizado,
        relatorio_compressao: relatorio,
      });
    } catch (erro) { next(erro); }
  }
);

// ─── POST /uploads/audio/ogg/:conteudo_id ──────────────────────
roteador.post('/audio/ogg/:conteudo_id',
  upload.single('ficheiro'),
  async (req, res, next) => {
    try {
      if (!req.file) return res.status(400).json({ sucesso: false, mensagem: 'Nenhum ficheiro enviado.' });

      const conteudo = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);
      if (!conteudo) return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });

      const nomeBase = path.basename(req.file.filename, path.extname(req.file.filename));
      const relatorio = await comprimirAudioOgg(req.file.path, nomeBase);

      const audioUrl = `/uploads/audios_comp/${relatorio.ficheiro_final}`;

      await ConteudoRepositorio.actualizarAudioComRelatorio(
        req.params.conteudo_id, audioUrl, JSON.stringify(relatorio)
      );

      const actualizado = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);

      const io = req.app.get('io');
      if (io) io.emit('conteudo_atualizado', actualizado);

      res.json({
        sucesso: true,
        mensagem: 'Áudio enviado e comprimido (OGG Vorbis).',
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



// ─── POST /uploads/processar/:conteudo_id ───────────────────
// Processamento multimédia unificado — todos os codecs
roteador.post('/processar/:conteudo_id',
  upload.fields([
    { name: 'imagem', maxCount: 1 },
    { name: 'audio',  maxCount: 1 },
    { name: 'video',  maxCount: 1 },
  ]),
  async (req, res, next) => {
    try {
      const conteudo = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);
      if (!conteudo) {
        return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });
      }

      const ficheiros = {};

      if (req.files && req.files['imagem'] && req.files['imagem'][0]) {
        const f = req.files['imagem'][0];
        ficheiros.imagem = {
          path: f.path,
          nomeBase: path.basename(f.filename, path.extname(f.filename)),
        };
      }
      if (req.files && req.files['audio'] && req.files['audio'][0]) {
        const f = req.files['audio'][0];
        ficheiros.audio = {
          path: f.path,
          nomeBase: path.basename(f.filename, path.extname(f.filename)),
        };
      }
      if (req.files && req.files['video'] && req.files['video'][0]) {
        const f = req.files['video'][0];
        ficheiros.video = {
          path: f.path,
          nomeBase: path.basename(f.filename, path.extname(f.filename)),
        };
      }

      if (Object.keys(ficheiros).length === 0) {
        return res.status(400).json({ sucesso: false, mensagem: 'Nenhum ficheiro enviado.' });
      }

      const resultado = await processarTudo(ficheiros);

      res.json({
        sucesso: true,
        mensagem: 'Processamento multimédia concluído.',
        conteudo_id: parseInt(req.params.conteudo_id),
        resultado,
      });
    } catch (erro) { next(erro); }
  }
);

// ─── POST /uploads/publicar/:conteudo_id ────────────────────
// Publica as versões selecionadas pelo administrador
roteador.post('/publicar/:conteudo_id',
  async (req, res, next) => {
    try {
      const conteudo = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);
      if (!conteudo) {
        return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });
      }

      const baseUrl = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
      const { imagem_ficheiro, audio_ficheiro, video_ficheiro, relatorio } = req.body;

      if (imagem_ficheiro) {
        const imagemUrl = `/uploads/imagens_comp/${imagem_ficheiro}`;
        await ConteudoRepositorio.actualizarImagemComRelatorio(
          req.params.conteudo_id, imagemUrl, JSON.stringify(relatorio || {})
        );
      }
      if (audio_ficheiro) {
        const audioUrl = `/uploads/audios_comp/${audio_ficheiro}`;
        await ConteudoRepositorio.actualizarAudioComRelatorio(
          req.params.conteudo_id, audioUrl, JSON.stringify(relatorio || {})
        );
      }
      if (video_ficheiro) {
        const videoUrl = `/uploads/videos_comp/${video_ficheiro}`;
        await ConteudoRepositorio.actualizarVideoComRelatorio(
          req.params.conteudo_id, videoUrl, JSON.stringify(relatorio || {})
        );
      }

      const actualizado = await ConteudoRepositorio.buscarPorId(req.params.conteudo_id);

      const io = req.app.get('io');
      if (io) io.emit('conteudo_atualizado', actualizado);

      res.json({
        sucesso: true,
        mensagem: 'Conteúdo publicado com as versões selecionadas.',
        dados: actualizado,
      });
    } catch (erro) { next(erro); }
  }
);

module.exports = roteador;
