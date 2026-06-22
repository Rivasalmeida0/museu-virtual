// =============================================================
//  src/controller/media.controlador.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const fs               = require('fs');
const MediaServico     = require('../service/media.servico');
const MediaRepositorio = require('../repository/media.repositorio');
const StreamingServico = require('../service/streaming.servico');

async function enviarFicheiro(req, res, next) {
  try {
    if (!req.file) return res.status(400).json({ sucesso: false, mensagem: 'Nenhum ficheiro enviado.' });
    const { idPeca, principal = 'false' } = req.body;
    if (!idPeca) return res.status(400).json({ sucesso: false, mensagem: 'idPeca é obrigatório.' });
    const media = await MediaServico.processarUpload(
      req.file, Number(idPeca), req.utilizadorAutenticado.id, principal === 'true'
    );
    res.status(201).json({ sucesso: true, mensagem: 'Ficheiro enviado e comprimido com sucesso.', dados: media });
  } catch (erro) { next(erro); }
}

async function listarPorPeca(req, res, next) {
  try {
    const ficheiros = await MediaRepositorio.listarPorPeca(req.params.idPeca);
    res.json({ sucesso: true, dados: ficheiros });
  } catch (erro) { next(erro); }
}

async function transmitir(req, res, next) {
  try {
    const media = await MediaRepositorio.buscarPorId(req.params.id);
    if (!media) return res.status(404).json({ sucesso: false, mensagem: 'Ficheiro não encontrado.' });

    const caminho = media.caminhoComprimido || media.caminhoOriginal;

    await StreamingServico.iniciarSessaoStreaming(
      req.utilizadorAutenticado?.id || null,
      media.id, 'VOD', req.ip, req.headers['user-agent']
    );

    StreamingServico.servirStreamVOD(caminho, media.tipoMime, req, res);
  } catch (erro) { next(erro); }
}

async function transferir(req, res, next) {
  try {
    const media = await MediaRepositorio.buscarPorId(req.params.id);
    if (!media) return res.status(404).json({ sucesso: false, mensagem: 'Ficheiro não encontrado.' });
    const caminho = media.caminhoComprimido || media.caminhoOriginal;
    if (!fs.existsSync(caminho)) return res.status(404).json({ sucesso: false, mensagem: 'Ficheiro físico não encontrado.' });
    res.download(caminho, media.nomeOriginal);
  } catch (erro) { next(erro); }
}

async function eliminar(req, res, next) {
  try {
    await MediaServico.eliminarMedia(req.params.id);
    res.json({ sucesso: true, mensagem: 'Ficheiro eliminado.' });
  } catch (erro) { next(erro); }
}

module.exports = { enviarFicheiro, listarPorPeca, transmitir, transferir, eliminar };
