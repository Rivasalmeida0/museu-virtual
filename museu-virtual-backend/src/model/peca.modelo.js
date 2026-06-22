// =============================================================
//  src/model/peca.modelo.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const TABELA = 'pecas';

const CAMPOS_PUBLICOS = `p.id, p.id_exposicao AS idExposicao,
                         p.titulo, p.descricao, p.origem, p.periodo,
                         p.autor, p.etiquetas,
                         p.activa, p.criado_em AS criadaEm,
                         u.nome AS criadaPor,
                         e.titulo AS tituloExposicao`;

const QUERIES = {
  listarPorExposicao : `SELECT ${CAMPOS_PUBLICOS}
                        FROM ${TABELA} p
                        JOIN utilizadores u ON u.id = p.criado_por
                        JOIN exposicoes   e ON e.id = p.id_exposicao
                        WHERE p.id_exposicao = ? AND p.activa = 1
                        ORDER BY p.criado_em DESC`,

  buscarPorId        : `SELECT ${CAMPOS_PUBLICOS}
                        FROM ${TABELA} p
                        JOIN utilizadores u ON u.id = p.criado_por
                        JOIN exposicoes   e ON e.id = p.id_exposicao
                        WHERE p.id = ? LIMIT 1`,

  pesquisar          : `SELECT ${CAMPOS_PUBLICOS}
                        FROM ${TABELA} p
                        JOIN utilizadores u ON u.id = p.criado_por
                        JOIN exposicoes   e ON e.id = p.id_exposicao
                        WHERE p.activa = 1
                          AND MATCH(p.titulo, p.descricao, p.etiquetas)
                          AGAINST (? IN BOOLEAN MODE)
                        ORDER BY p.criado_em DESC
                        LIMIT ? OFFSET ?`,

  criar              : `INSERT INTO ${TABELA}
                        (id_exposicao, titulo, descricao, origem, periodo, autor, etiquetas, criado_por)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,

  actualizar         : `UPDATE ${TABELA}
                        SET titulo = ?, descricao = ?, origem = ?,
                            periodo = ?, autor = ?, etiquetas = ?, actualizado_em = NOW()
                        WHERE id = ?`,

  desactivar         : `UPDATE ${TABELA} SET activa = 0, actualizado_em = NOW() WHERE id = ?`,
};

module.exports = { TABELA, QUERIES };
