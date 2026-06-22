// =============================================================
//  src/middleware/upload.middleware.js
//  Configuração do Multer para upload de ficheiros multimédia
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const multer = require('multer');
const path   = require('path');
const fs     = require('fs');

const pastaUpload = path.join(__dirname, '../../..', process.env.UPLOAD_DIR || 'uploads');

// Garante que as subpastas existem
['imagens', 'audio', 'video', 'originais'].forEach((sub) => {
  const caminho = path.join(pastaUpload, sub);
  if (!fs.existsSync(caminho)) fs.mkdirSync(caminho, { recursive: true });
});

// ── Destino e nome do ficheiro ────────────────────────────────
const armazenamento = multer.diskStorage({
  destination(req, ficheiro, callback) {
    const subpasta =
      ficheiro.mimetype.startsWith('image/') ? 'imagens'  :
      ficheiro.mimetype.startsWith('audio/') ? 'audio'    :
      ficheiro.mimetype.startsWith('video/') ? 'video'    : 'originais';

    callback(null, path.join(pastaUpload, subpasta));
  },
  filename(req, ficheiro, callback) {
    const extensao    = path.extname(ficheiro.originalname).toLowerCase();
    const marcaTempo  = Date.now();
    const nomeSeguro  = `${marcaTempo}-${Math.round(Math.random() * 1e6)}${extensao}`;
    callback(null, nomeSeguro);
  },
});

// ── Filtro de tipos permitidos ────────────────────────────────
const tiposPermitidos = [
  'image/jpeg', 'image/png', 'image/webp', 'image/gif',
  'audio/mpeg', 'audio/aac', 'audio/ogg', 'audio/wav',
  'video/mp4',  'video/webm', 'video/ogg', 'video/x-matroska',
];

function filtrarFicheiro(req, ficheiro, callback) {
  if (tiposPermitidos.includes(ficheiro.mimetype)) {
    callback(null, true);
  } else {
    callback(
      new Error(`Tipo de ficheiro não permitido: ${ficheiro.mimetype}`),
      false
    );
  }
}

// ── Tamanho máximo ────────────────────────────────────────────
const tamanhoMaximoBytes =
  (Number(process.env.MAX_FILE_SIZE_MB) || 200) * 1024 * 1024;

// ── Instâncias do Multer ──────────────────────────────────────
const uploadUnico    = multer({ storage: armazenamento, fileFilter: filtrarFicheiro, limits: { fileSize: tamanhoMaximoBytes } }).single('ficheiro');
const uploadMultiplo = multer({ storage: armazenamento, fileFilter: filtrarFicheiro, limits: { fileSize: tamanhoMaximoBytes } }).array('ficheiros', 10);

module.exports = { uploadUnico, uploadMultiplo };
