// =============================================================
//  src/repository/conteudo.repositorio.js
//  Operações CRUD na tabela `computadores` (conteúdos do museu).
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const { query, queryOne } = require('../config/db');
const { QUERIES } = require('../model/conteudo.modelo');

async function listarTodos(pesquisa = null, categoria = null) {
  if (pesquisa || categoria) {
    let sql = `SELECT c.id, c.nome, c.ano, c.fabricante, c.categoria,
               c.descricao, c.curiosidade,
               c.imagem_url AS imagemUrl,
               c.audio_url AS audioUrl,
               c.video_url AS videoUrl,
               c.relatorio_compressao AS relatorioCompressao,
               c.wikipedia_url AS wikipediaUrl,
               c.criado_em AS criadoEm,
               c.actualizado_em AS actualizadoEm
               FROM computadores c WHERE c.activa = 1`;
    const params = [];
    if (pesquisa) {
      sql += ' AND (c.nome LIKE ? OR c.fabricante LIKE ? OR c.descricao LIKE ?)';
      const termo = `%${pesquisa}%`;
      params.push(termo, termo, termo);
    }
    if (categoria) {
      sql += ' AND c.categoria = ?';
      params.push(categoria);
    }
    sql += ' ORDER BY c.criado_em DESC';
    return query(sql, params);
  }
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

async function actualizarImagemComRelatorio(id, url, relatorio) {
  return query(QUERIES.actualizarImagemComRelatorio, [url, relatorio, id]);
}

async function actualizarAudioComRelatorio(id, url, relatorio) {
  return query(QUERIES.actualizarAudioComRelatorio, [url, relatorio, id]);
}

async function actualizarVideoComRelatorio(id, url, relatorio) {
  return query(QUERIES.actualizarVideoComRelatorio, [url, relatorio, id]);
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
  actualizarImagemComRelatorio,
  actualizarAudioComRelatorio,
  actualizarVideoComRelatorio,
  desactivar,
};
