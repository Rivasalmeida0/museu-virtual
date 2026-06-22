'use strict';
const express    = require('express');
const roteador   = express.Router();
const Controlador = require('../controller/relatorio.controlador');
const { verificarToken, apenasAdmin } = require('../middleware/autenticacao.middleware');

roteador.get('/compressao', verificarToken, apenasAdmin, Controlador.obterRelatorioCompressao);

module.exports = roteador;
