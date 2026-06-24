'use strict';

const express = require('express');
const roteador = express.Router();
const path = require('path');
const fs = require('fs');
const jwt = require('jsonwebtoken');
const { verificarToken } = require('../middleware/autenticacao.middleware');
const segredo = process.env.JWT_SECRET || 'museu-virtual-segredo-dev';

function fazerDownload(req, res, pasta) {
  const filename = req.params.filename;
  const filePath = path.join(__dirname, '../..', 'uploads', pasta, filename);

  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ sucesso: false, mensagem: 'Ficheiro não encontrado.' });
  }

  res.download(filePath);
}

function verificarTokenOuQuery(req, res, next) {
  const token = req.query.token || req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ sucesso: false, mensagem: 'Token ausente.' });
  try {
    const decodificado = jwt.verify(token, segredo);
    req.utilizadorAutenticado = decodificado;
    next();
  } catch {
    return res.status(401).json({ sucesso: false, mensagem: 'Token inválido.' });
  }
}

roteador.get('/video/:filename',
  verificarTokenOuQuery,
  (req, res) => fazerDownload(req, res, 'videos_comp')
);

roteador.get('/audio/:filename',
  verificarTokenOuQuery,
  (req, res) => fazerDownload(req, res, 'audios_comp')
);

roteador.get('/imagem/:filename',
  verificarTokenOuQuery,
  (req, res) => fazerDownload(req, res, 'imagens_comp')
);

module.exports = roteador;
