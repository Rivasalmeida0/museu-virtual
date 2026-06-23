// =============================================================
//  src/repository/conteudo.repositorio.js
//  Operações CRUD na tabela `computadores` (conteúdos do museu).
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const { query, queryOne } = require('../config/db');
const { QUERIES } = require('../model/conteudo.modelo');

async function listarTodos() {
  return query(QUERIES.listarTodos);
}

async function buscarPorId(id) {
  return queryOne(QUERIES.buscarPorId, [id]);
}

async function criar(dados) {
  const { nome, ano, fabricante, categoria, descricao, curiosidade, wikipedia_url } = dados;
  const resultado = await query(QUERIES.criar, [
    nome, ano ?? null, fabricante ?? null, categoria ?? 'historico',
    descricao ?? null, curiosidade ?? null, wikipedia_url ?? null,
  ]);
  return resultado.insertId;
}

async function actualizar(id, dados) {
  const { nome, ano, fabricante, categoria, descricao, curiosidade, wikipedia_url } = dados;
  return query(QUERIES.actualizar, [
    nome, ano ?? null, fabricante ?? null, categoria ?? 'historico',
    descricao ?? null, curiosidade ?? null, wikipedia_url ?? null, id,
  ]);
}

async function actualizarImagem(id, caminhoImagem) {
  return query(QUERIES.actualizarImagem, [caminhoImagem, id]);
}

async function desactivar(id) {
  return query(QUERIES.desactivar, [id]);
}

module.exports = {
  listarTodos,
  buscarPorId,
  criar,
  actualizar,
  actualizarImagem,
  desactivar,
};
