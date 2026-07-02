'use strict';

const { query, queryOne } = require('../config/db');

const SALA_LIVE = 'live-principal';

async function obterLiveAtiva() {
  return queryOne(
    'SELECT id, titulo, gestor_nome, gestor_id, iniciado_em FROM streaming WHERE ativo = true LIMIT 1'
  );
}

async function iniciarLive(titulo, gestorNome, gestorId) {
  await query(
    'UPDATE streaming SET ativo = false, terminado_em = NOW() WHERE ativo = true'
  );

  const resultado = await query(
    `INSERT INTO streaming (titulo, gestor_nome, gestor_id, ativo, iniciado_em)
     VALUES (?, ?, ?, true, NOW())`,
    [titulo || 'Visita Guiada ao Vivo', gestorNome || null, gestorId || null]
  );

  return {
    id: resultado.insertId,
    titulo: titulo || 'Visita Guiada ao Vivo',
    gestor_nome: gestorNome || null,
    gestor_id: gestorId || null,
    sala: SALA_LIVE,
  };
}

async function terminarLive() {
  await query(
    'UPDATE streaming SET ativo = false, terminado_em = NOW() WHERE ativo = true'
  );
}

function emitirLiveIniciada(io, dados) {
  if (!io) return;
  io.emit('stream_iniciado', dados);
}

function emitirLiveTerminada(io) {
  if (!io) return;
  io.emit('stream_terminado', {});
  io.to(SALA_LIVE).emit('host-disconnected');
}

module.exports = {
  SALA_LIVE,
  obterLiveAtiva,
  iniciarLive,
  terminarLive,
  emitirLiveIniciada,
  emitirLiveTerminada,
};
