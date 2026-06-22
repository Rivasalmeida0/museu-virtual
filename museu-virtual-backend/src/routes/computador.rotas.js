'use strict';

const express = require('express');
const roteador = express.Router();
const Controlador = require('../controller/computador.controlador');
const { verificarToken, apenasAdmin } = require('../middleware/autenticacao.middleware');

roteador.get('/',              Controlador.listarTodos);
roteador.get('/pesquisar',     Controlador.pesquisar);
roteador.get('/categoria/:categoria', Controlador.listarPorCategoria);
roteador.get('/:id',           Controlador.obterPorId);

roteador.post('/',             verificarToken, apenasAdmin, Controlador.criar);
roteador.put('/:id',           verificarToken, apenasAdmin, Controlador.actualizar);
roteador.delete('/:id',        verificarToken, apenasAdmin, Controlador.desactivar);

module.exports = roteador;
