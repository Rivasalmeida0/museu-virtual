// =============================================================
//  src/repository/favorito.repositorio.js
//  Operações na tabela `favoritos`
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const { query, queryOne } = require('../config/db');

const QUERIES = {
  listarPorUtilizador: `
    SELECT f.id, f.id_peca AS idPeca, f.criado_em AS criadoEm,
           c.nome, c.ano, c.fabricante, c.categoria,
           c.descricao, c.imagem_url AS imagemUrl,
           c.video_url AS videoUrl
    FROM favoritos f
    JOIN computadores c ON c.id = f.id_peca
    WHERE f.id_utilizador = ? AND c.activa = 1
    ORDER BY f.criado_em DESC`,

  verificar: `
    SELECT id FROM favoritos
    WHERE id_utilizador = ? AND id_peca = ?
    LIMIT 1`,

  adicionar: `
    INSERT INTO favoritos (id_utilizador, id_peca) VALUES (?, ?)`,

  remover: `
    DELETE FROM favoritos WHERE id_utilizador = ? AND id_peca = ?`,

  contar: `
    SELECT COUNT(*) AS total FROM favoritos WHERE id_utilizador = ?`,
};

async function listarPorUtilizador(idUtilizador) {
  return query(QUERIES.listarPorUtilizador, [idUtilizador]);
}

async function verificar(idUtilizador, idPeca) {
  return queryOne(QUERIES.verificar, [idUtilizador, idPeca]);
}

async function adicionar(idUtilizador, idPeca) {
  return query(QUERIES.adicionar, [idUtilizador, idPeca]);
}

async function remover(idUtilizador, idPeca) {
  return query(QUERIES.remover, [idUtilizador, idPeca]);
}

async function contar(idUtilizador) {
  const resultado = await queryOne(QUERIES.contar, [idUtilizador]);
  return resultado?.total || 0;
}

module.exports = {
  listarPorUtilizador,
  verificar,
  adicionar,
  remover,
  contar,
};
