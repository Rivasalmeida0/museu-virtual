// =============================================================
//  src/model/exposicao.modelo.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const TABELA = 'exposicoes';

const CAMPOS_PUBLICOS = `e.id, e.titulo, e.descricao, e.tema,
                         e.url_miniatura AS urlMiniatura,
                         e.activa, e.criado_em AS criadaEm,
                         u.nome AS criadaPor`;

const QUERIES = {
  listarActivas : `SELECT ${CAMPOS_PUBLICOS}
                   FROM ${TABELA} e
                   JOIN utilizadores u ON u.id = e.criado_por
                   WHERE e.activa = 1
                   ORDER BY e.criado_em DESC`,

  buscarPorId   : `SELECT ${CAMPOS_PUBLICOS}
                   FROM ${TABELA} e
                   JOIN utilizadores u ON u.id = e.criado_por
                   WHERE e.id = ? LIMIT 1`,

  criar         : `INSERT INTO ${TABELA} (titulo, descricao, tema, url_miniatura, criado_por)
                   VALUES (?, ?, ?, ?, ?)`,

  actualizar    : `UPDATE ${TABELA}
                   SET titulo = ?, descricao = ?, tema = ?,
                       url_miniatura = ?, actualizado_em = NOW()
                   WHERE id = ?`,

  desactivar    : `UPDATE ${TABELA} SET activa = 0, actualizado_em = NOW() WHERE id = ?`,

  contarPecas   : `SELECT COUNT(*) AS totalPecas FROM pecas WHERE id_exposicao = ? AND activa = 1`,
};

module.exports = { TABELA, QUERIES };
