// =============================================================
//  src/repository/categoria.repositorio.js
//  Operações na tabela `categorias_vod`
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const { query, queryOne } = require('../config/db');

const QUERIES = {
  listarTodas: `
    SELECT id, nome, descricao, icone, cor, ordem
    FROM categorias_vod
    WHERE activa = 1
    ORDER BY ordem ASC, nome ASC`,

  buscarPorId: `
    SELECT id, nome, descricao, icone, cor
    FROM categorias_vod
    WHERE id = ? AND activa = 1
    LIMIT 1`,

  listarConteudosPorCategoria: `
    SELECT c.id, c.nome, c.ano, c.fabricante, c.categoria,
           c.descricao, c.imagem_url AS imagemUrl,
           c.video_url AS videoUrl,
           c.criado_em AS criadoEm
    FROM conteudo_categorias cc
    JOIN computadores c ON c.id = cc.id_conteudo
    WHERE cc.id_categoria = ? AND c.activa = 1
    ORDER BY c.criado_em DESC`,

  criar: `
    INSERT INTO categorias_vod (nome, descricao, icone, cor, ordem)
    VALUES (?, ?, ?, ?, ?)`,

  actualizar: `
    UPDATE categorias_vod
    SET nome = ?, descricao = ?, icone = ?, cor = ?, ordem = ?
    WHERE id = ?`,

  desactivar: `
    UPDATE categorias_vod SET activa = 0 WHERE id = ?`,

  associarConteudo: `
    INSERT IGNORE INTO conteudo_categorias (id_conteudo, id_categoria)
    VALUES (?, ?)`,

  desassociarConteudo: `
    DELETE FROM conteudo_categorias
    WHERE id_conteudo = ? AND id_categoria = ?`,
};

async function listarTodas() {
  return query(QUERIES.listarTodas);
}

async function buscarPorId(id) {
  return queryOne(QUERIES.buscarPorId, [id]);
}

async function listarConteudosPorCategoria(idCategoria) {
  return query(QUERIES.listarConteudosPorCategoria, [idCategoria]);
}

async function criar(dados) {
  const resultado = await query(QUERIES.criar, [
    dados.nome, dados.descricao || null, dados.icone || null,
    dados.cor || null, dados.ordem || 0,
  ]);
  return resultado.insertId;
}

async function actualizar(id, dados) {
  return query(QUERIES.actualizar, [
    dados.nome, dados.descricao || null, dados.icone || null,
    dados.cor || null, dados.ordem || 0, id,
  ]);
}

async function desactivar(id) {
  return query(QUERIES.desactivar, [id]);
}

async function associarConteudo(idConteudo, idCategoria) {
  return query(QUERIES.associarConteudo, [idConteudo, idCategoria]);
}

async function desassociarConteudo(idConteudo, idCategoria) {
  return query(QUERIES.desassociarConteudo, [idConteudo, idCategoria]);
}

module.exports = {
  listarTodas,
  buscarPorId,
  listarConteudosPorCategoria,
  criar,
  actualizar,
  desactivar,
  associarConteudo,
  desassociarConteudo,
};
