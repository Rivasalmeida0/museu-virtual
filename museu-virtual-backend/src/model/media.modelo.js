// =============================================================
//  src/model/media.modelo.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const TABELA = 'ficheiros_media';

const CAMPOS_PUBLICOS = `m.id, m.id_peca AS idPeca,
                         m.tipo, m.tipo_mime AS tipoMime,
                         m.nome_original AS nomeOriginal,
                         m.caminho_original AS caminhoOriginal,
                         m.caminho_comprimido AS caminhoComprimido,
                         m.tamanho_original AS tamanhoOriginal,
                         m.tamanho_comprimido AS tamanhoComprimido,
                         m.largura_px AS largura, m.altura_px AS altura,
                         m.duracao_segundos AS duracaoSegundos,
                         m.principal, m.criado_em AS criadoEm,
                         u.nome AS enviadoPor`;

const QUERIES = {
  listarPorPeca  : `SELECT ${CAMPOS_PUBLICOS}
                    FROM ${TABELA} m
                    JOIN utilizadores u ON u.id = m.id_enviador
                    WHERE m.id_peca = ?
                    ORDER BY m.principal DESC, m.criado_em ASC`,

  buscarPorId    : `SELECT ${CAMPOS_PUBLICOS}
                    FROM ${TABELA} m
                    JOIN utilizadores u ON u.id = m.id_enviador
                    WHERE m.id = ? LIMIT 1`,

  criar          : `INSERT INTO ${TABELA}
                    (id_peca, id_enviador, tipo, tipo_mime, nome_original,
                     caminho_original, caminho_comprimido,
                     tamanho_original, tamanho_comprimido,
                     largura_px, altura_px, duracao_segundos, principal)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,

  actualizarComprimido :
                   `UPDATE ${TABELA}
                    SET caminho_comprimido = ?, tamanho_comprimido = ?
                    WHERE id = ?`,

  eliminar       : `DELETE FROM ${TABELA} WHERE id = ?`,
};

module.exports = { TABELA, QUERIES };
