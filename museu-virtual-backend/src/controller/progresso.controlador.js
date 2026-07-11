// =============================================================
//  src/controller/progresso.controlador.js
//  Controlador de progresso de reprodução (Continuar a assistir)
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const ProgressoRepo = require('../repository/progresso.repositorio');

// ── GET /continuar ─────────────────────────────────────────────
async function listar(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    const itens = await ProgressoRepo.listarPorUtilizador(idUtilizador);

    res.json({ sucesso: true, total: itens.length, dados: itens });
  } catch (erro) { next(erro); }
}

// ── GET /continuar/:idConteudo ─────────────────────────────────
async function obter(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    const idConteudo = parseInt(req.params.idConteudo, 10);

    const progresso = await ProgressoRepo.buscar(idUtilizador, idConteudo);

    res.json({
      sucesso: true,
      dados: progresso || { posicao_segundos: 0, percentagem: 0 },
    });
  } catch (erro) { next(erro); }
}

// ── POST /continuar ────────────────────────────────────────────
async function guardar(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    const { idConteudo, posicaoSegundos, duracaoTotalSegundos } = req.body;

    if (!idConteudo || posicaoSegundos == null || !duracaoTotalSegundos) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'idConteudo, posicaoSegundos e duracaoTotalSegundos são obrigatórios.',
      });
    }

    await ProgressoRepo.guardar(
      idUtilizador,
      parseInt(idConteudo, 10),
      parseInt(posicaoSegundos, 10),
      parseInt(duracaoTotalSegundos, 10)
    );

    res.json({
      sucesso: true,
      mensagem: 'Progresso guardado.',
    });
  } catch (erro) { next(erro); }
}

// ── DELETE /continuar/:idConteudo ──────────────────────────────
async function remover(req, res, next) {
  try {
    const idUtilizador = req.utilizadorAutenticado.id;
    const idConteudo = parseInt(req.params.idConteudo, 10);

    await ProgressoRepo.remover(idUtilizador, idConteudo);

    res.json({
      sucesso: true,
      mensagem: 'Progresso removido.',
    });
  } catch (erro) { next(erro); }
}

module.exports = { listar, obter, guardar, remover };
