// =============================================================
//  src/repository/progresso.repositorio.js
//  Operações na tabela `progresso_reproducao`
//  (Continuar a assistir)
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const { query, queryOne } = require('../config/db');

const QUERIES = {
  listarPorUtilizador: `
    SELECT p.id, p.id_conteudo AS idConteudo,
           p.posicao_segundos AS posicaoSegundos,
           p.duracao_total_segundos AS duracaoTotalSegundos,
           p.percentagem, p.actualizado_em AS actualizadoEm,
           c.nome, c.ano, c.fabricante, c.categoria,
           c.descricao, c.imagem_url AS imagemUrl,
           c.video_url AS videoUrl
    FROM progresso_reproducao p
    JOIN computadores c ON c.id = p.id_conteudo
    WHERE p.id_utilizador = ? AND c.activa = 1
      AND p.percentagem < 95
    ORDER BY p.actualizado_em DESC`,

  buscar: `
    SELECT * FROM progresso_reproducao
    WHERE id_utilizador = ? AND id_conteudo = ?
    LIMIT 1`,

  guardar: `
    INSERT INTO progresso_reproducao
      (id_utilizador, id_conteudo, posicao_segundos,
       duracao_total_segundos, percentagem)
    VALUES (?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      posicao_segundos = VALUES(posicao_segundos),
      duracao_total_segundos = VALUES(duracao_total_segundos),
      percentagem = VALUES(percentagem),
      actualizado_em = NOW()`,

  remover: `
    DELETE FROM progresso_reproducao
    WHERE id_utilizador = ? AND id_conteudo = ?`,

  limparPorUtilizador: `
    DELETE FROM progresso_reproducao WHERE id_utilizador = ?`,
};

async function listarPorUtilizador(idUtilizador) {
  return query(QUERIES.listarPorUtilizador, [idUtilizador]);
}

async function buscar(idUtilizador, idConteudo) {
  return queryOne(QUERIES.buscar, [idUtilizador, idConteudo]);
}

async function guardar(idUtilizador, idConteudo, posicao, duracao) {
  const percentagem = duracao > 0
    ? Math.min(100, Math.round((posicao / duracao) * 10000) / 100)
    : 0;
  return query(QUERIES.guardar, [
    idUtilizador, idConteudo, posicao, duracao, percentagem,
  ]);
}

async function remover(idUtilizador, idConteudo) {
  return query(QUERIES.remover, [idUtilizador, idConteudo]);
}

async function limparPorUtilizador(idUtilizador) {
  return query(QUERIES.limparPorUtilizador, [idUtilizador]);
}

module.exports = {
  listarPorUtilizador,
  buscar,
  guardar,
  remover,
  limparPorUtilizador,
};
