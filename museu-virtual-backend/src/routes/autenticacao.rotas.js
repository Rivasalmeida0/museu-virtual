// =============================================================
//  src/routes/autenticacao.rotas.js
//  Rotas de autenticação — registo, login, refresh, logout, perfil
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const express     = require('express');
const roteador    = express.Router();
const Controlador = require('../controller/autenticacao.controlador');
const { registarActividade } = require('../middleware/registo.middleware');
const { verificarToken }     = require('../middleware/autenticacao.middleware');

// Rotas públicas (não requerem JWT)
roteador.post('/registar', registarActividade('REGISTO', 'users'), Controlador.registar);
roteador.post('/entrar',   registarActividade('LOGIN',   'users'), Controlador.entrar);
roteador.post('/renovar',  Controlador.renovar);

// Rotas protegidas (requerem JWT)
roteador.post('/sair',   verificarToken, Controlador.sair);
roteador.get('/perfil',  verificarToken, Controlador.perfil);

module.exports = roteador;
