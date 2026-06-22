'use strict';
const express    = require('express');
const roteador   = express.Router();
const Controlador = require('../controller/autenticacao.controlador');
const { registarActividade } = require('../middleware/registo.middleware');

roteador.post('/registar', registarActividade('REGISTO',  'users'), Controlador.registar);
roteador.post('/entrar',   registarActividade('LOGIN',    'users'), Controlador.entrar);
roteador.post('/renovar',  Controlador.renovarToken);

module.exports = roteador;
