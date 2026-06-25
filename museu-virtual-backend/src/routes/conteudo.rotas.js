'use strict';

const express = require('express');
const roteador = express.Router();
const Controlador = require('../controller/conteudo.controlador');
const { uploadUnico } = require('../middleware/upload.middleware');

roteador.get('/',        Controlador.listarTodos);
roteador.get('/pesquisar', Controlador.pesquisar);
roteador.get('/:id',     Controlador.obterPorId);

roteador.post('/',                Controlador.criar);
roteador.put('/:id',              Controlador.actualizar);
roteador.delete('/:id',           Controlador.desactivar);
roteador.post('/:id/imagem',      uploadUnico, Controlador.uploadImagem);

module.exports = roteador;
