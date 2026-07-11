// =============================================================
//  src/middleware/compressao.completa.middleware.js
//  Processamento multim\u00e9dia completo \u2014 todos os codecs
//  Imagens: JPEG + PNG + WebP (sharp)
//  \u00c1udio:   MP3 + AAC + OGG  (ffmpeg)
//  V\u00eddeo:   H.264 + H.265 + VP9 (ffmpeg)
//  Museu Virtual Interativo \u2014 ISPTEC 2026
// =============================================================

'use strict';

const sharp  = require('sharp');
const ffmpeg = require('fluent-ffmpeg');
const fs     = require('fs');
const path   = require('path');
const { registarLog } = require('./compressao.middleware');

// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
//  UTILIT\u00c1RIOS
// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
function formatarBytes(bytes) {
  if (bytes < 1024)           return `${bytes} B`;
  if (bytes < 1024 * 1024)   return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
}

function taxaOtimizacao(original, comprimido) {
  return ((1 - comprimido / original) * 100).toFixed(2);
}

function garantirPasta(pasta) {
  if (!fs.existsSync(pasta)) fs.mkdirSync(pasta, { recursive: true });
}

// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
//  IMAGENS \u2014 JPEG + PNG + WebP (sharp)
// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
async function processarImagem(caminhoOriginal, nomeBase) {
  const tamanhoOriginal = fs.statSync(caminhoOriginal).size;
  const formatoOriginal = path.extname(caminhoOriginal).replace('.', '').toUpperCase();
  const pastaDestino    = path.join('uploads', 'imagens_comp');
  garantirPasta(pastaDestino);

  async function gerarFormato(fmt, opcoes) {
    const nome    = `${nomeBase}_${fmt}.${fmt}`;
    const destino = path.join(pastaDestino, nome);
    const inicio  = Date.now();

    let pipe = sharp(caminhoOriginal).resize(1280, 1280, { fit: 'inside', withoutEnlargement: true });
    if (fmt === 'jpeg') pipe = pipe.jpeg({ quality: opcoes.quality });
    if (fmt === 'png')  pipe = pipe.png({ compressionLevel: 9 });
    if (fmt === 'webp') pipe = pipe.webp({ quality: opcoes.quality });
    await pipe.toFile(destino);

    const tamanhoFinal = fs.statSync(destino).size;
    const resultado = {
      codec:            fmt.toUpperCase(),
      formato_final:    fmt.toUpperCase(),
      tamanho_original: formatarBytes(tamanhoOriginal),
      tamanho_original_bytes: tamanhoOriginal,
      tamanho_final:    formatarBytes(tamanhoFinal),
      tamanho_final_bytes: tamanhoFinal,
      taxa_otimizacao:  `${taxaOtimizacao(tamanhoOriginal, tamanhoFinal)}%`,
      tempo_ms:         Date.now() - inicio,
      qualidade:        fmt === 'png' ? 'Sem perdas (lossless)' : `${opcoes.quality}% qualidade`,
      algoritmo:        fmt === 'jpeg' ? 'DCT (com perdas)' : fmt === 'png' ? 'Deflate (sem perdas)' : 'VP8L/VP8 (com perdas)',
      ficheiro:         nome,
    };

    try {
      registarLog({
        tipo: 'imagem',
        formato_original: formatoOriginal,
        formato_final: resultado.formato_final,
        tamanho_original_bytes: resultado.tamanho_original_bytes,
        tamanho_original_legivel: resultado.tamanho_original,
        tamanho_comprimido_bytes: resultado.tamanho_final_bytes,
        tamanho_comprimido_legivel: resultado.tamanho_final,
        taxa_compressao: resultado.taxa_otimizacao,
        qualidade_percebida: resultado.qualidade,
        tempo_processamento_ms: resultado.tempo_ms,
        ficheiro_final: resultado.ficheiro,
        caminho_final: destino
      });
    } catch (e) {
      console.error('Erro ao registar log de compressao (imagem):', e.message);
    }

    return resultado;
  }

  const [jpeg, png, webp] = await Promise.all([
    gerarFormato('jpeg', { quality: 85 }),
    gerarFormato('png',  {}),
    gerarFormato('webp', { quality: 80 }),
  ]);

  const variantes = [jpeg, png, webp];
  const melhor = variantes.filter(v => v.codec !== 'PNG')
    .reduce((a, b) => parseFloat(a.taxa_otimizacao) > parseFloat(b.taxa_otimizacao) ? a : b);

  return { tipo: 'imagem', formato_original: formatoOriginal, variantes, melhor: melhor.codec };
}

// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
//  \u00c1UDIO \u2014 MP3 + AAC + OGG (ffmpeg)
// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
function _audioCodec(origem, nomeBase, cfg) {
  return new Promise((resolve, reject) => {
    const pasta   = path.join('uploads', 'audios_comp');
    garantirPasta(pasta);
    const nome    = `${nomeBase}_${cfg.id}.${cfg.ext}`;
    const destino = path.join(pasta, nome);
    const inicio  = Date.now();
    const original = fs.statSync(origem).size;

    let cmd = ffmpeg(origem).audioFrequency(44100).audioChannels(2);
    if (cfg.id === 'mp3') cmd = cmd.audioCodec('libmp3lame').audioBitrate('128k');
    if (cfg.id === 'aac') cmd = cmd.audioCodec('aac').audioBitrate('128k');
    if (cfg.id === 'ogg') cmd = cmd.audioCodec('libvorbis').audioBitrate('96k');

    cmd.output(destino)
      .on('end', () => {
        const tamanhoFinal = fs.statSync(destino).size;
        const resultado = {
          codec:            cfg.label,
          formato_final:    cfg.label,
          tamanho_original: formatarBytes(original),
          tamanho_original_bytes: original,
          tamanho_final:    formatarBytes(tamanhoFinal),
          tamanho_final_bytes: tamanhoFinal,
          taxa_otimizacao:  `${taxaOtimizacao(original, tamanhoFinal)}%`,
          tempo_ms:         Date.now() - inicio,
          qualidade:        cfg.qualidade,
          algoritmo:        cfg.algoritmo,
          ficheiro:         nome,
        };

        try {
          const formatoOriginal = path.extname(origem).replace('.', '').toUpperCase();
          registarLog({
            tipo: 'audio',
            formato_original: formatoOriginal,
            formato_final: resultado.formato_final,
            tamanho_original_bytes: resultado.tamanho_original_bytes,
            tamanho_original_legivel: resultado.tamanho_original,
            tamanho_comprimido_bytes: resultado.tamanho_final_bytes,
            tamanho_comprimido_legivel: resultado.tamanho_final,
            taxa_compressao: resultado.taxa_otimizacao,
            qualidade_percebida: resultado.qualidade,
            tempo_processamento_ms: resultado.tempo_ms,
            ficheiro_final: resultado.ficheiro,
            caminho_final: destino
          });
        } catch (e) {
          console.error('Erro ao registar log de compressao (audio):', e.message);
        }

        resolve(resultado);
      })
      .on('error', (e) => reject(new Error(`${cfg.label}: ${e.message}`)))
      .run();
  });
}

async function processarAudio(caminhoOriginal, nomeBase) {
  const formatoOriginal = path.extname(caminhoOriginal).replace('.', '').toUpperCase();

  const [mp3, aac, ogg] = await Promise.all([
    _audioCodec(caminhoOriginal, nomeBase, { id: 'mp3', ext: 'mp3', label: 'MP3',  qualidade: '128kbps, 44.1kHz, est\u00e9reo', algoritmo: 'MPEG-1 Layer III (com perdas)' }),
    _audioCodec(caminhoOriginal, nomeBase, { id: 'aac', ext: 'aac', label: 'AAC',  qualidade: '128kbps, 44.1kHz, est\u00e9reo', algoritmo: 'Advanced Audio Coding (com perdas)' }),
    _audioCodec(caminhoOriginal, nomeBase, { id: 'ogg', ext: 'ogg', label: 'OGG',  qualidade: '96kbps, 44.1kHz, est\u00e9reo',  algoritmo: 'Vorbis (com perdas)' }),
  ]);

  const variantes = [mp3, aac, ogg];
  const melhor    = variantes.reduce((a, b) => parseFloat(a.taxa_otimizacao) > parseFloat(b.taxa_otimizacao) ? a : b);
  return { tipo: 'audio', formato_original: formatoOriginal, variantes, melhor: melhor.codec };
}

// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
//  V\u00cdDEO \u2014 H.264 + H.265 + VP9 (ffmpeg, sequencial para n\u00e3o sobrecarregar CPU)
// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
function _videoCodec(origem, nomeBase, cfg) {
  return new Promise((resolve, reject) => {
    const pasta   = path.join('uploads', 'videos_comp');
    garantirPasta(pasta);
    const nome    = `${nomeBase}_${cfg.id}.${cfg.ext}`;
    const destino = path.join(pasta, nome);
    const inicio  = Date.now();
    const original = fs.statSync(origem).size;

    let cmd = ffmpeg(origem).size('1280x?').autopad();
    if (cfg.id === 'h264') {
      cmd = cmd.videoCodec('libx264').audioCodec('aac').audioBitrate('128k')
        .outputOptions(['-crf 23', '-preset fast', '-movflags +faststart']);
    }
    if (cfg.id === 'h265') {
      cmd = cmd.videoCodec('libx265').audioCodec('aac').audioBitrate('96k')
        .outputOptions(['-crf 28', '-preset fast', '-movflags +faststart', '-tag:v hvc1']);
    }
    if (cfg.id === 'vp9') {
      cmd = cmd.videoCodec('libvpx-vp9').audioCodec('libopus').audioBitrate('96k')
        .outputOptions(['-crf 30', '-b:v 0', '-deadline good', '-cpu-used 2', '-row-mt 1']);
    }

    cmd.output(destino)
      .on('end', () => {
        const tamanhoFinal = fs.statSync(destino).size;
        const resultado = {
          codec:            cfg.label,
          formato_final:    cfg.label,
          tamanho_original: formatarBytes(original),
          tamanho_original_bytes: original,
          tamanho_final:    formatarBytes(tamanhoFinal),
          tamanho_final_bytes: tamanhoFinal,
          taxa_otimizacao:  `${taxaOtimizacao(original, tamanhoFinal)}%`,
          tempo_ms:         Date.now() - inicio,
          qualidade:        cfg.qualidade,
          algoritmo:        cfg.algoritmo,
          ficheiro:         nome,
        };

        try {
          const formatoOriginal = path.extname(origem).replace('.', '').toUpperCase();
          registarLog({
            tipo: 'video',
            formato_original: formatoOriginal,
            formato_final: resultado.formato_final,
            tamanho_original_bytes: resultado.tamanho_original_bytes,
            tamanho_original_legivel: resultado.tamanho_original,
            tamanho_comprimido_bytes: resultado.tamanho_final_bytes,
            tamanho_comprimido_legivel: resultado.tamanho_final,
            taxa_compressao: resultado.taxa_otimizacao,
            qualidade_percebida: resultado.qualidade,
            tempo_processamento_ms: resultado.tempo_ms,
            ficheiro_final: resultado.ficheiro,
            caminho_final: destino
          });
        } catch (e) {
          console.error('Erro ao registar log de compressao (video):', e.message);
        }

        resolve(resultado);
      })
      .on('error', (e) => reject(new Error(`${cfg.label}: ${e.message}`)))
      .run();
  });
}

async function processarVideo(caminhoOriginal, nomeBase) {
  const formatoOriginal = path.extname(caminhoOriginal).replace('.', '').toUpperCase();
  const h264 = await _videoCodec(caminhoOriginal, nomeBase, { id: 'h264', ext: 'mp4',  label: 'H.264', qualidade: 'CRF 23, preset fast', algoritmo: 'H.264/AVC \u2014 bloco DCT (com perdas)' });
  const h265 = await _videoCodec(caminhoOriginal, nomeBase, { id: 'h265', ext: 'mp4',  label: 'H.265', qualidade: 'CRF 28, preset fast', algoritmo: 'H.265/HEVC \u2014 CTU (com perdas)' });
  const vp9  = await _videoCodec(caminhoOriginal, nomeBase, { id: 'vp9',  ext: 'webm', label: 'VP9',   qualidade: 'CRF 30, good deadline', algoritmo: 'VP9 \u2014 superframe (com perdas)' });

  const variantes = [h264, h265, vp9];
  const melhor    = variantes.reduce((a, b) => parseFloat(a.taxa_otimizacao) > parseFloat(b.taxa_otimizacao) ? a : b);
  return { tipo: 'video', formato_original: formatoOriginal, variantes, melhor: melhor.codec };
}

// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
//  PROCESSAMENTO UNIFICADO
// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
async function processarTudo(ficheiros) {
  const resultado = {};
  if (ficheiros.imagem) {
    resultado.imagem = await processarImagem(ficheiros.imagem.path, ficheiros.imagem.nomeBase);
    try { fs.unlinkSync(ficheiros.imagem.path); } catch (e) {}
  }
  if (ficheiros.audio) {
    resultado.audio  = await processarAudio(ficheiros.audio.path,   ficheiros.audio.nomeBase);
    try { fs.unlinkSync(ficheiros.audio.path); } catch (e) {}
  }
  if (ficheiros.video) {
    resultado.video  = await processarVideo(ficheiros.video.path,   ficheiros.video.nomeBase);
    try { fs.unlinkSync(ficheiros.video.path); } catch (e) {}
  }
  return resultado;
}

module.exports = { processarTudo, processarImagem, processarAudio, processarVideo };
