'use strict';
const express   = require('express');
const roteador  = express.Router();
const Controlador = require('../controller/media.controlador');
const { verificarToken } = require('../middleware/autenticacao.middleware');
const { registarActividade } = require('../middleware/registo.middleware');

roteador.get('/vod/:id', verificarToken, registarActividade('STREAM_VOD', 'media_files'), Controlador.transmitir);

module.exports = roteador;
