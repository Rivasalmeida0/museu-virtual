// fix_constraints.js
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
    console.log('Alterando a tabela favoritos: dropando fk_favoritos_peca...');
    try {
      await conexao.query('ALTER TABLE favoritos DROP FOREIGN KEY fk_favoritos_peca');
      console.log('Removida fk_favoritos_peca antiga.');
    } catch (e) {
      console.log('Nota: fk_favoritos_peca antiga não existia ou já foi removida.', e.message);
    }

    console.log('Adicionando nova constraint fk_favoritos_peca apontando para computadores(id)...');
    await conexao.query(`
      ALTER TABLE favoritos 
      ADD CONSTRAINT fk_favoritos_peca 
      FOREIGN KEY (id_peca) REFERENCES computadores(id) 
      ON DELETE CASCADE ON UPDATE CASCADE
    `);
    console.log('✅ Chave estrangeira de favoritos corrigida com sucesso!');
  } catch (error) {
    console.error('❌ Erro ao corrigir chaves estrangeiras:', error.message);
  } finally {
    await conexao.end();
  }
}

main().catch(console.error);
