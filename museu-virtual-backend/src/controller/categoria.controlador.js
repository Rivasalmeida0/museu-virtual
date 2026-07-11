// =============================================================
//  src/controller/categoria.controlador.js
//  Controlador de categorias VOD
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const CategoriaRepo = require('../repository/categoria.repositorio');

// ── GET /categorias ────────────────────────────────────────────
async function listar(req, res, next) {
  try {
    const categorias = await CategoriaRepo.listarTodas();
    res.json({ sucesso: true, total: categorias.length, dados: categorias });
  } catch (erro) { next(erro); }
}

// ── GET /categorias/:id ────────────────────────────────────────
async function obterPorId(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const categoria = await CategoriaRepo.buscarPorId(id);

    if (!categoria) {
      return res.status(404).json({
        sucesso: false,
        mensagem: 'Categoria não encontrada.',
      });
    }

    res.json({ sucesso: true, dados: categoria });
  } catch (erro) { next(erro); }
}

// ── GET /categorias/:id/conteudos ──────────────────────────────
async function listarConteudos(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const categoria = await CategoriaRepo.buscarPorId(id);

    if (!categoria) {
      return res.status(404).json({
        sucesso: false,
        mensagem: 'Categoria não encontrada.',
      });
    }

    const conteudos = await CategoriaRepo.listarConteudosPorCategoria(id);

    res.json({
      sucesso: true,
      categoria,
      total: conteudos.length,
      dados: conteudos,
    });
  } catch (erro) { next(erro); }
}

// ── POST /categorias ──────────────────────────────────────────
async function criar(req, res, next) {
  try {
    const { nome, descricao, icone, cor, ordem } = req.body;
    if (!nome) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Nome da categoria é obrigatório.',
      });
    }

    const id = await CategoriaRepo.criar({ nome, descricao, icone, cor, ordem });
    const categoria = await CategoriaRepo.buscarPorId(id);

    res.status(201).json({
      sucesso: true,
      mensagem: 'Categoria criada com sucesso.',
      dados: categoria,
    });
  } catch (erro) { next(erro); }
}

// ── PUT /categorias/:id ───────────────────────────────────────
async function actualizar(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const { nome, descricao, icone, cor, ordem } = req.body;

    if (!nome) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Nome da categoria é obrigatório.',
      });
    }

    await CategoriaRepo.actualizar(id, { nome, descricao, icone, cor, ordem });
    const categoria = await CategoriaRepo.buscarPorId(id);

    res.json({
      sucesso: true,
      mensagem: 'Categoria actualizada.',
      dados: categoria,
    });
  } catch (erro) { next(erro); }
}

// ── DELETE /categorias/:id ────────────────────────────────────
async function desactivar(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    await CategoriaRepo.desactivar(id);

    res.json({
      sucesso: true,
      mensagem: 'Categoria desactivada.',
    });
  } catch (erro) { next(erro); }
}

// ── POST /categorias/:id/conteudo/:idConteudo ─────────────────
async function associarConteudo(req, res, next) {
  try {
    const idCategoria = parseInt(req.params.id, 10);
    const idConteudo = parseInt(req.params.idConteudo, 10);

    await CategoriaRepo.associarConteudo(idConteudo, idCategoria);

    res.status(201).json({
      sucesso: true,
      mensagem: 'Conteúdo associado à categoria.',
    });
  } catch (erro) { next(erro); }
}

// ── DELETE /categorias/:id/conteudo/:idConteudo ───────────────
async function desassociarConteudo(req, res, next) {
  try {
    const idCategoria = parseInt(req.params.id, 10);
    const idConteudo = parseInt(req.params.idConteudo, 10);

    await CategoriaRepo.desassociarConteudo(idConteudo, idCategoria);

    res.json({
      sucesso: true,
      mensagem: 'Conteúdo desassociado da categoria.',
    });
  } catch (erro) { next(erro); }
}

module.exports = {
  listar,
  obterPorId,
  listarConteudos,
  criar,
  actualizar,
  desactivar,
  associarConteudo,
  desassociarConteudo,
};
