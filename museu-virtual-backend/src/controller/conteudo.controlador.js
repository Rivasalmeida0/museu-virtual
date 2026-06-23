// =============================================================
//  src/controller/conteudo.controlador.js
//  Controlador para gestão de conteúdos do museu.
//  Apenas gestores podem criar, editar, apagar e enviar imagem.
//  Listagem e detalhe são públicos.
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const ConteudoRepositorio = require('../repository/conteudo.repositorio');
const path = require('path');

async function listarTodos(req, res, next) {
  try {
    const dados = await ConteudoRepositorio.listarTodos();
    res.json({ sucesso: true, dados });
  } catch (erro) { next(erro); }
}

async function obterPorId(req, res, next) {
  try {
    const conteudo = await ConteudoRepositorio.buscarPorId(req.params.id);
    if (!conteudo) {
      return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });
    }
    res.json({ sucesso: true, dados: conteudo });
  } catch (erro) { next(erro); }
}

async function criar(req, res, next) {
  try {
    const { nome } = req.body;
    if (!nome) {
      return res.status(400).json({ sucesso: false, mensagem: 'Nome é obrigatório.' });
    }

    const idNovo = await ConteudoRepositorio.criar(req.body);
    const conteudo = await ConteudoRepositorio.buscarPorId(idNovo);
    res.status(201).json({ sucesso: true, mensagem: 'Conteúdo criado.', dados: conteudo });
  } catch (erro) { next(erro); }
}

async function actualizar(req, res, next) {
  try {
    const existente = await ConteudoRepositorio.buscarPorId(req.params.id);
    if (!existente) {
      return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });
    }

    await ConteudoRepositorio.actualizar(req.params.id, req.body);
    const conteudo = await ConteudoRepositorio.buscarPorId(req.params.id);
    res.json({ sucesso: true, mensagem: 'Conteúdo actualizado.', dados: conteudo });
  } catch (erro) { next(erro); }
}

async function uploadImagem(req, res, next) {
  try {
    const conteudo = await ConteudoRepositorio.buscarPorId(req.params.id);
    if (!conteudo) {
      return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });
    }

    if (!req.file) {
      return res.status(400).json({ sucesso: false, mensagem: 'Nenhuma imagem enviada.' });
    }

    // Caminho relativo para servir via static
    const caminhoRelativo = `/uploads/imagens/${req.file.filename}`;
    await ConteudoRepositorio.actualizarImagem(req.params.id, caminhoRelativo);

    const actualizado = await ConteudoRepositorio.buscarPorId(req.params.id);
    res.json({ sucesso: true, mensagem: 'Imagem enviada.', dados: actualizado });
  } catch (erro) { next(erro); }
}

async function desactivar(req, res, next) {
  try {
    const existente = await ConteudoRepositorio.buscarPorId(req.params.id);
    if (!existente) {
      return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });
    }

    await ConteudoRepositorio.desactivar(req.params.id);
    res.json({ sucesso: true, mensagem: 'Conteúdo removido.' });
  } catch (erro) { next(erro); }
}

module.exports = {
  listarTodos,
  obterPorId,
  criar,
  actualizar,
  uploadImagem,
  desactivar,
};
