// =============================================================
//  src/routes/favorito.rotas.js
//  Rotas de favoritos — API VOD
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const express      = require('express');
const roteador     = express.Router();
const Controlador  = require('../controller/favorito.controlador');
const { verificarToken } = require('../middleware/autenticacao.middleware');

// Todas as rotas de favoritos requerem autenticação
roteador.use(verificarToken);

roteador.get('/',                       Controlador.listar);
roteador.get('/verificar/:idConteudo',  Controlador.verificar);
roteador.post('/:idConteudo',           Controlador.adicionar);
roteador.delete('/:idConteudo',         Controlador.remover);

module.exports = roteador;
