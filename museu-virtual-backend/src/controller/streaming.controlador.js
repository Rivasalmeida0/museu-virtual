'use strict';

const jwt = require('jsonwebtoken');

const LIVEKIT_API_KEY = process.env.LIVEKIT_API_KEY || 'devkey';
const LIVEKIT_API_SECRET = process.env.LIVEKIT_API_SECRET || 'devsecret';
const LIVEKIT_HOST = process.env.LIVEKIT_HOST || 'http://localhost:7880';

function criarToken(roomName, identity, metadata) {
  const payload = {
    exp: Math.floor(Date.now() / 1000) + 3600,
    iat: Math.floor(Date.now() / 1000),
    nbf: Math.floor(Date.now() / 1000),
    iss: LIVEKIT_API_KEY,
    sub: identity,
    video: {
      room: roomName,
      roomJoin: true,
      canPublish: true,
      canSubscribe: true,
    },
  };
  if (metadata) payload.video.metadata = JSON.stringify(metadata);
  return jwt.sign(payload, LIVEKIT_API_SECRET, { algorithm: 'HS256' });
}

async function obterTokenSala(req, res, next) {
  try {
    const { sala: roomName } = req.params;
    const identity = req.query.identidade
      || `visitante_${Date.now()}`;
    const metadata = req.utilizadorAutenticado
      ? { nome: req.utilizadorAutenticado.nome, email: req.utilizadorAutenticado.email }
      : { tipo: 'anonimo' };

    const token = criarToken(roomName, identity, metadata);
    res.json({
      sucesso: true,
      dados: {
        token,
        host: LIVEKIT_HOST,
        sala: roomName,
        identidade: identity,
      },
    });
  } catch (erro) { next(erro); }
}

async function listarSalas(req, res, next) {
  try {
    const salas = [
      {
        id: 'visita-guiada',
        nome: 'Visita Guiada ao Museu',
        descricao: 'Tour ao vivo com curadores do museu',
        activa: true,
      },
      {
        id: 'apresentacao-peca',
        nome: 'Apresentação de Peça',
        descricao: 'Detalhes sobre uma peça específica do acervo',
        activa: true,
      },
      {
        id: 'evento-especial',
        nome: 'Evento Especial',
        descricao: 'Palestras e eventos ao vivo',
        activa: true,
      },
    ];
    res.json({ sucesso: true, dados: salas });
  } catch (erro) { next(erro); }
}

module.exports = { obterTokenSala, listarSalas };
