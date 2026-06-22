// =============================================================
//  src/config/db.js
//  Conexão com MySQL via pool de conexões (mysql2/promise)
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const mysql = require('mysql2/promise');

// ── Configuração do pool ──────────────────────────────────────
const pool = mysql.createPool({
  host              : process.env.DB_HOST            || 'localhost',
  port              : Number(process.env.DB_PORT)    || 3306,
  database          : process.env.DB_NAME            || 'museu_virtual',
  user              : process.env.DB_USER            || 'root',
  password          : process.env.DB_PASSWORD        || '',
  connectionLimit   : Number(process.env.DB_CONNECTION_LIMIT) || 10,

  // Garante que datas chegam como string ISO, não como objeto Date do JS
  dateStrings       : true,

  // Ativa suporte a múltiplas declarações (útil para migrations)
  multipleStatements: false,

  // Reconecta automaticamente se a ligação cair
  waitForConnections: true,
  queueLimit        : 0,

  // Charset para suportar emojis e caracteres especiais (português)
  charset           : 'utf8mb4',
});

// ── Testar a ligação ao iniciar ───────────────────────────────
async function connectDB() {
  try {
    const connection = await pool.getConnection();
    console.log(`✅  MySQL ligado — base de dados: "${process.env.DB_NAME}"`);
    connection.release(); // devolve a conexão ao pool
  } catch (error) {
    console.error('❌  Falha ao ligar ao MySQL:', error.message);
    process.exit(1); // encerra o processo se não conseguir ligar
  }
}

// ── Helper: executar query com parâmetros ─────────────────────
/**
 * Executa uma query SQL e devolve as linhas resultantes.
 *
 * @param {string}  sql    - Query SQL com placeholders (?)
 * @param {Array}   params - Valores a substituir nos placeholders
 * @returns {Promise<Array>} - Array de linhas (SELECT) ou ResultSetHeader (INSERT/UPDATE/DELETE)
 *
 * @example
 * const users = await query('SELECT * FROM users WHERE role = ?', ['admin']);
 */
async function query(sql, params = []) {
  const [rows] = await pool.execute(sql, params);
  return rows;
}

// ── Helper: obter uma única linha ────────────────────────────
/**
 * Devolve apenas a primeira linha do resultado (ou null se não existir).
 *
 * @param {string} sql
 * @param {Array}  params
 * @returns {Promise<Object|null>}
 */
async function queryOne(sql, params = []) {
  const rows = await query(sql, params);
  return rows[0] || null;
}

// ── Helper: transação ─────────────────────────────────────────
/**
 * Executa várias operações numa transação atómica.
 * Faz rollback automático em caso de erro.
 *
 * @param {Function} callback - async (connection) => { ... }
 * @returns {Promise<any>} - Valor devolvido pelo callback
 *
 * @example
 * await transaction(async (conn) => {
 *   await conn.execute('INSERT INTO exhibits ...', [...]);
 *   await conn.execute('INSERT INTO activity_logs ...', [...]);
 * });
 */
async function transaction(callback) {
  const connection = await pool.getConnection();
  await connection.beginTransaction();
  try {
    const result = await callback(connection);
    await connection.commit();
    return result;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// ── Fechar o pool (para testes ou encerramento gracioso) ──────
async function closeDB() {
  await pool.end();
  console.log('🔌  Pool MySQL encerrado.');
}

module.exports = { pool, connectDB, query, queryOne, transaction, closeDB };
