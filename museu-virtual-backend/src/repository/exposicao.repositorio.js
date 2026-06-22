// =============================================================
//  src/repository/exposicao.repositorio.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const { query, queryOne } = require('../config/db');
const { QUERIES }         = require('../model/exposicao.modelo');

async function listarActivas() {
  return query(QUERIES.listarActivas);
}

async function buscarPorId(id) {
  return queryOne(QUERIES.buscarPorId, [id]);
}

async function criar(titulo, descricao, tema, urlMiniatura, idCriador) {
  const resultado = await query(QUERIES.criar, [titulo, descricao, tema, urlMiniatura, idCriador]);
  return resultado.insertId;
}

async function actualizar(id, titulo, descricao, tema, urlMiniatura) {
  return query(QUERIES.actualizar, [titulo, descricao, tema, urlMiniatura, id]);
}

async function desactivar(id) {
  return query(QUERIES.desactivar, [id]);
}

async function contarPecas(idExposicao) {
  const resultado = await queryOne(QUERIES.contarPecas, [idExposicao]);
  return resultado?.totalPecas ?? 0;
}

module.exports = {
  listarActivas,
  buscarPorId,
  criar,
  actualizar,
  desactivar,
  contarPecas,
};
