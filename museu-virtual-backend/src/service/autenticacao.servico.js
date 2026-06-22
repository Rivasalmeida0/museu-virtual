// =============================================================
//  src/service/autenticacao.servico.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const bcrypt                = require('bcryptjs');
const jwt                   = require('jsonwebtoken');
const UtilizadorRepositorio = require('../repository/utilizador.repositorio');

const RONDAS_BCRYPT = 12;

async function registar(nome, email, senha, funcao = 'visitante') {
  const existente = await UtilizadorRepositorio.buscarPorEmail(email);
  if (existente) {
    const erro = new Error('Já existe um utilizador com este email.');
    erro.statusCode = 409;
    throw erro;
  }

  const hashSenha  = await bcrypt.hash(senha, RONDAS_BCRYPT);
  const idNovo     = await UtilizadorRepositorio.criar(nome, email, hashSenha, funcao);
  const utilizador = await UtilizadorRepositorio.buscarPorId(idNovo);

  return { utilizador, tokens: _gerarTokens(utilizador) };
}

async function entrar(email, senha) {
  const registo = await UtilizadorRepositorio.buscarPorEmail(email);

  if (!registo) {
    const erro = new Error('Email ou senha incorretos.');
    erro.statusCode = 401;
    throw erro;
  }

  if (!registo.activo) {
    const erro = new Error('Conta desactivada. Contacte o administrador.');
    erro.statusCode = 403;
    throw erro;
  }

  const senhaCorrecta = await bcrypt.compare(senha, registo.senha_hash);
  if (!senhaCorrecta) {
    const erro = new Error('Email ou senha incorretos.');
    erro.statusCode = 401;
    throw erro;
  }

  const utilizador = await UtilizadorRepositorio.buscarPorId(registo.id);
  return { utilizador, tokens: _gerarTokens(utilizador) };
}

async function renovarToken(tokenRenovacao) {
  try {
    const dados      = jwt.verify(tokenRenovacao, process.env.JWT_REFRESH_SECRET);
    const utilizador = await UtilizadorRepositorio.buscarPorId(dados.id);

    if (!utilizador) {
      const erro = new Error('Utilizador não encontrado.');
      erro.statusCode = 401;
      throw erro;
    }

    return _gerarTokens(utilizador);
  } catch {
    const erro = new Error('Token de renovação inválido ou expirado.');
    erro.statusCode = 401;
    throw erro;
  }
}

function _gerarTokens(utilizador) {
  const carga = {
    id    : utilizador.id,
    nome  : utilizador.nome,
    email : utilizador.email,
    funcao: utilizador.funcao,
  };

  const tokenAcesso = jwt.sign(carga, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '8h',
  });

  const tokenRenovacao = jwt.sign(
    { id: utilizador.id },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
  );

  return { tokenAcesso, tokenRenovacao };
}

module.exports = { registar, entrar, renovarToken };
