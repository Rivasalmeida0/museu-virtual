// =============================================================
//  src/controller/autenticacao.controlador.js
//  Controlador de autenticação com JWT
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const AutenticacaoServico = require('../service/autenticacao.servico');

// ── POST /registar ─────────────────────────────────────────────
async function registar(req, res, next) {
  try {
    const { nome, email, senha, funcao } = req.body;
    if (!nome || !email || !senha) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Nome, email e senha são obrigatórios.',
      });
    }

    const resultado = await AutenticacaoServico.registar(nome, email, senha, funcao);

    res.status(201).json({
      sucesso: true,
      mensagem: 'Utilizador registado com sucesso.',
      dados: {
        utilizador:   resultado.utilizador,
        accessToken:  resultado.accessToken,
        refreshToken: resultado.refreshToken,
      },
    });
  } catch (erro) { next(erro); }
}

// ── POST /entrar ───────────────────────────────────────────────
async function entrar(req, res, next) {
  try {
    const { email, senha } = req.body;
    if (!email || !senha) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Email e senha são obrigatórios.',
      });
    }

    const resultado = await AutenticacaoServico.entrar(email, senha);

    res.status(200).json({
      sucesso: true,
      mensagem: 'Login efectuado com sucesso.',
      dados: {
        utilizador:   resultado.utilizador,
        accessToken:  resultado.accessToken,
        refreshToken: resultado.refreshToken,
      },
    });
  } catch (erro) { next(erro); }
}

// ── POST /renovar ──────────────────────────────────────────────
async function renovar(req, res, next) {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Refresh token é obrigatório.',
      });
    }

    const resultado = await AutenticacaoServico.renovarToken(refreshToken);

    res.status(200).json({
      sucesso: true,
      mensagem: 'Token renovado com sucesso.',
      dados: {
        utilizador:   resultado.utilizador,
        accessToken:  resultado.accessToken,
        refreshToken: resultado.refreshToken,
      },
    });
  } catch (erro) { next(erro); }
}

// ── POST /sair ─────────────────────────────────────────────────
async function sair(req, res, next) {
  try {
    const { refreshToken } = req.body;
    await AutenticacaoServico.sair(refreshToken);

    res.status(200).json({
      sucesso: true,
      mensagem: 'Sessão terminada com sucesso.',
    });
  } catch (erro) { next(erro); }
}

// ── GET /perfil ────────────────────────────────────────────────
async function perfil(req, res, next) {
  try {
    const utilizador = await AutenticacaoServico.buscarPorId(
      req.utilizadorAutenticado.id
    );

    if (!utilizador) {
      return res.status(404).json({
        sucesso: false,
        mensagem: 'Utilizador não encontrado.',
      });
    }

    res.json({ sucesso: true, dados: utilizador });
  } catch (erro) { next(erro); }
}

module.exports = { registar, entrar, renovar, sair, perfil };
