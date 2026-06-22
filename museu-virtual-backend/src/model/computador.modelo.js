'use strict';

const TABELA = 'computadores';

const CAMPOS_PUBLICOS = `c.id, c.nome, c.ano, c.fabricante, c.categoria,
                         c.descricao, c.curiosidade,
                         c.imagem_url AS imagemUrl,
                         c.wikipedia_url AS wikipediaUrl,
                         c.especificacoes,
                         c.criado_em AS criadoEm`;

const QUERIES = {
  listarTodos: `SELECT ${CAMPOS_PUBLICOS}
                FROM ${TABELA} c
                WHERE c.activa = 1
                ORDER BY c.ano ASC`,

  listarPorCategoria: `SELECT ${CAMPOS_PUBLICOS}
                       FROM ${TABELA} c
                       WHERE c.categoria = ? AND c.activa = 1
                       ORDER BY c.ano ASC`,

  buscarPorId: `SELECT ${CAMPOS_PUBLICOS}
                FROM ${TABELA} c
                WHERE c.id = ? AND c.activa = 1
                LIMIT 1`,

  pesquisar: `SELECT ${CAMPOS_PUBLICOS}
              FROM ${TABELA} c
              WHERE c.activa = 1
                AND (c.nome LIKE ? OR c.fabricante LIKE ? OR c.descricao LIKE ?)
              ORDER BY c.ano ASC`,

  criar: `INSERT INTO ${TABELA}
          (nome, ano, fabricante, categoria, descricao, curiosidade,
           imagem_url, wikipedia_url, especificacoes)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,

  actualizar: `UPDATE ${TABELA}
               SET nome = ?, ano = ?, fabricante = ?, categoria = ?,
                   descricao = ?, curiosidade = ?,
                   imagem_url = ?, wikipedia_url = ?, especificacoes = ?
               WHERE id = ?`,

  desactivar: `UPDATE ${TABELA} SET activa = 0 WHERE id = ?`,
};

module.exports = { TABELA, QUERIES };
