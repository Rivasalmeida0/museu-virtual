'use strict';

const ComputadorRepositorio = require('../repository/computador.repositorio');

async function listarTodos(req, res, next) {
  try {
    const computadores = await ComputadorRepositorio.listarTodos();
    res.json({ sucesso: true, dados: computadores });
  } catch (erro) { next(erro); }
}

async function listarPorCategoria(req, res, next) {
  try {
    const { categoria } = req.params;
    if (!['historico', 'supercomputador'].includes(categoria)) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Categoria inválida. Use "historico" ou "supercomputador".',
      });
    }
    const computadores = await ComputadorRepositorio.listarPorCategoria(categoria);
    res.json({ sucesso: true, dados: computadores });
  } catch (erro) { next(erro); }
}

async function obterPorId(req, res, next) {
  try {
    const computador = await ComputadorRepositorio.buscarPorId(req.params.id);
    if (!computador) {
      return res.status(404).json({ sucesso: false, mensagem: 'Computador não encontrado.' });
    }
    if (computador.especificacoes && typeof computador.especificacoes === 'string') {
      try { computador.especificacoes = JSON.parse(computador.especificacoes); }
      catch { computador.especificacoes = []; }
    }
    res.json({ sucesso: true, dados: computador });
  } catch (erro) { next(erro); }
}

async function pesquisar(req, res, next) {
  try {
    const { q } = req.query;
    if (!q) {
      return res.status(400).json({ sucesso: false, mensagem: 'Parâmetro "q" é obrigatório.' });
    }
    const resultados = await ComputadorRepositorio.pesquisar(q);
    res.json({ sucesso: true, total: resultados.length, dados: resultados });
  } catch (erro) { next(erro); }
}

async function criar(req, res, next) {
  try {
    const { nome } = req.body;
    if (!nome) {
      return res.status(400).json({ sucesso: false, mensagem: 'Nome é obrigatório.' });
    }
    const idNovo = await ComputadorRepositorio.criar(req.body);
    const computador = await ComputadorRepositorio.buscarPorId(idNovo);
    res.status(201).json({ sucesso: true, mensagem: 'Computador criado.', dados: computador });
  } catch (erro) { next(erro); }
}

async function actualizar(req, res, next) {
  try {
    await ComputadorRepositorio.actualizar(req.params.id, req.body);
    const computador = await ComputadorRepositorio.buscarPorId(req.params.id);
    res.json({ sucesso: true, mensagem: 'Computador actualizado.', dados: computador });
  } catch (erro) { next(erro); }
}

async function desactivar(req, res, next) {
  try {
    await ComputadorRepositorio.desactivar(req.params.id);
    res.json({ sucesso: true, mensagem: 'Computador removido.' });
  } catch (erro) { next(erro); }
}

module.exports = {
  listarTodos, listarPorCategoria, obterPorId,
  pesquisar, criar, actualizar, desactivar,
};
