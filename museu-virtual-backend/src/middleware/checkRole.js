// =============================================================
//  src/middleware/checkRole.js
//  Verifica se o utilizador autenticado tem o papel (role)
//  necessário para aceder à rota.
//  Uso: router.get('/rota', verificarToken, checkRole('gestor'), handler)
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

/**
 * @param  {...string} papeis  Lista de papeis permitidos (ex: 'gestor', 'admin')
 * @returns {Function} Middleware Express
 */
function checkRole(...papeis) {
  return (req, res, next) => {
    const funcao = req.utilizadorAutenticado?.funcao;

    if (!funcao || !papeis.includes(funcao)) {
      return res.status(403).json({
        sucesso: false,
        mensagem: `Acesso restrito. Papeis necessários: ${papeis.join(', ')}.`,
      });
    }

    next();
  };
}

module.exports = { checkRole };
