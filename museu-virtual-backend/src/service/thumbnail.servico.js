// =============================================================
//  src/service/thumbnail.servico.js
//  Geração automática de thumbnails usando ffmpeg
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const ffmpeg = require('fluent-ffmpeg');
const path   = require('path');
const fs     = require('fs');
const logger = require('../middleware/logger');

/**
 * Gera um thumbnail a partir de um vídeo.
 *
 * @param {string} videoPath - Caminho completo do ficheiro de vídeo
 * @param {string} outputName - Nome do ficheiro de imagem de saída (ex: thumb_xxx.jpg)
 * @returns {Promise<string>} - Caminho relativo do thumbnail gerado
 */
async function gerarThumbnail(videoPath, outputName) {
  return new Promise((resolve, reject) => {
    const uploadDir = path.join(__dirname, '../..', 'uploads', 'imagens');
    
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }

    ffmpeg(videoPath)
      .on('end', () => {
        const relativePath = `/uploads/imagens/${outputName}`;
        logger.info(`Thumbnail gerado com sucesso: ${relativePath}`);
        resolve(relativePath);
      })
      .on('error', (err) => {
        logger.error(`Erro ao gerar thumbnail para ${videoPath}: ${err.message}`);
        // Retorna null ou rejeita
        reject(err);
      })
      .screenshots({
        count: 1,
        folder: uploadDir,
        filename: outputName,
        timemarks: ['00:00:02.000'], // Capturar no segundo 2
        size: '640x360'
      });
  });
}

module.exports = { gerarThumbnail };
