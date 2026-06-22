// =============================================================
//  src/service/compressao.servico.js
//  Compressão de imagens (sharp) e áudio/vídeo (ffmpeg)
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const sharp  = require('sharp');
const ffmpeg = require('fluent-ffmpeg');
const path   = require('path');
const fs     = require('fs');

/**
 * Comprimir automaticamente um ficheiro após upload.
 * Detecta o tipo e chama o compressor adequado.
 *
 * @param {Object} ficheiro - Objeto do Multer (req.file)
 * @returns {Promise<Object>} - Métricas de compressão
 */
async function comprimirFicheiro(ficheiro) {
  const { mimetype, path: caminhoOriginal, size: tamanhoOriginal } = ficheiro;

  const iniciado = Date.now();

  if (mimetype.startsWith('image/')) {
    return _comprimirImagem(caminhoOriginal, tamanhoOriginal, mimetype, iniciado);
  }

  if (mimetype.startsWith('audio/')) {
    return _comprimirAudio(caminhoOriginal, tamanhoOriginal, iniciado);
  }

  if (mimetype.startsWith('video/')) {
    return _comprimirVideo(caminhoOriginal, tamanhoOriginal, iniciado);
  }

  // Tipo desconhecido — devolve sem compressão
  return {
    caminhoComprimido : caminhoOriginal,
    tamanhoComprimido : tamanhoOriginal,
    codec             : 'nenhum',
    duracaoMs         : 0,
    pontuacaoQualidade: null,
  };
}

// ── Imagens ───────────────────────────────────────────────────
async function _comprimirImagem(caminhoOriginal, tamanhoOriginal, tipoMime, iniciado) {
  const qualidade      = Number(process.env.IMAGE_QUALITY) || 75;
  const extensaoSaida  = '.webp';
  const caminhoSaida   = caminhoOriginal.replace(path.extname(caminhoOriginal), `_comprimido${extensaoSaida}`);

  await sharp(caminhoOriginal)
    .webp({ quality: qualidade })
    .toFile(caminhoSaida);

  const tamanhoComprimido = fs.statSync(caminhoSaida).size;

  return {
    caminhoComprimido : caminhoSaida,
    tamanhoComprimido,
    codec             : 'WebP',
    duracaoMs         : Date.now() - iniciado,
    pontuacaoQualidade: qualidade,
  };
}

// ── Áudio ─────────────────────────────────────────────────────
async function _comprimirAudio(caminhoOriginal, tamanhoOriginal, iniciado) {
  const bitrate     = process.env.AUDIO_BITRATE || '128k';
  const caminhoSaida = caminhoOriginal.replace(path.extname(caminhoOriginal), '_comprimido.aac');

  await new Promise((resolver, rejeitar) => {
    ffmpeg(caminhoOriginal)
      .audioCodec('aac')
      .audioBitrate(bitrate)
      .output(caminhoSaida)
      .on('end',   resolver)
      .on('error', rejeitar)
      .run();
  });

  const tamanhoComprimido = fs.statSync(caminhoSaida).size;

  return {
    caminhoComprimido : caminhoSaida,
    tamanhoComprimido,
    codec             : 'AAC',
    duracaoMs         : Date.now() - iniciado,
    pontuacaoQualidade: null,
  };
}

// ── Vídeo ─────────────────────────────────────────────────────
async function _comprimirVideo(caminhoOriginal, tamanhoOriginal, iniciado) {
  const crf          = Number(process.env.VIDEO_CRF) || 28;
  const caminhoSaida = caminhoOriginal.replace(path.extname(caminhoOriginal), '_comprimido.mp4');

  await new Promise((resolver, rejeitar) => {
    ffmpeg(caminhoOriginal)
      .videoCodec('libx264')
      .addOption('-crf', String(crf))
      .addOption('-preset', 'fast')
      .audioCodec('aac')
      .output(caminhoSaida)
      .on('end',   resolver)
      .on('error', rejeitar)
      .run();
  });

  const tamanhoComprimido = fs.statSync(caminhoSaida).size;

  return {
    caminhoComprimido : caminhoSaida,
    tamanhoComprimido,
    codec             : 'H.264',
    duracaoMs         : Date.now() - iniciado,
    pontuacaoQualidade: 100 - crf, // estimativa simples
  };
}

module.exports = { comprimirFicheiro };
