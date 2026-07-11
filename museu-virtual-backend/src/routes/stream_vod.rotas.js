'use strict';

const express = require('express');
const roteador = express.Router();
const path = require('path');
const { servirStreamVOD } = require('../service/streaming.servico');

function servirFicheiro(req, res, pasta, tipoMime) {
  const filename = req.params.filename;
  const filePath = path.join(__dirname, '../..', 'uploads', pasta, filename);
  servirStreamVOD(filePath, tipoMime, req, res);
}

roteador.get('/video/:filename',
  (req, res) => servirFicheiro(req, res, 'videos_comp', 'video/mp4')
);

roteador.get('/audio/:filename',
  (req, res) => servirFicheiro(req, res, 'audios_comp', 'audio/mpeg')
);

module.exports = roteador;
