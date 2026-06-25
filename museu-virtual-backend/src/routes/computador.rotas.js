'use strict';

const express = require('express');
const roteador = express.Router();
const Controlador = require('../controller/computador.controlador');

roteador.get('/',              Controlador.listarTodos);
roteador.get('/pesquisar',     Controlador.pesquisar);
roteador.get('/categoria/:categoria', Controlador.listarPorCategoria);
roteador.get('/:id',           Controlador.obterPorId);

roteador.post('/',             Controlador.criar);
roteador.put('/:id',           Controlador.actualizar);
roteador.delete('/:id',        Controlador.desactivar);

module.exports = roteador;
