// test_fav.js
require('dotenv').config();
const mysql = require('mysql2/promise');

async function main() {
  const conexao = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 3306,
    database: process.env.DB_NAME || 'museuvirtual',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
  });

  try {
    console.log('Testando insert na tabela favoritos com id_peca = 1...');
    await conexao.query('INSERT INTO favoritos (id_utilizador, id_peca) VALUES (1, 1)');
    console.log('Sucesso!');
  } catch (error) {
    console.error('ERRO:', error.message);
  } finally {
    await conexao.end();
  }
}

main().catch(console.error);
