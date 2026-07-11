// =============================================================
//  src/middleware/autenticacao.middleware.js
//  Middleware de autenticação JWT
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const jwt    = require('jsonwebtoken');
const logger = require('./logger');

const JWT_SECRET = process.env.JWT_SECRET || 'museu_virtual_dev_secret_2026';

/**
 * Verifica se o pedido contém um token JWT válido.
 * Extrai o utilizador autenticado e coloca-o em `req.utilizadorAutenticado`.
 */
function verificarToken(req, res, next) {
  const cabecalho = req.headers['authorization'];

  if (!cabecalho || !cabecalho.startsWith('Bearer ')) {
    return res.status(401).json({
      sucesso: false,
      mensagem: 'Token de autenticação não fornecido.',
    });
  }

  const token = cabecalho.split(' ')[1];

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.utilizadorAutenticado = {
      id:     payload.id,
      email:  payload.email,
      funcao: payload.funcao,
      nome:   payload.nome,
    };
    next();
  } catch (erro) {
    if (erro.name === 'TokenExpiredError') {
      return res.status(401).json({
        sucesso: false,
        mensagem: 'Token expirado. Renove o seu token.',
        codigo: 'TOKEN_EXPIRADO',
      });
    }

    logger.warn(`Token JWT inválido: ${erro.message}`);
    return res.status(401).json({
      sucesso: false,
      mensagem: 'Token de autenticação inválido.',
    });
  }
}

/**
 * Verifica se o utilizador autenticado tem papel de admin.
 * Deve ser usado APÓS `verificarToken`.
 */
function apenasAdmin(req, res, next) {
  if (!req.utilizadorAutenticado) {
    return res.status(401).json({
      sucesso: false,
      mensagem: 'Autenticação necessária.',
    });
  }

  if (req.utilizadorAutenticado.funcao !== 'admin') {
    return res.status(403).json({
      sucesso: false,
      mensagem: 'Acesso restrito a administradores.',
    });
  }

  next();
}

/**
 * Middleware opcional — se houver token, extrai o utilizador;
 * se não houver, permite passar sem autenticação.
 * Útil para rotas públicas que mostram conteúdo diferente se autenticado.
 */
function tokenOpcional(req, res, next) {
  const cabecalho = req.headers['authorization'];

  if (!cabecalho || !cabecalho.startsWith('Bearer ')) {
    req.utilizadorAutenticado = null;
    return next();
  }

  const token = cabecalho.split(' ')[1];

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.utilizadorAutenticado = {
      id:     payload.id,
      email:  payload.email,
      funcao: payload.funcao,
      nome:   payload.nome,
    };
  } catch (_) {
    req.utilizadorAutenticado = null;
  }

  next();
}

module.exports = { verificarToken, apenasAdmin, tokenOpcional };
