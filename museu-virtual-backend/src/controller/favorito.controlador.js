// =============================================================
//  src/controller/favorito.controlador.js
//  Controlador de favoritos — API VOD
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const FavoritoRepo = require('../repository/favorito.repositorio');

// ── GET /favoritos ─────────────────────────────────────────────
async function listar(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    const favoritos = await FavoritoRepo.listarPorUtilizador(idUtilizador);
    const total = await FavoritoRepo.contar(idUtilizador);

    res.json({ sucesso: true, total, dados: favoritos });
  } catch (erro) { next(erro); }
}

// ── GET /favoritos/verificar/:idConteudo ───────────────────────
async function verificar(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    const idConteudo = parseInt(req.params.idConteudo, 10);

    const existe = await FavoritoRepo.verificar(idUtilizador, idConteudo);

    res.json({ sucesso: true, favorito: !!existe });
  } catch (erro) { next(erro); }
}

// ── POST /favoritos/:idConteudo ────────────────────────────────
async function adicionar(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    const idConteudo = parseInt(req.params.idConteudo, 10);

    // Verificar se já é favorito
    const existe = await FavoritoRepo.verificar(idUtilizador, idConteudo);
    if (existe) {
      return res.status(409).json({
        sucesso: false,
        mensagem: 'Este conteúdo já está nos favoritos.',
      });
    }

    await FavoritoRepo.adicionar(idUtilizador, idConteudo);

    res.status(201).json({
      sucesso: true,
      mensagem: 'Adicionado aos favoritos.',
    });
  } catch (erro) { next(erro); }
}

// ── DELETE /favoritos/:idConteudo ──────────────────────────────
async function remover(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    const idConteudo = parseInt(req.params.idConteudo, 10);

    await FavoritoRepo.remover(idUtilizador, idConteudo);

    res.json({
      sucesso: true,
      mensagem: 'Removido dos favoritos.',
    });
  } catch (erro) { next(erro); }
}

module.exports = { listar, verificar, adicionar, remover };
