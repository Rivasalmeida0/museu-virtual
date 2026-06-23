// =============================================================
//  src/controller/autenticacao.controlador.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const AutenticacaoServico = require('../service/autenticacao.servico');

async function registar(req, res, next) {
  try {
    const { nome, email, senha, funcao } = req.body;
    if (!nome || !email || !senha) {
      return res.status(400).json({ sucesso: false, mensagem: 'Nome, email e senha são obrigatórios.' });
    }
    const resultado = await AutenticacaoServico.registar(nome, email, senha, funcao);
    res.status(201).json({ sucesso: true, mensagem: 'Utilizador registado com sucesso.', dados: resultado });
  } catch (erro) { next(erro); }
}

async function entrar(req, res, next) {
  try {
    const { email, senha } = req.body;
    if (!email || !senha) {
      return res.status(400).json({ sucesso: false, mensagem: 'Email e senha são obrigatórios.' });
    }
    const resultado = await AutenticacaoServico.entrar(email, senha);
    res.status(200).json({ sucesso: true, mensagem: 'Login efectuado com sucesso.', dados: resultado });
  } catch (erro) { next(erro); }
}

async function me(req, res, next) {
  try {
    const utilizador = await AutenticacaoServico.buscarPorId(req.utilizadorAutenticado.id);
    if (!utilizador) {
      return res.status(404).json({ sucesso: false, mensagem: 'Utilizador não encontrado.' });
    }
    res.status(200).json({ sucesso: true, dados: utilizador });
  } catch (erro) { next(erro); }
}

module.exports = { registar, entrar, me };
