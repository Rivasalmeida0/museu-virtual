'use strict';
const express    = require('express');
const roteador   = express.Router();
const Controlador = require('../controller/autenticacao.controlador');
const { verificarToken } = require('../middleware/autenticacao.middleware');
const { registarActividade } = require('../middleware/registo.middleware');

roteador.post('/registar', registarActividade('REGISTO', 'users'), Controlador.registar);
roteador.post('/entrar',   registarActividade('LOGIN',   'users'), Controlador.entrar);
roteador.get('/me',        verificarToken, Controlador.me);

module.exports = roteador;
