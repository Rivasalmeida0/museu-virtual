// =============================================================
//  src/routes/progresso.rotas.js
//  Rotas de progresso de reprodução (Continuar a assistir)
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const express      = require('express');
const roteador     = express.Router();
const Controlador  = require('../controller/progresso.controlador');
const { verificarToken } = require('../middleware/autenticacao.middleware');

// Todas as rotas de progresso requerem autenticação
roteador.use(verificarToken);

roteador.get('/',                Controlador.listar);
roteador.get('/:idConteudo',    Controlador.obter);
roteador.post('/',               Controlador.guardar);
roteador.delete('/:idConteudo', Controlador.remover);

module.exports = roteador;
