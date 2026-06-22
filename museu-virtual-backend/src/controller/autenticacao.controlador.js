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

async function renovarToken(req, res, next) {
  try {
    const { tokenRenovacao } = req.body;
    if (!tokenRenovacao) {
      return res.status(400).json({ sucesso: false, mensagem: 'Token de renovação não fornecido.' });
    }
    const tokens = await AutenticacaoServico.renovarToken(tokenRenovacao);
    res.status(200).json({ sucesso: true, dados: tokens });
  } catch (erro) { next(erro); }
}

module.exports = { registar, entrar, renovarToken };
