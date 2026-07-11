// =============================================================
//  src/routes/historico.rotas.js
//  Rotas de histórico de visualizações — API VOD
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const express      = require('express');
const roteador     = express.Router();
const Controlador  = require('../controller/historico.controlador');
const { verificarToken } = require('../middleware/autenticacao.middleware');

// Todas as rotas de histórico requerem autenticação
roteador.use(verificarToken);

roteador.get('/',                Controlador.listar);
roteador.post('/:idConteudo',   Controlador.registar);
roteador.delete('/',            Controlador.limpar);
roteador.delete('/:id',         Controlador.removerItem);

module.exports = roteador;
