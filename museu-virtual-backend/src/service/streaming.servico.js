// =============================================================
//  src/service/streaming.servico.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const fs               = require('fs');
const MediaRepositorio = require('../repository/media.repositorio');

function servirStreamVOD(caminhoFicheiro, tipoMime, req, res) {
  if (!fs.existsSync(caminhoFicheiro)) {
    return res.status(404).json({ sucesso: false, mensagem: 'Ficheiro não encontrado.' });
  }

  const tamanhoTotal   = fs.statSync(caminhoFicheiro).size;
  const cabecalhoRange = req.headers['range'];

  if (!cabecalhoRange) {
    res.writeHead(200, {
      'Content-Type'  : tipoMime,
      'Content-Length': tamanhoTotal,
      'Accept-Ranges' : 'bytes',
    });
    fs.createReadStream(caminhoFicheiro).pipe(res);
    return;
  }

  const partes      = cabecalhoRange.replace(/bytes=/, '').split('-');

  let inicio, fim;
  if (partes[0] === '') {
    const suffix = parseInt(partes[1], 10);
    inicio = Math.max(0, tamanhoTotal - suffix);
    fim = tamanhoTotal - 1;
  } else {
    inicio = parseInt(partes[0], 10);
    fim = partes[1] !== undefined && partes[1] !== ''
      ? parseInt(partes[1], 10)
      : tamanhoTotal - 1;
  }

  if (isNaN(inicio) || isNaN(fim) || inicio >= tamanhoTotal || inicio > fim) {
    res.writeHead(416, {
      'Content-Range': `bytes */${tamanhoTotal}`,
    });
    return res.end();
  }

  if (fim >= tamanhoTotal) fim = tamanhoTotal - 1;

  const tamanhoChunk = fim - inicio + 1;

  res.writeHead(206, {
    'Content-Range' : `bytes ${inicio}-${fim}/${tamanhoTotal}`,
    'Accept-Ranges' : 'bytes',
    'Content-Length': tamanhoChunk,
    'Content-Type'  : tipoMime,
  });

  fs.createReadStream(caminhoFicheiro, { start: inicio, end: fim }).pipe(res);
}

async function iniciarSessaoStreaming(idUtilizador, idMedia, tipo, enderecoIp, agenteUtilizador) {
  return MediaRepositorio.iniciarSessao(idUtilizador, idMedia, tipo, enderecoIp, agenteUtilizador);
}

async function terminarSessaoStreaming(idSessao, bytesTransferidos, ultimaPosicaoSegundos) {
  return MediaRepositorio.terminarSessao(idSessao, bytesTransferidos, ultimaPosicaoSegundos);
}

module.exports = { servirStreamVOD, iniciarSessaoStreaming, terminarSessaoStreaming };
