'use strict';

const express = require('express');
const roteador = express.Router();
const fs = require('fs');
const path = require('path');

function servirFicheiro(req, res, pasta, tipoMime) {
  const filename = req.params.filename;
  const filePath = path.join(__dirname, '../..', 'uploads', pasta, filename);

  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ sucesso: false, mensagem: 'Ficheiro não encontrado.' });
  }

  const stat = fs.statSync(filePath);
  const fileSize = stat.size;
  const range = req.headers.range;

  if (range) {
    const parts = range.replace(/bytes=/, '').split('-');

    // Suporta suffix range: "bytes=-500" (últimos 500 bytes)
    let start, end;
    if (parts[0] === '') {
      const suffix = parseInt(parts[1], 10);
      start = Math.max(0, fileSize - suffix);
      end = fileSize - 1;
    } else {
      start = parseInt(parts[0], 10);
      end = parts[1] !== undefined && parts[1] !== ''
        ? parseInt(parts[1], 10)
        : fileSize - 1;
    }

    // Validação: start ou end inválidos
    if (isNaN(start) || isNaN(end) || start >= fileSize || start > end) {
      res.writeHead(416, {
        'Content-Range': `bytes */${fileSize}`,
      });
      return res.end();
    }

    // Clamp end ao tamanho real
    if (end >= fileSize) end = fileSize - 1;

    const chunkSize = end - start + 1;
    const file = fs.createReadStream(filePath, { start, end });

    res.writeHead(206, {
      'Content-Range': `bytes ${start}-${end}/${fileSize}`,
      'Accept-Ranges': 'bytes',
      'Content-Length': chunkSize,
      'Content-Type': tipoMime,
    });
    file.pipe(res);
  } else {
    res.writeHead(200, {
      'Content-Length': fileSize,
      'Content-Type': tipoMime,
      'Accept-Ranges': 'bytes',
    });
    fs.createReadStream(filePath).pipe(res);
  }
}

roteador.get('/video/:filename',
  (req, res) => servirFicheiro(req, res, 'videos_comp', 'video/mp4')
);

roteador.get('/audio/:filename',
  (req, res) => servirFicheiro(req, res, 'audios_comp', 'audio/mpeg')
);

module.exports = roteador;
