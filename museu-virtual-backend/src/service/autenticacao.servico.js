// =============================================================
//  src/service/autenticacao.servico.js
//  Serviço de autenticação com JWT + Refresh Token
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const crypto                = require('crypto');
const bcrypt                = require('bcryptjs');
const jwt                   = require('jsonwebtoken');
const UtilizadorRepositorio = require('../repository/utilizador.repositorio');
const RefreshTokenRepo      = require('../repository/refresh_token.repositorio');

const RONDAS_BCRYPT      = 12;
const JWT_SECRET         = process.env.JWT_SECRET     || 'museu_virtual_dev_secret_2026';
const JWT_EXPIRA_EM      = process.env.JWT_EXPIRES_IN || '15m';
const REFRESH_EXPIRA_DIAS = 7;

// ── Helpers ────────────────────────────────────────────────────

/**
 * Gera um access token JWT de curta duração.
 */
function gerarAccessToken(utilizador) {
  return jwt.sign(
    {
      id:     utilizador.id,
      email:  utilizador.email,
      funcao: utilizador.funcao || utilizador.funcao,
      nome:   utilizador.nome,
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRA_EM }
  );
}

/**
 * Gera um refresh token opaco (não é JWT — é um hash aleatório).
 */
function gerarRefreshToken() {
  return crypto.randomBytes(40).toString('hex');
}

/**
 * Calcula a data de expiração do refresh token.
 */
function calcularExpiracao() {
  const data = new Date();
  data.setDate(data.getDate() + REFRESH_EXPIRA_DIAS);
  return data;
}

// ── Registo ────────────────────────────────────────────────────

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

  // Gerar tokens
  const accessToken  = gerarAccessToken(utilizador);
  const refreshToken = gerarRefreshToken();
  const expiraEm     = calcularExpiracao();

  await RefreshTokenRepo.criar(utilizador.id, refreshToken, expiraEm);

  return { utilizador, accessToken, refreshToken };
}

// ── Login ──────────────────────────────────────────────────────

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

  // Gerar tokens
  const accessToken  = gerarAccessToken(utilizador);
  const refreshToken = gerarRefreshToken();
  const expiraEm     = calcularExpiracao();

  await RefreshTokenRepo.criar(utilizador.id, refreshToken, expiraEm);

  return { utilizador, accessToken, refreshToken };
}

// ── Renovar Token ──────────────────────────────────────────────

async function renovarToken(refreshToken) {
  const registo = await RefreshTokenRepo.buscarPorToken(refreshToken);

  if (!registo) {
    const erro = new Error('Refresh token inválido ou expirado.');
    erro.statusCode = 401;
    throw erro;
  }

  // Revogar o refresh token usado (rotação de tokens)
  await RefreshTokenRepo.revogarPorToken(refreshToken);

  const utilizador = await UtilizadorRepositorio.buscarPorId(registo.id_utilizador);
  if (!utilizador) {
    const erro = new Error('Utilizador não encontrado.');
    erro.statusCode = 404;
    throw erro;
  }

  // Gerar novos tokens
  const novoAccessToken  = gerarAccessToken(utilizador);
  const novoRefreshToken = gerarRefreshToken();
  const expiraEm         = calcularExpiracao();

  await RefreshTokenRepo.criar(utilizador.id, novoRefreshToken, expiraEm);

  return {
    utilizador,
    accessToken:  novoAccessToken,
    refreshToken: novoRefreshToken,
  };
}

// ── Logout ─────────────────────────────────────────────────────

async function sair(refreshToken) {
  if (refreshToken) {
    await RefreshTokenRepo.revogarPorToken(refreshToken);
  }
}

/**
 * Logout total — revoga todos os refresh tokens do utilizador.
 * Útil para "sair de todos os dispositivos".
 */
async function sairDeTudo(idUtilizador) {
  await RefreshTokenRepo.revogarTodosPorUtilizador(idUtilizador);
}

// ── Buscar por ID ──────────────────────────────────────────────

async function buscarPorId(id) {
  return UtilizadorRepositorio.buscarPorId(id);
}

module.exports = {
  registar,
  entrar,
  renovarToken,
  sair,
  sairDeTudo,
  buscarPorId,
};
