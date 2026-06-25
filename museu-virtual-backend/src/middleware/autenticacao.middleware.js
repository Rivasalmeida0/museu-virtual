'use strict';

function verificarToken(req, res, next) {
  next();
}

function apenasAdmin(req, res, next) {
  next();
}

module.exports = { verificarToken, apenasAdmin };
