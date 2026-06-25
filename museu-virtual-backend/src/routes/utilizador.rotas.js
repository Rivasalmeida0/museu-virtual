'use strict';
const express    = require('express');
const roteador   = express.Router();
const UtilizadorRepositorio           = require('../repository/utilizador.repositorio');

roteador.get('/', async (req, res, next) => {
  try {
    const utilizadores = await UtilizadorRepositorio.listarTodos();
    res.json({ sucesso: true, dados: utilizadores });
  } catch (erro) { next(erro); }
});

module.exports = roteador;
