// =============================================================
//  src/controller/relatorio.controlador.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const MediaRepositorio = require('../repository/media.repositorio');

async function obterRelatorioCompressao(req, res, next) {
  try {
    const { idMedia } = req.query;
    const relatorio   = await MediaRepositorio.obterRelatorioCompressao(idMedia ? Number(idMedia) : null);
    res.json({ sucesso: true, total: relatorio.length, dados: relatorio });
  } catch (erro) { next(erro); }
}

module.exports = { obterRelatorioCompressao };
