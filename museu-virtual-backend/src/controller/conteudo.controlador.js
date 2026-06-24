// =============================================================
//  src/controller/conteudo.controlador.js
//  Controlador para gestão de conteúdos do museu.
//  Apenas gestores podem criar, editar, apagar e enviar imagem.
//  Listagem e detalhe são públicos.
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const path = require('path');
const ConteudoRepositorio = require('../repository/conteudo.repositorio');
const { comprimirImagem } = require('../middleware/compressao.middleware');

async function listarTodos(req, res, next) {
  try {
    const { pesquisa, categoria } = req.query;
    const dados = await ConteudoRepositorio.listarTodos(pesquisa, categoria);
    res.json({ sucesso: true, dados });
  } catch (erro) { next(erro); }
}

async function pesquisar(req, res, next) {
  try {
    const { q } = req.query;
    const dados = await ConteudoRepositorio.listarTodos(q, null);
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

    // Emitir evento de novo conteúdo para todos os clientes
    const io = req.app.get('io');
    if (io) io.emit('novo_conteudo', conteudo);

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

    const io = req.app.get('io');
    if (io) io.emit('conteudo_atualizado', conteudo);

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

    // Comprimir a imagem após upload
    const nomeBase = path.basename(req.file.filename, path.extname(req.file.filename));
    const relatorio = await comprimirImagem(req.file.path, nomeBase);

    const baseUrl = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
    const imagemUrl = `${baseUrl}/uploads/imagens_comp/${relatorio.ficheiro_final}`;

    const relatorioJson = JSON.stringify(relatorio);
    await ConteudoRepositorio.actualizarImagemComRelatorio(
      req.params.id, imagemUrl, relatorioJson
    );

    const actualizado = await ConteudoRepositorio.buscarPorId(req.params.id);

    const io = req.app.get('io');
    if (io) io.emit('conteudo_atualizado', actualizado);

    res.json({
      sucesso: true,
      mensagem: 'Imagem enviada e comprimida.',
      dados: actualizado,
      relatorio_compressao: relatorio,
    });
  } catch (erro) { next(erro); }
}

async function desactivar(req, res, next) {
  try {
    const existente = await ConteudoRepositorio.buscarPorId(req.params.id);
    if (!existente) {
      return res.status(404).json({ sucesso: false, mensagem: 'Conteúdo não encontrado.' });
    }

    await ConteudoRepositorio.desactivar(req.params.id);

    const io = req.app.get('io');
    if (io) io.emit('conteudo_apagado', { id: Number(req.params.id) });

    res.json({ sucesso: true, mensagem: 'Conteúdo removido.' });
  } catch (erro) { next(erro); }
}

module.exports = {
  listarTodos,
  pesquisar,
  obterPorId,
  criar,
  actualizar,
  uploadImagem,
  desactivar,
};
