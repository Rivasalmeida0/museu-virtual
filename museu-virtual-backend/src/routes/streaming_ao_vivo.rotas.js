'use strict';

const express = require('express');
const roteador = express.Router();
const { query, queryOne } = require('../config/db');

roteador.get('/ativo', async (req, res, next) => {
  try {
    const stream = await queryOne(
      'SELECT video_id, titulo, iniciado_em FROM streaming WHERE ativo = true LIMIT 1'
    );
    if (stream) {
      res.json({ sucesso: true, ativo: true, dados: stream });
    } else {
      res.json({ sucesso: true, ativo: false });
    }
  } catch (erro) { next(erro); }
});

roteador.get('/historico', async (req, res, next) => {
  try {
    const streams = await query(
      'SELECT * FROM streaming ORDER BY iniciado_em DESC LIMIT 10'
    );
    res.json({ sucesso: true, dados: streams });
  } catch (erro) { next(erro); }
});

roteador.post('/iniciar',
  async (req, res, next) => {
    try {
      const { video_id, titulo } = req.body;
      if (!video_id) {
        return res.status(400).json({ sucesso: false, mensagem: 'video_id é obrigatório.' });
      }

      await query(
        'UPDATE streaming SET ativo = false, terminado_em = NOW() WHERE ativo = true'
      );

      const resultado = await query(
        'INSERT INTO streaming (video_id, titulo, ativo, iniciado_em) VALUES (?, ?, true, NOW())',
        [video_id, titulo || 'Visita Guiada ao Vivo']
      );

      const io = req.app.get('io');
      if (io) {
        io.emit('stream_iniciado', { video_id, titulo: titulo || 'Visita Guiada ao Vivo' });
      }

      res.json({ sucesso: true, mensagem: 'Transmissão iniciada.', id: resultado.insertId });
    } catch (erro) { next(erro); }
  }
);

roteador.post('/terminar',
  async (req, res, next) => {
    try {
      await query(
        'UPDATE streaming SET ativo = false, terminado_em = NOW() WHERE ativo = true'
      );

      const io = req.app.get('io');
      if (io) io.emit('stream_terminado', {});

      res.json({ sucesso: true, mensagem: 'Transmissão terminada.' });
    } catch (erro) { next(erro); }
  }
);

module.exports = roteador;
