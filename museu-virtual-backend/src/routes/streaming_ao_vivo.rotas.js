'use strict';

const express = require('express');
const roteador = express.Router();
const {
  obterLiveAtiva,
  iniciarLive,
  terminarLive,
  emitirLiveIniciada,
  emitirLiveTerminada,
} = require('../service/streaming_ao_vivo.servico');

const PAPEIS_GESTOR = new Set(['gestor', 'admin']);

function _podeGerirLive(req) {
  const funcaoBody = req.body?.funcao;
  if (funcaoBody && PAPEIS_GESTOR.has(String(funcaoBody).toLowerCase())) {
    return true;
  }

  const cn = req.certificado?.cn;
  if (cn && PAPEIS_GESTOR.has(String(cn).toLowerCase())) {
    return true;
  }

  return false;
}

roteador.get('/ativo', async (req, res, next) => {
  try {
    const stream = await obterLiveAtiva();
    if (stream) {
      res.json({ sucesso: true, ativo: true, dados: stream });
    } else {
      res.json({ sucesso: true, ativo: false });
    }
  } catch (erro) {
    next(erro);
  }
});

roteador.get('/historico', async (req, res, next) => {
  try {
    const { query } = require('../config/db');
    const streams = await query(
      'SELECT id, titulo, gestor_nome, gestor_id, ativo, iniciado_em, terminado_em FROM streaming ORDER BY iniciado_em DESC LIMIT 10'
    );
    res.json({ sucesso: true, dados: streams });
  } catch (erro) {
    next(erro);
  }
});

roteador.post('/iniciar', async (req, res, next) => {
  try {
    if (!_podeGerirLive(req)) {
      return res.status(403).json({
        sucesso: false,
        mensagem: 'Apenas gestores podem iniciar uma transmissão ao vivo.',
      });
    }

    const { titulo, gestor_nome, gestor_id } = req.body;
    if (!titulo || !String(titulo).trim()) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'O título da transmissão é obrigatório.',
      });
    }

    const liveAtiva = await obterLiveAtiva();
    if (liveAtiva) {
      return res.status(409).json({
        sucesso: false,
        mensagem: 'Já existe uma transmissão ao vivo em curso.',
      });
    }

    const dados = await iniciarLive(
      String(titulo).trim(),
      gestor_nome ? String(gestor_nome).trim() : null,
      gestor_id || null
    );

    const io = req.app.get('io');
    emitirLiveIniciada(io, dados);

    res.json({
      sucesso: true,
      mensagem: 'Transmissão iniciada.',
      dados,
    });
  } catch (erro) {
    next(erro);
  }
});

roteador.post('/terminar', async (req, res, next) => {
  try {
    if (!_podeGerirLive(req)) {
      return res.status(403).json({
        sucesso: false,
        mensagem: 'Apenas gestores podem terminar a transmissão ao vivo.',
      });
    }

    await terminarLive();

    const io = req.app.get('io');
    emitirLiveTerminada(io);

    res.json({ sucesso: true, mensagem: 'Transmissão terminada.' });
  } catch (erro) {
    next(erro);
  }
});

module.exports = roteador;
