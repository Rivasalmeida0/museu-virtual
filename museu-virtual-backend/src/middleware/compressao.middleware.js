// =============================================================
//  src/middleware/compressao.middleware.js
//  Compressão completa de imagem, áudio e vídeo com relatório
//  Museu Virtual Interativo — ISPTEC 2026
// =============================================================

'use strict';

const sharp  = require('sharp');
const ffmpeg = require('fluent-ffmpeg');
const fs     = require('fs');
const path   = require('path');

// ─────────────────────────────────────────────────────────────
//  1. COMPRESSÃO DE IMAGEM (sharp → WebP)
// ─────────────────────────────────────────────────────────────
async function comprimirImagem(caminhoOriginal, nomeBase) {
  const tempoInicio  = Date.now();
  const tamanhoOriginal = fs.statSync(caminhoOriginal).size;
  const formatoOriginal  = path.extname(caminhoOriginal).replace('.', '').toUpperCase();

  const nomeFinal   = `${nomeBase}_comp.webp`;
  const caminhoFinal = path.join('uploads', 'imagens_comp', nomeFinal);

  await sharp(caminhoOriginal)
    .resize(1024, 1024, {
      fit: 'inside',
      withoutEnlargement: true,
    })
    .webp({ quality: 80 })
    .toFile(caminhoFinal);

  const tamanhoComprimido = fs.statSync(caminhoFinal).size;
  const tempoProcessamento = Date.now() - tempoInicio;
  const taxaCompressao = ((1 - tamanhoComprimido / tamanhoOriginal) * 100).toFixed(2);

  // Remove o original após comprimir
  fs.unlinkSync(caminhoOriginal);

  const relatorio = {
    tipo: 'imagem',
    formato_original: formatoOriginal,
    formato_final: 'WebP',
    tamanho_original_bytes: tamanhoOriginal,
    tamanho_original_legivel: formatarBytes(tamanhoOriginal),
    tamanho_comprimido_bytes: tamanhoComprimido,
    tamanho_comprimido_legivel: formatarBytes(tamanhoComprimido),
    taxa_compressao: `${taxaCompressao}%`,
    qualidade_percebida: 'Alta (80% WebP, redimensionado para max 1024px)',
    tempo_processamento_ms: tempoProcessamento,
    ficheiro_final: nomeFinal,
    caminho_final: caminhoFinal,
  };

  registarLog(relatorio);
  return relatorio;
}

// ─────────────────────────────────────────────────────────────
//  2. COMPRESSÃO DE ÁUDIO (ffmpeg → MP3 128kbps)
// ─────────────────────────────────────────────────────────────
function comprimirAudio(caminhoOriginal, nomeBase) {
  return new Promise((resolve, reject) => {
    const tempoInicio  = Date.now();
    const tamanhoOriginal = fs.statSync(caminhoOriginal).size;
    const formatoOriginal  = path.extname(caminhoOriginal).replace('.', '').toUpperCase();

    const nomeFinal   = `${nomeBase}_comp.mp3`;
    const caminhoFinal = path.join('uploads', 'audios_comp', nomeFinal);

    ffmpeg(caminhoOriginal)
      .audioCodec('libmp3lame')
      .audioBitrate('128k')
      .audioFrequency(44100)
      .audioChannels(2)
      .output(caminhoFinal)
      .on('end', () => {
        const tamanhoComprimido = fs.statSync(caminhoFinal).size;
        const tempoProcessamento = Date.now() - tempoInicio;
        const taxaCompressao = ((1 - tamanhoComprimido / tamanhoOriginal) * 100).toFixed(2);

        fs.unlinkSync(caminhoOriginal);

        const relatorio = {
          tipo: 'audio',
          formato_original: formatoOriginal,
          formato_final: 'MP3 128kbps',
          tamanho_original_bytes: tamanhoOriginal,
          tamanho_original_legivel: formatarBytes(tamanhoOriginal),
          tamanho_comprimido_bytes: tamanhoComprimido,
          tamanho_comprimido_legivel: formatarBytes(tamanhoComprimido),
          taxa_compressao: `${taxaCompressao}%`,
          qualidade_percebida: 'Boa (128kbps, 44.1kHz, estéreo)',
          tempo_processamento_ms: tempoProcessamento,
          ficheiro_final: nomeFinal,
          caminho_final: caminhoFinal,
        };

        registarLog(relatorio);
        resolve(relatorio);
      })
      .on('error', (err) => {
        reject(new Error(`Erro ao comprimir áudio: ${err.message}`));
      })
      .run();
  });
}

// ─────────────────────────────────────────────────────────────
//  3. COMPRESSÃO DE VÍDEO (ffmpeg → H.264/MP4)
// ─────────────────────────────────────────────────────────────
function comprimirVideo(caminhoOriginal, nomeBase) {
  return new Promise((resolve, reject) => {
    const tempoInicio  = Date.now();
    const tamanhoOriginal = fs.statSync(caminhoOriginal).size;
    const formatoOriginal  = path.extname(caminhoOriginal).replace('.', '').toUpperCase();

    const nomeFinal   = `${nomeBase}_comp.mp4`;
    const caminhoFinal = path.join('uploads', 'videos_comp', nomeFinal);

    ffmpeg(caminhoOriginal)
      .videoCodec('libx264')
      .audioCodec('aac')
      .videoBitrate('800k')
      .audioBitrate('128k')
      .size('1280x?')
      .autopad()
      .outputOptions([
        '-crf 23',
        '-preset fast',
        '-movflags +faststart',
      ])
      .output(caminhoFinal)
      .on('progress', (progress) => {
        if (progress.percent) {
          console.log(`[COMPRESSÃO] Vídeo: ${progress.percent.toFixed(0)}%`);
        }
      })
      .on('end', () => {
        const tamanhoComprimido = fs.statSync(caminhoFinal).size;
        const tempoProcessamento = Date.now() - tempoInicio;
        const taxaCompressao = ((1 - tamanhoComprimido / tamanhoOriginal) * 100).toFixed(2);

        fs.unlinkSync(caminhoOriginal);

        const relatorio = {
          tipo: 'video',
          formato_original: formatoOriginal,
          formato_final: 'H.264/MP4 (AAC audio)',
          tamanho_original_bytes: tamanhoOriginal,
          tamanho_original_legivel: formatarBytes(tamanhoOriginal),
          tamanho_comprimido_bytes: tamanhoComprimido,
          tamanho_comprimido_legivel: formatarBytes(tamanhoComprimido),
          taxa_compressao: `${taxaCompressao}%`,
          qualidade_percebida: 'Alta (H.264 CRF 23, 800kbps, 1280px)',
          tempo_processamento_ms: tempoProcessamento,
          ficheiro_final: nomeFinal,
          caminho_final: caminhoFinal,
        };

        registarLog(relatorio);
        resolve(relatorio);
      })
      .on('error', (err) => {
        reject(new Error(`Erro ao comprimir vídeo: ${err.message}`));
      })
      .run();
  });
}

// ─────────────────────────────────────────────────────────────
//  4. COMPRESSÃO DE VÍDEO (ffmpeg → H.265/HEVC)
// ─────────────────────────────────────────────────────────────
function comprimirVideoHevc(caminhoOriginal, nomeBase) {
  return new Promise((resolve, reject) => {
    const tempoInicio  = Date.now();
    const tamanhoOriginal = fs.statSync(caminhoOriginal).size;
    const formatoOriginal  = path.extname(caminhoOriginal).replace('.', '').toUpperCase();

    const nomeFinal   = `${nomeBase}_comp_hevc.mp4`;
    const caminhoFinal = path.join('uploads', 'videos_comp', nomeFinal);

    ffmpeg(caminhoOriginal)
      .videoCodec('libx265')
      .audioCodec('aac')
      .videoBitrate('600k')
      .audioBitrate('96k')
      .size('1280x?')
      .autopad()
      .outputOptions([
        '-crf 28',
        '-preset fast',
        '-movflags +faststart',
        '-tag:v hvc1',
      ])
      .output(caminhoFinal)
      .on('progress', (progress) => {
        if (progress.percent) {
          console.log(`[COMPRESSÃO HEVC] ${progress.percent.toFixed(0)}%`);
        }
      })
      .on('end', () => {
        const tamanhoComprimido = fs.statSync(caminhoFinal).size;
        const tempoProcessamento = Date.now() - tempoInicio;
        const taxaCompressao = ((1 - tamanhoComprimido / tamanhoOriginal) * 100).toFixed(2);

        fs.unlinkSync(caminhoOriginal);

        const relatorio = {
          tipo: 'video',
          codec: 'H.265/HEVC',
          formato_original: formatoOriginal,
          formato_final: 'H.265/MP4 (AAC audio)',
          tamanho_original_bytes: tamanhoOriginal,
          tamanho_original_legivel: formatarBytes(tamanhoOriginal),
          tamanho_comprimido_bytes: tamanhoComprimido,
          tamanho_comprimido_legivel: formatarBytes(tamanhoComprimido),
          taxa_compressao: `${taxaCompressao}%`,
          qualidade_percebida: 'Alta (H.265 CRF 28, 600kbps, 1280px)',
          tempo_processamento_ms: tempoProcessamento,
          ficheiro_final: nomeFinal,
          caminho_final: caminhoFinal,
        };

        registarLog(relatorio);
        resolve(relatorio);
      })
      .on('error', (err) => {
        reject(new Error(`Erro ao comprimir vídeo HEVC: ${err.message}`));
      })
      .run();
  });
}

// ─────────────────────────────────────────────────────────────
//  5. COMPRESSÃO DE VÍDEO (ffmpeg → VP9/WebM)
// ─────────────────────────────────────────────────────────────
function comprimirVideoVp9(caminhoOriginal, nomeBase) {
  return new Promise((resolve, reject) => {
    const tempoInicio  = Date.now();
    const tamanhoOriginal = fs.statSync(caminhoOriginal).size;
    const formatoOriginal  = path.extname(caminhoOriginal).replace('.', '').toUpperCase();

    const nomeFinal   = `${nomeBase}_comp_vp9.webm`;
    const caminhoFinal = path.join('uploads', 'videos_comp', nomeFinal);

    ffmpeg(caminhoOriginal)
      .videoCodec('libvpx-vp9')
      .audioCodec('libopus')
      .videoBitrate('500k')
      .audioBitrate('96k')
      .size('1280x?')
      .autopad()
      .outputOptions([
        '-crf 30',
        '-b:v 0',
        '-deadline good',
        '-cpu-used 2',
        '-row-mt 1',
      ])
      .output(caminhoFinal)
      .on('progress', (progress) => {
        if (progress.percent) {
          console.log(`[COMPRESSÃO VP9] ${progress.percent.toFixed(0)}%`);
        }
      })
      .on('end', () => {
        const tamanhoComprimido = fs.statSync(caminhoFinal).size;
        const tempoProcessamento = Date.now() - tempoInicio;
        const taxaCompressao = ((1 - tamanhoComprimido / tamanhoOriginal) * 100).toFixed(2);

        fs.unlinkSync(caminhoOriginal);

        const relatorio = {
          tipo: 'video',
          codec: 'VP9',
          formato_original: formatoOriginal,
          formato_final: 'VP9/WebM (Opus audio)',
          tamanho_original_bytes: tamanhoOriginal,
          tamanho_original_legivel: formatarBytes(tamanhoOriginal),
          tamanho_comprimido_bytes: tamanhoComprimido,
          tamanho_comprimido_legivel: formatarBytes(tamanhoComprimido),
          taxa_compressao: `${taxaCompressao}%`,
          qualidade_percebida: 'Alta (VP9 CRF 30, 500kbps, 1280px)',
          tempo_processamento_ms: tempoProcessamento,
          ficheiro_final: nomeFinal,
          caminho_final: caminhoFinal,
        };

        registarLog(relatorio);
        resolve(relatorio);
      })
      .on('error', (err) => {
        reject(new Error(`Erro ao comprimir vídeo VP9: ${err.message}`));
      })
      .run();
  });
}

// ─────────────────────────────────────────────────────────────
//  6. COMPRESSÃO DE ÁUDIO (ffmpeg → OGG Vorbis)
// ─────────────────────────────────────────────────────────────
function comprimirAudioOgg(caminhoOriginal, nomeBase) {
  return new Promise((resolve, reject) => {
    const tempoInicio  = Date.now();
    const tamanhoOriginal = fs.statSync(caminhoOriginal).size;
    const formatoOriginal  = path.extname(caminhoOriginal).replace('.', '').toUpperCase();

    const nomeFinal   = `${nomeBase}_comp.ogg`;
    const caminhoFinal = path.join('uploads', 'audios_comp', nomeFinal);

    ffmpeg(caminhoOriginal)
      .audioCodec('libvorbis')
      .audioBitrate('96k')
      .audioFrequency(44100)
      .audioChannels(2)
      .output(caminhoFinal)
      .on('end', () => {
        const tamanhoComprimido = fs.statSync(caminhoFinal).size;
        const tempoProcessamento = Date.now() - tempoInicio;
        const taxaCompressao = ((1 - tamanhoComprimido / tamanhoOriginal) * 100).toFixed(2);

        fs.unlinkSync(caminhoOriginal);

        const relatorio = {
          tipo: 'audio',
          codec: 'Vorbis',
          formato_original: formatoOriginal,
          formato_final: 'OGG Vorbis 96kbps',
          tamanho_original_bytes: tamanhoOriginal,
          tamanho_original_legivel: formatarBytes(tamanhoOriginal),
          tamanho_comprimido_bytes: tamanhoComprimido,
          tamanho_comprimido_legivel: formatarBytes(tamanhoComprimido),
          taxa_compressao: `${taxaCompressao}%`,
          qualidade_percebida: 'Boa (OGG Vorbis, 96kbps, 44.1kHz, estéreo)',
          tempo_processamento_ms: tempoProcessamento,
          ficheiro_final: nomeFinal,
          caminho_final: caminhoFinal,
        };

        registarLog(relatorio);
        resolve(relatorio);
      })
      .on('error', (err) => {
        reject(new Error(`Erro ao comprimir áudio OGG: ${err.message}`));
      })
      .run();
  });
}

// ─────────────────────────────────────────────────────────────
//  UTILITÁRIOS
// ─────────────────────────────────────────────────────────────
function formatarBytes(bytes) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
}

function registarLog(relatorio) {
  const linha = JSON.stringify({
    data: new Date().toISOString(),
    ...relatorio,
  }) + '\n';

  const logPath = path.join('logs', 'compressao.log');
  const logDir  = path.dirname(logPath);
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }

  fs.appendFileSync(logPath, linha);

  console.log(
    `[COMPRESSÃO] ${relatorio.tipo.toUpperCase()}: ` +
    `${relatorio.tamanho_original_legivel} → ` +
    `${relatorio.tamanho_comprimido_legivel} ` +
    `(${relatorio.taxa_compressao} redução, ` +
    `${relatorio.tempo_processamento_ms}ms)`
  );
}

module.exports = {
  comprimirImagem,
  comprimirAudio,
  comprimirVideo,
  comprimirVideoHevc,
  comprimirVideoVp9,
  comprimirAudioOgg,
};
