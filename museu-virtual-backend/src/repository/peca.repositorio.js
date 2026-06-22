// =============================================================
//  src/repository/peca.repositorio.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const { query, queryOne } = require('../config/db');
const { QUERIES }         = require('../model/peca.modelo');

async function listarPorExposicao(idExposicao) {
  return query(QUERIES.listarPorExposicao, [idExposicao]);
}

async function buscarPorId(id) {
  return queryOne(QUERIES.buscarPorId, [id]);
}

async function pesquisar(termoPesquisa, limite = 20, deslocamento = 0) {
  const termoFormatado = termoPesquisa
    .trim()
    .split(/\s+/)
    .map((palavra) => `+${palavra}*`)
    .join(' ');
  return query(QUERIES.pesquisar, [termoFormatado, limite, deslocamento]);
}

async function criar(idExposicao, titulo, descricao, origem, periodo, autor, etiquetas, idCriador) {
  const resultado = await query(QUERIES.criar, [
    idExposicao, titulo, descricao, origem, periodo, autor, etiquetas, idCriador,
  ]);
  return resultado.insertId;
}

async function actualizar(id, titulo, descricao, origem, periodo, autor, etiquetas) {
  return query(QUERIES.actualizar, [titulo, descricao, origem, periodo, autor, etiquetas, id]);
}

async function desactivar(id) {
  return query(QUERIES.desactivar, [id]);
}

module.exports = {
  listarPorExposicao,
  buscarPorId,
  pesquisar,
  criar,
  actualizar,
  desactivar,
};
