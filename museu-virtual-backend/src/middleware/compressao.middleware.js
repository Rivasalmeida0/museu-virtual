// =============================================================
//  src/middleware/compressao.middleware.js
//  Comprime automaticamente o ficheiro após o upload
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const CompressaoServico = require('../service/compressao.servico');

/**
 * Middleware executado APÓS o upload (uploadUnico).
 * Comprime o ficheiro e enriquece req com os caminhos e métricas.
 */
async function comprimirAposUpload(req, res, next) {
  if (!req.file) return next();

  try {
    const resultado = await CompressaoServico.comprimirFicheiro(req.file);
    req.resultadoCompressao = resultado;
    next();
  } catch (erro) {
    next(erro);
  }
}

module.exports = { comprimirAposUpload };
