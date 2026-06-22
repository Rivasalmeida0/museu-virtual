// =============================================================
//  src/middleware/autenticacao.middleware.js
//  Verifica o token JWT em rotas protegidas
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const jwt = require('jsonwebtoken');

/**
 * Middleware que verifica se o pedido contém um token JWT válido.
 * Injeta os dados do utilizador em req.utilizadorAutenticado.
 */
function verificarToken(req, res, next) {
  const cabecalhoAutorizacao = req.headers['authorization'];

  if (!cabecalhoAutorizacao || !cabecalhoAutorizacao.startsWith('Bearer ')) {
    return res.status(401).json({
      sucesso : false,
      mensagem: 'Token de acesso não fornecido.',
    });
  }

  const token = cabecalhoAutorizacao.split(' ')[1];

  try {
    const dadosDecodificados = jwt.verify(token, process.env.JWT_SECRET);
    req.utilizadorAutenticado = dadosDecodificados; // { id, nome, email, funcao }
    next();
  } catch (erro) {
    const mensagem =
      erro.name === 'TokenExpiredError'
        ? 'Token expirado. Faça login novamente.'
        : 'Token inválido.';

    return res.status(401).json({ sucesso: false, mensagem });
  }
}

/**
 * Middleware que verifica se o utilizador tem função de admin.
 * Deve ser usado APÓS verificarToken.
 */
function apenasAdmin(req, res, next) {
  if (req.utilizadorAutenticado?.funcao !== 'admin') {
    return res.status(403).json({
      sucesso : false,
      mensagem: 'Acesso restrito a administradores.',
    });
  }
  next();
}

module.exports = { verificarToken, apenasAdmin };
