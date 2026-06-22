// =============================================================
//  src/repository/media.repositorio.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const { query, queryOne } = require('../config/db');
const { QUERIES }         = require('../model/media.modelo');

async function listarPorPeca(idPeca) {
  return query(QUERIES.listarPorPeca, [idPeca]);
}

async function buscarPorId(id) {
  return queryOne(QUERIES.buscarPorId, [id]);
}

async function criar(dadosFicheiro) {
  const {
    idPeca, idEnviador, tipo, tipoMime, nomeOriginal,
    caminhoOriginal, caminhoComprimido,
    tamanhoOriginal, tamanhoComprimido,
    largura, altura, duracaoSegundos, principal,
  } = dadosFicheiro;

  const resultado = await query(QUERIES.criar, [
    idPeca, idEnviador, tipo, tipoMime, nomeOriginal,
    caminhoOriginal, caminhoComprimido ?? null,
    tamanhoOriginal, tamanhoComprimido ?? null,
    largura ?? null, altura ?? null,
    duracaoSegundos ?? null, principal ? 1 : 0,
  ]);
  return resultado.insertId;
}

async function actualizarComprimido(id, caminhoComprimido, tamanhoComprimido) {
  return query(QUERIES.actualizarComprimido, [caminhoComprimido, tamanhoComprimido, id]);
}

async function eliminar(id) {
  return query(QUERIES.eliminar, [id]);
}

// ── Registos de compressão ────────────────────────────────────
async function registarLogCompressao(idMedia, codec, tamanhoOriginal, tamanhoComprimido, pontuacaoQualidade, duracaoMs) {
  // taxa_compressao calculada aqui para evitar GENERATED ALWAYS AS no MySQL
  const taxaCompressao = tamanhoComprimido > 0
    ? parseFloat((tamanhoOriginal / tamanhoComprimido).toFixed(3))
    : 0;

  return query(
    `INSERT INTO registos_compressao
       (id_media, codec, tamanho_original, tamanho_comprimido,
        taxa_compressao, pontuacao_qualidade, duracao_ms)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [idMedia, codec, tamanhoOriginal, tamanhoComprimido,
     taxaCompressao, pontuacaoQualidade ?? null, duracaoMs]
  );
}

async function obterRelatorioCompressao(idMedia = null) {
  if (idMedia) {
    return query('SELECT * FROM vw_relatorio_compressao WHERE id_media = ?', [idMedia]);
  }
  return query('SELECT * FROM vw_relatorio_compressao ORDER BY id_media DESC');
}

// ── Sessões de streaming ──────────────────────────────────────
async function iniciarSessao(idUtilizador, idMedia, tipo, enderecoIp, agenteUtilizador) {
  const resultado = await query(
    `INSERT INTO sessoes_streaming
       (id_utilizador, id_media, tipo, endereco_ip, agente_utilizador)
     VALUES (?, ?, ?, ?, ?)`,
    [idUtilizador, idMedia, tipo, enderecoIp ?? null, agenteUtilizador ?? null]
  );
  return resultado.insertId;
}

async function terminarSessao(idSessao, bytesTransferidos, ultimaPosicaoSegundos) {
  return query(
    `UPDATE sessoes_streaming
     SET terminado_em = NOW(), bytes_transferidos = ?, ultima_posicao_s = ?
     WHERE id = ?`,
    [bytesTransferidos, ultimaPosicaoSegundos ?? 0, idSessao]
  );
}

module.exports = {
  listarPorPeca,
  buscarPorId,
  criar,
  actualizarComprimido,
  eliminar,
  registarLogCompressao,
  obterRelatorioCompressao,
  iniciarSessao,
  terminarSessao,
};
