// =============================================================
//  download_and_seed.js — Descarrega, comprime e guarda as imagens localmente (V3)
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const https = require('https');
const sharp = require('sharp');
const { query, closeDB } = require('../config/db');

const pageTitlesMapping = {
  'ENIAC': ['ENIAC'],
  'Apple I': ['Apple I', 'Apple-1'],
  'Commodore 64': ['Commodore 64'],
  'IBM 5150 (IBM PC)': ['IBM Personal Computer', 'IBM PC'],
  'IBM 5150': ['IBM Personal Computer', 'IBM PC'],
  'Macintosh 128K': ['Macintosh 128K'],
  'Apple Macintosh 128K': ['Macintosh 128K'],
  'Cray-1': ['Cray-1'],
  'ZX Spectrum': ['ZX Spectrum'],
  'Altair 8800': ['Altair 8800'],
  'Deep Blue': ['Deep Blue (chess computer)', 'Deep Blue'],
  'Commodore Amiga 1000': ['Amiga 1000'],
  'Amiga 1000': ['Amiga 1000'],
  'IBM System/360': ['IBM System/360'],
  'Frontier': ['Frontier (supercomputer)', 'Frontier Supercomputer'],
  'Summit': ['Summit (supercomputer)', 'Summit Supercomputer'],
  'Fugaku': ['Fugaku (supercomputer)'],
  'Aurora': ['Aurora (supercomputer)'],
  'El Capitan': ['El Capitan (supercomputer)'],
  'LUMI': ['LUMI'],
  'Sierra': ['Sierra (supercomputer)'],
  'Sunway TaihuLight': ['Sunway TaihuLight'],
  'Perlmutter': ['Perlmutter (supercomputer)'],
  'Tianhe-2 (MilkyWay-2)': ['Tianhe-2'],
  'IBM Watson': ['Watson (computer)', 'IBM Watson'],
  'Nintendo Entertainment System': ['Nintendo Entertainment System'],
  'MSX': ['MSX'],
  'Osborne 1': ['Osborne 1'],
  'Z3 (Zuse 3)': ['Z3 (computer)', 'Z3'],
  'UNIVAC I': ['UNIVAC I'],
  'TRS-80': ['TRS-80'],
  'Commodore PET': ['Commodore PET'],
  'Atari 2600': ['Atari 2600'],
  'Xerox Alto': ['Xerox Alto']
};

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function fetchWikipediaPageImageUrlSingle(title) {
  return new Promise((resolve, reject) => {
    const url = `https://en.wikipedia.org/w/api.php?action=query&prop=pageimages&titles=${encodeURIComponent(title)}&pithumbsize=1000&format=json`;
    const headers = { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36' };
    https.get(url, { headers }, (res) => {
      if (res.statusCode === 429) {
        return reject(new Error('Rate limit (429)'));
      }
      if (res.statusCode !== 200) {
        return reject(new Error(`HTTP status ${res.statusCode}`));
      }
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          const pages = parsed.query.pages;
          const pageId = Object.keys(pages)[0];
          if (pageId === '-1' || !pages[pageId].thumbnail) {
            return resolve(null);
          }
          resolve(pages[pageId].thumbnail.source);
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function fetchWikipediaPageImageUrl(titles) {
  for (const title of titles) {
    let attempts = 0;
    while (attempts < 3) {
      attempts++;
      try {
        console.log(`🔍 A tentar obter imagem de página para: ${title} (Tentativa ${attempts}/3)`);
        const url = await fetchWikipediaPageImageUrlSingle(title);
        if (url) return url;
        // If it resolved to null, it means no image exists for this title, so break and try next title
        break;
      } catch (e) {
        console.warn(`⚠️ Falha ao obter API: ${e.message}`);
        if (attempts < 3) {
          console.log('A aguardar 3 segundos antes de tentar novamente...');
          await delay(3000);
        }
      }
    }
    await delay(1000);
  }
  return null;
}

function downloadToBuffer(url) {
  return new Promise((resolve, reject) => {
    const headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept': 'image/*'
    };
    https.get(url, { headers }, (res) => {
      if (res.statusCode === 429) {
        return reject(new Error('Rate limit (429)'));
      }
      if (res.statusCode !== 200) {
        return reject(new Error(`Failed with status code ${res.statusCode}`));
      }
      const chunks = [];
      res.on('data', chunk => chunks.push(chunk));
      res.on('end', () => resolve(Buffer.concat(chunks)));
    }).on('error', reject);
  });
}

async function run() {
  const uploadDir = path.join(__dirname, '..', '..', process.env.UPLOAD_DIR || 'uploads');
  const imagensDir = path.join(uploadDir, 'imagens');

  if (!fs.existsSync(imagensDir)) {
    fs.mkdirSync(imagensDir, { recursive: true });
    console.log(`📁 Pasta criada: ${imagensDir}`);
  }

  console.log('🔌 Ligar ao banco de dados...');
  const computadores = await query('SELECT id, nome, imagem_url FROM computadores');
  console.log(`📦 Encontrados ${computadores.length} computadores na base de dados.`);

  for (const row of computadores) {
    console.log(`\n----------------------------------------`);
    console.log(`⚙️ Processar: ${row.nome}`);

    const sanitizedName = row.nome.toLowerCase().replace(/[^a-z0-9]/g, '_') + '.jpg';
    const destPath = path.join(imagensDir, sanitizedName);
    const dbPath = `/uploads/imagens/${sanitizedName}`;

    // Try fetching via page titles
    const titles = pageTitlesMapping[row.nome] || [row.nome];
    let imageUrl = await fetchWikipediaPageImageUrl(titles);

    if (!imageUrl && row.imagem_url && row.imagem_url.startsWith('http')) {
      console.log(`ℹ️ Usar URL direta da base de dados como backup: ${row.imagem_url}`);
      imageUrl = row.imagem_url;
    }

    if (!imageUrl) {
      console.warn(`❌ Não foi possível encontrar um URL válido para ${row.nome}. A usar placeholder...`);
      imageUrl = 'https://picsum.photos/800/600';
    }

    console.log(`📥 A descarregar de: ${imageUrl}`);
    let success = false;
    let attempts = 0;
    while (!success && attempts < 3) {
      attempts++;
      try {
        const imageBuffer = await downloadToBuffer(imageUrl);
        console.log(`🎨 A otimizar com Sharp...`);
        const optimizedBuffer = await sharp(imageBuffer)
          .resize({ width: 800, withoutEnlargement: true })
          .jpeg({ quality: 85 })
          .toBuffer();

        await fs.promises.writeFile(destPath, optimizedBuffer);
        console.log(`💾 Salvo em: ${destPath}`);

        console.log(`📝 Atualizar base de dados: ${dbPath}`);
        await query('UPDATE computadores SET imagem_url = ? WHERE id = ?', [dbPath, row.id]);
        success = true;
      } catch (e) {
        console.error(`⚠️ Erro (Tentativa ${attempts}/3): ${e.message}`);
        if (attempts < 3) {
          console.log('A aguardar 4 segundos antes de tentar novamente...');
          await delay(4000);
        }
      }
    }

    // Delay between records to prevent rate limiting (2.5 seconds)
    await delay(2500);
  }

  console.log('\n✅ Todos os computadores processados com sucesso!');
  await closeDB();
}

run().catch(async (e) => {
  console.error('💥 Erro fatal:', e);
  try { await closeDB(); } catch(_) {}
  process.exit(1);
});
