'use strict';

const bcrypt                = require('bcryptjs');
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

  return { utilizador };
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
  return { utilizador };
}

async function buscarPorId(id) {
  return UtilizadorRepositorio.buscarPorId(id);
}

module.exports = { registar, entrar, buscarPorId };
