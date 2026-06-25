'use strict';
const express    = require('express');
const roteador   = express.Router();
const Controlador = require('../controller/peca.controlador');
const { registarActividade }          = require('../middleware/registo.middleware');

roteador.get('/pesquisar',               Controlador.pesquisar);
roteador.get('/exposicao/:idExposicao',  Controlador.listarPorExposicao);
roteador.get('/:id',                     Controlador.obterPorId);
roteador.post('/',                       registarActividade('CRIAR_PECA', 'pecas'), Controlador.criar);
roteador.put('/:id',                     registarActividade('ACTUALIZAR_PECA', 'pecas'), Controlador.actualizar);
roteador.delete('/:id',                  registarActividade('REMOVER_PECA', 'pecas'), Controlador.desactivar);

module.exports = roteador;
