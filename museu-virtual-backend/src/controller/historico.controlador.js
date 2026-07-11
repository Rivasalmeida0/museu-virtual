// =============================================================
//  src/controller/historico.controlador.js
//  Controlador de histórico de visualizações — API VOD
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const HistoricoRepo = require('../repository/historico.repositorio');

// ── GET /historico ─────────────────────────────────────────────
async function listar(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    const limite = parseInt(req.query.limite, 10) || 50;

    const historico = await HistoricoRepo.listarPorUtilizador(
      idUtilizador, Math.min(limite, 100)
    );

    res.json({ sucesso: true, total: historico.length, dados: historico });
  } catch (erro) { next(erro); }
}

// ── POST /historico/:idConteudo ────────────────────────────────
async function registar(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    const idConteudo = parseInt(req.params.idConteudo, 10);

    await HistoricoRepo.registar(idUtilizador, idConteudo);

    res.status(201).json({
      sucesso: true,
      mensagem: 'Registado no histórico.',
    });
  } catch (erro) { next(erro); }
}

// ── DELETE /historico ──────────────────────────────────────────
async function limpar(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    await HistoricoRepo.limparPorUtilizador(idUtilizador);

    res.json({
      sucesso: true,
      mensagem: 'Histórico limpo com sucesso.',
    });
  } catch (erro) { next(erro); }
}

// ── DELETE /historico/:id ──────────────────────────────────────
async function removerItem(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    const id = parseInt(req.params.id, 10);

    await HistoricoRepo.removerItem(id, idUtilizador);

    res.json({
      sucesso: true,
      mensagem: 'Item removido do histórico.',
    });
  } catch (erro) { next(erro); }
}

module.exports = { listar, registar, limpar, removerItem };
