// =============================================================
//  src/repository/refresh_token.repositorio.js
//  Operações na tabela `refresh_tokens`
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const { query, queryOne } = require('../config/db');

const QUERIES = {
  criar: `INSERT INTO refresh_tokens (id_utilizador, token, expira_em)
          VALUES (?, ?, ?)`,

  buscarPorToken: `SELECT * FROM refresh_tokens
                   WHERE token = ? AND revogado = 0 AND expira_em > NOW()
                   LIMIT 1`,

  revogarPorToken: `UPDATE refresh_tokens SET revogado = 1 WHERE token = ?`,

  revogarTodosPorUtilizador: `UPDATE refresh_tokens SET revogado = 1
                              WHERE id_utilizador = ?`,

  limparExpirados: `DELETE FROM refresh_tokens
                    WHERE expira_em < NOW() OR revogado = 1`,
};

async function criar(idUtilizador, token, expiraEm) {
  return query(QUERIES.criar, [idUtilizador, token, expiraEm]);
}

async function buscarPorToken(token) {
  return queryOne(QUERIES.buscarPorToken, [token]);
}

async function revogarPorToken(token) {
  return query(QUERIES.revogarPorToken, [token]);
}

async function revogarTodosPorUtilizador(idUtilizador) {
  return query(QUERIES.revogarTodosPorUtilizador, [idUtilizador]);
}

async function limparExpirados() {
  return query(QUERIES.limparExpirados);
}

module.exports = {
  criar,
  buscarPorToken,
  revogarPorToken,
  revogarTodosPorUtilizador,
  limparExpirados,
};
