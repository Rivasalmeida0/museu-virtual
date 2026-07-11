// =============================================================
//  src/routes/categoria.rotas.js
//  Rotas de categorias VOD
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const express      = require('express');
const roteador     = express.Router();
const Controlador  = require('../controller/categoria.controlador');
const { verificarToken }  = require('../middleware/autenticacao.middleware');
const { checkRole }       = require('../middleware/checkRole');

// Rotas públicas (leitura)
roteador.get('/',                Controlador.listar);
roteador.get('/:id',             Controlador.obterPorId);
roteador.get('/:id/conteudos',   Controlador.listarConteudos);

// Rotas protegidas (gestão — apenas gestor/admin)
roteador.post('/',
  verificarToken, checkRole('gestor', 'admin'),
  Controlador.criar
);
roteador.put('/:id',
  verificarToken, checkRole('gestor', 'admin'),
  Controlador.actualizar
);
roteador.delete('/:id',
  verificarToken, checkRole('gestor', 'admin'),
  Controlador.desactivar
);
roteador.post('/:id/conteudo/:idConteudo',
  verificarToken, checkRole('gestor', 'admin'),
  Controlador.associarConteudo
);
roteador.delete('/:id/conteudo/:idConteudo',
  verificarToken, checkRole('gestor', 'admin'),
  Controlador.desassociarConteudo
);

module.exports = roteador;
