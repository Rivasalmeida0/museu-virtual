// =============================================================
//  src/controller/peca.controlador.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const PecaRepositorio = require('../repository/peca.repositorio');

async function listarPorExposicao(req, res, next) {
  try {
    const pecas = await PecaRepositorio.listarPorExposicao(req.params.idExposicao);
    res.json({ sucesso: true, dados: pecas });
  } catch (erro) { next(erro); }
}

async function obterPorId(req, res, next) {
  try {
    const peca = await PecaRepositorio.buscarPorId(req.params.id);
    if (!peca) return res.status(404).json({ sucesso: false, mensagem: 'Peça não encontrada.' });
    res.json({ sucesso: true, dados: peca });
  } catch (erro) { next(erro); }
}

async function pesquisar(req, res, next) {
  try {
    const { termo, limite = 20, pagina = 1 } = req.query;
    if (!termo) return res.status(400).json({ sucesso: false, mensagem: 'O parâmetro "termo" é obrigatório.' });
    const deslocamento = (Number(pagina) - 1) * Number(limite);
    const resultados   = await PecaRepositorio.pesquisar(termo, Number(limite), deslocamento);
    res.json({ sucesso: true, total: resultados.length, dados: resultados });
  } catch (erro) { next(erro); }
}

async function criar(req, res, next) {
  try {
    const { idExposicao, titulo, descricao, origem, periodo, autor, etiquetas } = req.body;
    if (!idExposicao || !titulo) {
      return res.status(400).json({ sucesso: false, mensagem: 'idExposicao e título são obrigatórios.' });
    }
    const idNova = await PecaRepositorio.criar(
      idExposicao, titulo, descricao, origem, periodo, autor, etiquetas,
      req.utilizadorAutenticado.id
    );
    const peca = await PecaRepositorio.buscarPorId(idNova);
    res.status(201).json({ sucesso: true, mensagem: 'Peça criada.', dados: peca });
  } catch (erro) { next(erro); }
}

async function actualizar(req, res, next) {
  try {
    const { titulo, descricao, origem, periodo, autor, etiquetas } = req.body;
    await PecaRepositorio.actualizar(req.params.id, titulo, descricao, origem, periodo, autor, etiquetas);
    const peca = await PecaRepositorio.buscarPorId(req.params.id);
    res.json({ sucesso: true, mensagem: 'Peça actualizada.', dados: peca });
  } catch (erro) { next(erro); }
}

async function desactivar(req, res, next) {
  try {
    await PecaRepositorio.desactivar(req.params.id);
    res.json({ sucesso: true, mensagem: 'Peça removida.' });
  } catch (erro) { next(erro); }
}

module.exports = { listarPorExposicao, obterPorId, pesquisar, criar, actualizar, desactivar };
