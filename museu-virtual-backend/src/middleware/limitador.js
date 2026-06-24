// =============================================================
//  src/middleware/limitador.js
//  Rate limiter middleware using express-rate-limit
// =============================================================
'use strict';

const rateLimit = require('express-rate-limit');

const limitadorGeral = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { sucesso: false, mensagem: 'Demasiados pedidos. Tente novamente mais tarde.' },
});

const limitadorAutenticacao = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { sucesso: false, mensagem: 'Demasiadas tentativas de autenticação. Tente novamente mais tarde.' },
});

const limitadorUpload = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { sucesso: false, mensagem: 'Demasiados uploads. Tente novamente mais tarde.' },
});

module.exports = { limitadorGeral, limitadorAutenticacao, limitadorUpload };
