// =============================================================
//  src/controller/exposicao.controlador.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const ExposicaoRepositorio = require('../repository/exposicao.repositorio');

async function listar(req, res, next) {
  try {
    const exposicoes = await ExposicaoRepositorio.listarActivas();
    res.json({ sucesso: true, dados: exposicoes });
  } catch (erro) { next(erro); }
}

async function obterPorId(req, res, next) {
  try {
    const exposicao  = await ExposicaoRepositorio.buscarPorId(req.params.id);
    if (!exposicao) return res.status(404).json({ sucesso: false, mensagem: 'Exposição não encontrada.' });
    const totalPecas = await ExposicaoRepositorio.contarPecas(req.params.id);
    res.json({ sucesso: true, dados: { ...exposicao, totalPecas } });
  } catch (erro) { next(erro); }
}

async function criar(req, res, next) {
  try {
    const { titulo, descricao, tema, urlMiniatura } = req.body;
    if (!titulo) return res.status(400).json({ sucesso: false, mensagem: 'O título é obrigatório.' });
    const idNova    = await ExposicaoRepositorio.criar(titulo, descricao, tema, urlMiniatura, req.utilizadorAutenticado.id);
    const exposicao = await ExposicaoRepositorio.buscarPorId(idNova);
    res.status(201).json({ sucesso: true, mensagem: 'Exposição criada.', dados: exposicao });
  } catch (erro) { next(erro); }
}

async function actualizar(req, res, next) {
  try {
    const { titulo, descricao, tema, urlMiniatura } = req.body;
    await ExposicaoRepositorio.actualizar(req.params.id, titulo, descricao, tema, urlMiniatura);
    const exposicao = await ExposicaoRepositorio.buscarPorId(req.params.id);
    res.json({ sucesso: true, mensagem: 'Exposição actualizada.', dados: exposicao });
  } catch (erro) { next(erro); }
}

async function desactivar(req, res, next) {
  try {
    await ExposicaoRepositorio.desactivar(req.params.id);
    res.json({ sucesso: true, mensagem: 'Exposição removida.' });
  } catch (erro) { next(erro); }
}

module.exports = { listar, obterPorId, criar, actualizar, desactivar };
