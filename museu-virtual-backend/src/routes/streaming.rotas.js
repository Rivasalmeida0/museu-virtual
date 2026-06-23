'use strict';

const express = require('express');
const roteador = express.Router();
const Controlador = require('../controller/streaming.controlador');

roteador.get('/salas', Controlador.listarSalas);

module.exports = roteador;
