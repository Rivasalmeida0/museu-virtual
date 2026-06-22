'use strict';
const express    = require('express');
const roteador   = express.Router();
const Controlador = require('../controller/exposicao.controlador');
const { verificarToken, apenasAdmin } = require('../middleware/autenticacao.middleware');
const { registarActividade }          = require('../middleware/registo.middleware');

roteador.get('/',         verificarToken, Controlador.listar);
roteador.get('/:id',      verificarToken, Controlador.obterPorId);
roteador.post('/',        verificarToken, apenasAdmin, registarActividade('CRIAR_EXPOSICAO', 'exposicoes'), Controlador.criar);
roteador.put('/:id',      verificarToken, apenasAdmin, registarActividade('ACTUALIZAR_EXPOSICAO', 'exposicoes'), Controlador.actualizar);
roteador.delete('/:id',   verificarToken, apenasAdmin, registarActividade('REMOVER_EXPOSICAO',   'exposicoes'), Controlador.desactivar);

module.exports = roteador;
