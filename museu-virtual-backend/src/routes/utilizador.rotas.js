'use strict';
const express    = require('express');
const roteador   = express.Router();
const { verificarToken, apenasAdmin } = require('../middleware/autenticacao.middleware');
const UtilizadorRepositorio           = require('../repository/utilizador.repositorio');

roteador.get('/perfil', verificarToken, async (req, res, next) => {
  try {
    const utilizador = await UtilizadorRepositorio.buscarPorId(req.utilizadorAutenticado.id);
    res.json({ sucesso: true, dados: utilizador });
  } catch (erro) { next(erro); }
});

roteador.put('/perfil', verificarToken, async (req, res, next) => {
  try {
    const { nome, biografia, urlAvatar } = req.body;
    await UtilizadorRepositorio.actualizar(req.utilizadorAutenticado.id, nome, biografia, urlAvatar);
    const utilizador = await UtilizadorRepositorio.buscarPorId(req.utilizadorAutenticado.id);
    res.json({ sucesso: true, mensagem: 'Perfil actualizado.', dados: utilizador });
  } catch (erro) { next(erro); }
});

roteador.get('/', verificarToken, apenasAdmin, async (req, res, next) => {
  try {
    const utilizadores = await UtilizadorRepositorio.listarTodos();
    res.json({ sucesso: true, dados: utilizadores });
  } catch (erro) { next(erro); }
});

module.exports = roteador;
