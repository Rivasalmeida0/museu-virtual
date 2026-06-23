// =============================================================
//  criar_gestor.js
//  Cria um utilizador com papel de gestor na base de dados.
//  Uso: node criar_gestor.js "Nome" "email@exemplo.com" "password"
//  Exemplo: node criar_gestor.js "Sergio Almeida" "sergio@email.com" "123456"
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

require('dotenv').config();
const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

async function main() {
  const nome = process.argv[2];
  const email = process.argv[3];
  const senha = process.argv[4];

  if (!nome || !email || !senha) {
    console.log('Uso: node criar_gestor.js "Nome" "email@exemplo.com" "password"');
    process.exit(1);
  }

  const conexao = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 3306,
    database: process.env.DB_NAME || 'museuvirtual',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
  });

  try {
    const [existentes] = await conexao.execute(
      'SELECT id FROM utilizadores WHERE email = ? LIMIT 1', [email]
    );

    if (existentes.length > 0) {
      console.log(`Já existe um utilizador com o email "${email}".`);
      return;
    }

    const hashSenha = await bcrypt.hash(senha, 12);
    await conexao.execute(
      'INSERT INTO utilizadores (nome, email, senha_hash, funcao, activo) VALUES (?, ?, ?, ?, 1)',
      [nome, email, hashSenha, 'gestor']
    );

    console.log('Gestor criado com sucesso!');
    console.log(`  Nome: ${nome}`);
    console.log(`  Email: ${email}`);
    console.log(`  Função: gestor`);
  } finally {
    await conexao.end();
  }
}

main().catch((erro) => {
  console.error('Erro:', erro.message);
  process.exit(1);
});
