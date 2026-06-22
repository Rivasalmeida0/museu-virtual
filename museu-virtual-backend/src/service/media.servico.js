// =============================================================
//  src/service/media.servico.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const fs               = require('fs');
const MediaRepositorio = require('../repository/media.repositorio');
const CompressaoServico = require('./compressao.servico');

async function processarUpload(ficheiro, idPeca, idEnviador, principal = false) {
  const { path: caminhoOriginal, mimetype: tipoMime,
          originalname: nomeOriginal, size: tamanhoOriginal } = ficheiro;

  const tipo = tipoMime.startsWith('image/') ? 'imagem'
             : tipoMime.startsWith('audio/') ? 'audio'
             : 'video';

  // 1. Comprimir
  const resultadoCompressao = await CompressaoServico.comprimirFicheiro(ficheiro);

  // 2. Guardar na BD
  const idMedia = await MediaRepositorio.criar({
    idPeca,
    idEnviador,
    tipo,
    tipoMime,
    nomeOriginal,
    caminhoOriginal,
    caminhoComprimido : resultadoCompressao.caminhoComprimido,
    tamanhoOriginal,
    tamanhoComprimido : resultadoCompressao.tamanhoComprimido,
    largura           : null,
    altura            : null,
    duracaoSegundos   : null,
    principal,
  });

  // 3. Guardar log de compressão (taxa calculada no repositório)
  await MediaRepositorio.registarLogCompressao(
    idMedia,
    resultadoCompressao.codec,
    tamanhoOriginal,
    resultadoCompressao.tamanhoComprimido,
    resultadoCompressao.pontuacaoQualidade,
    resultadoCompressao.duracaoMs
  );

  return MediaRepositorio.buscarPorId(idMedia);
}

async function eliminarMedia(idMedia) {
  const media = await MediaRepositorio.buscarPorId(idMedia);
  if (!media) {
    const erro = new Error('Ficheiro não encontrado.');
    erro.statusCode = 404;
    throw erro;
  }

  [media.caminhoOriginal, media.caminhoComprimido].forEach((caminho) => {
    if (caminho && fs.existsSync(caminho)) fs.unlinkSync(caminho);
  });

  await MediaRepositorio.eliminar(idMedia);
}

module.exports = { processarUpload, eliminarMedia };
