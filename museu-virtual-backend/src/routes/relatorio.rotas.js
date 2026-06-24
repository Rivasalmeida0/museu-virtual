'use strict';
const express    = require('express');
const roteador   = express.Router();
const Controlador = require('../controller/relatorio.controlador');
const { verificarToken } = require('../middleware/autenticacao.middleware');
const { checkRole } = require('../middleware/checkRole');

roteador.get('/compressao', verificarToken, checkRole('gestor', 'admin'), Controlador.obterRelatorioCompressao);

module.exports = roteador;
