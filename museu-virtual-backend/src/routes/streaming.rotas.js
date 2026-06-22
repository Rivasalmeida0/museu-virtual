'use strict';

const express = require('express');
const roteador = express.Router();
const Controlador = require('../controller/streaming.controlador');
const { verificarToken } = require('../middleware/autenticacao.middleware');

roteador.get('/salas', Controlador.listarSalas);
roteador.get('/token/:sala', Controlador.obterTokenSala);

module.exports = roteador;
