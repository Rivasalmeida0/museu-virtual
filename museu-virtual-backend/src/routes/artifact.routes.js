'use strict';
const express    = require('express');
const roteador   = express.Router();
const Controlador = require('../controller/peca.controlador');
const { verificarToken, apenasAdmin } = require('../middleware/autenticacao.middleware');
const { registarActividade }          = require('../middleware/registo.middleware');

roteador.get('/pesquisar',               verificarToken, Controlador.pesquisar);
roteador.get('/exposicao/:idExposicao',  verificarToken, Controlador.listarPorExposicao);
roteador.get('/:id',                     verificarToken, Controlador.obterPorId);
roteador.post('/',                       verificarToken, apenasAdmin, registarActividade('CRIAR_PECA', 'artifacts'), Controlador.criar);
roteador.put('/:id',                     verificarToken, apenasAdmin, registarActividade('ACTUALIZAR_PECA', 'artifacts'), Controlador.actualizar);
roteador.delete('/:id',                  verificarToken, apenasAdmin, registarActividade('REMOVER_PECA', 'artifacts'), Controlador.desactivar);

module.exports = roteador;
