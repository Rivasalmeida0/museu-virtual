'use strict';
const express    = require('express');
const roteador   = express.Router();
const Controlador = require('../controller/relatorio.controlador');

roteador.get('/compressao', Controlador.obterRelatorioCompressao);

module.exports = roteador;
