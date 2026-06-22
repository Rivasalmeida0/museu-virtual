'use strict';

const { query, queryOne } = require('../config/db');
const { QUERIES } = require('../model/computador.modelo');

async function listarTodos() {
  return query(QUERIES.listarTodos);
}

async function listarPorCategoria(categoria) {
  return query(QUERIES.listarPorCategoria, [categoria]);
}

async function buscarPorId(id) {
  return queryOne(QUERIES.buscarPorId, [id]);
}

async function pesquisar(termo) {
  const like = `%${termo}%`;
  return query(QUERIES.pesquisar, [like, like, like]);
}

async function criar(dados) {
  const { nome, ano, fabricante, categoria, descricao, curiosidade,
          imagem_url, wikipedia_url, especificacoes } = dados;
  const resultado = await query(QUERIES.criar, [
    nome, ano, fabricante, categoria, descricao, curiosidade,
    imagem_url, wikipedia_url, JSON.stringify(especificacoes ?? []),
  ]);
  return resultado.insertId;
}

async function actualizar(id, dados) {
  const { nome, ano, fabricante, categoria, descricao, curiosidade,
          imagem_url, wikipedia_url, especificacoes } = dados;
  return query(QUERIES.actualizar, [
    nome, ano, fabricante, categoria, descricao, curiosidade,
    imagem_url, wikipedia_url, JSON.stringify(especificacoes ?? []), id,
  ]);
}

async function desactivar(id) {
  return query(QUERIES.desactivar, [id]);
}

module.exports = {
  listarTodos, listarPorCategoria, buscarPorId,
  pesquisar, criar, actualizar, desactivar,
};
