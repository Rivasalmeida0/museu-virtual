'use strict';
const express    = require('express');
const roteador   = express.Router();
const Controlador = require('../controller/exposicao.controlador');
const { registarActividade }          = require('../middleware/registo.middleware');

roteador.get('/',         Controlador.listar);
roteador.get('/:id',      Controlador.obterPorId);
roteador.post('/',        registarActividade('CRIAR_EXPOSICAO', 'exposicoes'), Controlador.criar);
roteador.put('/:id',      registarActividade('ACTUALIZAR_EXPOSICAO', 'exposicoes'), Controlador.actualizar);
roteador.delete('/:id',   registarActividade('REMOVER_EXPOSICAO',   'exposicoes'), Controlador.desactivar);

module.exports = roteador;
