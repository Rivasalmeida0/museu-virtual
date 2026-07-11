// =============================================================
//  run_migration.js
//  Executa o script SQL de migração VOD.
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

async function main() {
  const sqlPath = path.join(__dirname, '..', 'database', 'migration_vod.sql');
  if (!fs.existsSync(sqlPath)) {
    console.error(`Ficheiro de migração não encontrado: ${sqlPath}`);
    process.exit(1);
  }

  console.log(`Lendo o ficheiro de migração de: ${sqlPath}`);
  const sql = fs.readFileSync(sqlPath, 'utf8');

  // Permitir multiple statements para facilitar a execução da migração de uma vez
  const conexao = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 3306,
    database: process.env.DB_NAME || 'museuvirtual',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true, // Importante para rodar várias queries no mesmo script
  });

  try {
    console.log('A executar migração na base de dados...');
    await conexao.query(sql);
    console.log('✅ Migração VOD executada com sucesso!');
  } catch (error) {
    console.error('❌ Erro ao executar migração:', error.message);
    process.exit(1);
  } finally {
    await conexao.end();
  }
}

main().catch((erro) => {
  console.error('Erro geral:', erro.message);
  process.exit(1);
});
