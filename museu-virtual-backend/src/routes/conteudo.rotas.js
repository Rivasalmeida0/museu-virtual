// =============================================================
//  src/routes/conteudo.rotas.js
//  Rotas para gestão de conteúdos do museu.
//  GET  /conteudos       — público
//  GET  /conteudos/:id   — público
//  POST /conteudos       — gestor
//  POST /conteudos/:id/imagem — gestor (upload)
//  PUT  /conteudos/:id   — gestor
//  DELETE /conteudos/:id  — gestor
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const express = require('express');
const roteador = express.Router();
const Controlador = require('../controller/conteudo.controlador');
const { verificarToken } = require('../middleware/autenticacao.middleware');
const { checkRole } = require('../middleware/checkRole');
const { uploadUnico } = require('../middleware/upload.middleware');

// Públicas
roteador.get('/',        Controlador.listarTodos);
roteador.get('/pesquisar', Controlador.pesquisar);
roteador.get('/:id',     Controlador.obterPorId);

// Protegidas — apenas gestores
roteador.post('/',                verificarToken, checkRole('gestor', 'admin'), Controlador.criar);
roteador.put('/:id',              verificarToken, checkRole('gestor', 'admin'), Controlador.actualizar);
roteador.delete('/:id',           verificarToken, checkRole('gestor', 'admin'), Controlador.desactivar);
roteador.post('/:id/imagem',      verificarToken, checkRole('gestor', 'admin'), uploadUnico, Controlador.uploadImagem);

module.exports = roteador;
