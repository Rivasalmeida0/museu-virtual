// =============================================================
//  src/model/utilizador.modelo.js
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================
'use strict';

const TABELA = 'utilizadores';

const CAMPOS_PUBLICOS = `id, nome, email, funcao, url_avatar AS urlAvatar,
                         biografia, activo, criado_em AS criadoEm`;

const QUERIES = {
  buscarPorEmail : `SELECT * FROM ${TABELA} WHERE email = ? LIMIT 1`,
  buscarPorId    : `SELECT ${CAMPOS_PUBLICOS} FROM ${TABELA} WHERE id = ? LIMIT 1`,
  listarTodos    : `SELECT ${CAMPOS_PUBLICOS} FROM ${TABELA} ORDER BY criado_em DESC`,
  criar          : `INSERT INTO ${TABELA} (nome, email, senha_hash, funcao) VALUES (?, ?, ?, ?)`,
  actualizar     : `UPDATE ${TABELA} SET nome = ?, biografia = ?, url_avatar = ?, actualizado_em = NOW() WHERE id = ?`,
  alterarSenha   : `UPDATE ${TABELA} SET senha_hash = ?, actualizado_em = NOW() WHERE id = ?`,
  desactivar     : `UPDATE ${TABELA} SET activo = 0, actualizado_em = NOW() WHERE id = ?`,
};

module.exports = { TABELA, CAMPOS_PUBLICOS, QUERIES };
