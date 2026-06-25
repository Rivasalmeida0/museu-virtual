'use strict';

const express = require('express');
const roteador = express.Router();
const path = require('path');
const fs = require('fs');

function fazerDownload(req, res, pasta) {
  const filename = req.params.filename;
  const filePath = path.join(__dirname, '../..', 'uploads', pasta, filename);

  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ sucesso: false, mensagem: 'Ficheiro não encontrado.' });
  }

  res.download(filePath);
}

roteador.get('/video/:filename',
  (req, res) => fazerDownload(req, res, 'videos_comp')
);

roteador.get('/audio/:filename',
  (req, res) => fazerDownload(req, res, 'audios_comp')
);

roteador.get('/imagem/:filename',
  (req, res) => fazerDownload(req, res, 'imagens_comp')
);

module.exports = roteador;
