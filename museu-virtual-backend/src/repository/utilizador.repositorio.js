// =============================================================
//  src/repository/utilizador.repositorio.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const { query, queryOne } = require('../config/db');
const { QUERIES }         = require('../model/utilizador.modelo');

async function buscarPorEmail(email) {
  return queryOne(QUERIES.buscarPorEmail, [email]);
}

async function buscarPorId(id) {
  return queryOne(QUERIES.buscarPorId, [id]);
}

async function listarTodos() {
  return query(QUERIES.listarTodos);
}

async function criar(nome, email, hashSenha, funcao = 'visitante') {
  const resultado = await query(QUERIES.criar, [nome, email, hashSenha, funcao]);
  return resultado.insertId;
}

async function actualizar(id, nome, biografia, urlAvatar) {
  return query(QUERIES.actualizar, [nome, biografia, urlAvatar, id]);
}

async function alterarSenha(id, novoHashSenha) {
  return query(QUERIES.alterarSenha, [novoHashSenha, id]);
}

async function desactivar(id) {
  return query(QUERIES.desactivar, [id]);
}

module.exports = {
  buscarPorEmail,
  buscarPorId,
  listarTodos,
  criar,
  actualizar,
  alterarSenha,
  desactivar,
};
