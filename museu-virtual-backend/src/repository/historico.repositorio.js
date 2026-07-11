// =============================================================
//  src/repository/historico.repositorio.js
//  Operações na tabela `historico_visualizacoes`
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const { query } = require('../config/db');

const QUERIES = {
  listarPorUtilizador: `
    SELECT h.id, h.id_conteudo AS idConteudo, h.visto_em AS vistoEm,
           c.nome, c.ano, c.fabricante, c.categoria,
           c.descricao, c.imagem_url AS imagemUrl,
           c.video_url AS videoUrl
    FROM historico_visualizacoes h
    JOIN computadores c ON c.id = h.id_conteudo
    WHERE h.id_utilizador = ? AND c.activa = 1
    ORDER BY h.visto_em DESC
    LIMIT ?`,

  registar: `
    INSERT INTO historico_visualizacoes (id_utilizador, id_conteudo)
    VALUES (?, ?)`,

  limparPorUtilizador: `
    DELETE FROM historico_visualizacoes WHERE id_utilizador = ?`,

  removerItem: `
    DELETE FROM historico_visualizacoes WHERE id = ? AND id_utilizador = ?`,
};

async function listarPorUtilizador(idUtilizador, limite = 50) {
  const limitSanitizado = parseInt(limite, 10) || 50;
  const sql = `
    SELECT h.id, h.id_conteudo AS idConteudo, h.visto_em AS vistoEm,
           c.nome, c.ano, c.fabricante, c.categoria,
           c.descricao, c.imagem_url AS imagemUrl,
           c.video_url AS videoUrl
    FROM historico_visualizacoes h
    JOIN computadores c ON c.id = h.id_conteudo
    WHERE h.id_utilizador = ? AND c.activa = 1
    ORDER BY h.visto_em DESC
    LIMIT ${limitSanitizado}`;
  return query(sql, [idUtilizador]);
}

async function registar(idUtilizador, idConteudo) {
  return query(QUERIES.registar, [idUtilizador, idConteudo]);
}

async function limparPorUtilizador(idUtilizador) {
  return query(QUERIES.limparPorUtilizador, [idUtilizador]);
}

async function removerItem(id, idUtilizador) {
  return query(QUERIES.removerItem, [id, idUtilizador]);
}

module.exports = {
  listarPorUtilizador,
  registar,
  limparPorUtilizador,
  removerItem,
};
