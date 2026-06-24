// =============================================================
//  src/model/conteudo.modelo.js
//  Reutiliza a tabela `computadores` para gerir conteúdos
//  do museu (peças / computadores históricos).
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const TABELA = 'computadores';

const CAMPOS_PUBLICOS = `c.id, c.nome, c.ano, c.fabricante, c.categoria,
                         c.descricao, c.curiosidade,
                         c.imagem_url AS imagemUrl,
                         c.audio_url AS audioUrl,
                         c.video_url AS videoUrl,
                         c.relatorio_compressao AS relatorioCompressao,
                         c.wikipedia_url AS wikipediaUrl,
                         c.criado_em AS criadoEm,
                         c.actualizado_em AS actualizadoEm`;

const QUERIES = {
  listarTodos: `SELECT ${CAMPOS_PUBLICOS}
                FROM ${TABELA} c
                WHERE c.activa = 1
                ORDER BY c.criado_em DESC`,

  buscarPorId: `SELECT ${CAMPOS_PUBLICOS}
                FROM ${TABELA} c
                WHERE c.id = ? AND c.activa = 1
                LIMIT 1`,

  criar: `INSERT INTO ${TABELA}
          (nome, ano, fabricante, categoria, descricao, curiosidade, wikipedia_url)
          VALUES (?, ?, ?, ?, ?, ?, ?)`,

  actualizar: `UPDATE ${TABELA}
               SET nome = ?, ano = ?, fabricante = ?, categoria = ?,
                   descricao = ?, curiosidade = ?, wikipedia_url = ?
               WHERE id = ?`,

  actualizarImagem: `UPDATE ${TABELA} SET imagem_url = ? WHERE id = ?`,

  actualizarImagemComRelatorio: `UPDATE ${TABELA} SET imagem_url = ?, relatorio_compressao = ? WHERE id = ?`,

  actualizarAudioComRelatorio: `UPDATE ${TABELA} SET audio_url = ?, relatorio_compressao = ? WHERE id = ?`,

  actualizarVideoComRelatorio: `UPDATE ${TABELA} SET video_url = ?, relatorio_compressao = ? WHERE id = ?`,

  desactivar: `UPDATE ${TABELA} SET activa = 0 WHERE id = ?`,
};

module.exports = { TABELA, QUERIES };
