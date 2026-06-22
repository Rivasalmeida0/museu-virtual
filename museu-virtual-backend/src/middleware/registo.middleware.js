// =============================================================
//  src/middleware/registo.middleware.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const { query } = require('../config/db');

function registarActividade(accao, entidade = null) {
  return async function (req, res, next) {
    const jsonOriginal = res.json.bind(res);

    res.json = function (corpo) {
      const idUtilizador = req.utilizadorAutenticado?.id || null;
      const idEntidade   = corpo?.dados?.id || req.params?.id || null;
      const enderecoIp   = req.ip || req.headers['x-forwarded-for'] || null;
      const metadados    = corpo?.sucesso === false ? { erro: corpo.mensagem } : null;

      query(
        `INSERT INTO registos_actividade
           (id_utilizador, accao, entidade, id_entidade, metadados, endereco_ip)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [idUtilizador, accao, entidade, idEntidade,
         metadados ? JSON.stringify(metadados) : null, enderecoIp]
      ).catch((err) => console.error('Erro ao registar actividade:', err));

      return jsonOriginal(corpo);
    };

    next();
  };
}

module.exports = { registarActividade };
