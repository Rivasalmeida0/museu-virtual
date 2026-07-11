// =============================================================
//  seed_vod.js
//  Associa os conteúdos existentes do museu a categorias VOD
//  para demonstração imediata.
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

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
    console.log('Populando tabela conteudo_categorias...');
    
    // Buscar todos os IDs de conteúdos (computadores) activos
    const [computadores] = await conexao.query('SELECT id, categoria FROM computadores WHERE activa = 1');
    
    // Obter as categorias VOD criadas
    const [categorias] = await conexao.query('SELECT id, nome FROM categorias_vod');
    
    const docCat = categorias.find(c => c.nome === 'Documentários');
    const tutCat = categorias.find(c => c.nome === 'Tutoriais');
    const tourCat = categorias.find(c => c.nome === 'Visitas Guiadas');
    
    if (!docCat || !tutCat || !tourCat) {
      console.log('Categorias VOD não encontradas. Certifique-se de executar a migração primeiro.');
      return;
    }

    const inserts = [];
    for (const comp of computadores) {
      // Computadores históricos vão para "Documentários"
      if (comp.categoria === 'historico') {
        inserts.push([comp.id, docCat.id]);
      } else {
        // Supercomputadores vão para "Tutoriais" e "Visitas Guiadas"
        inserts.push([comp.id, tutCat.id]);
        inserts.push([comp.id, tourCat.id]);
      }
    }

    // Inserir associações ignorando duplicados
    for (const [idConteudo, idCategoria] of inserts) {
      await conexao.query(
        'INSERT IGNORE INTO conteudo_categorias (id_conteudo, id_categoria) VALUES (?, ?)',
        [idConteudo, idCategoria]
      );
    }

    console.log('✅ Associações de categorias VOD semeadas com sucesso!');
  } catch (error) {
    console.error('❌ Erro ao semear associações:', error.message);
  } finally {
    await conexao.end();
  }
}

main().catch(console.error);
