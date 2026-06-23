'use strict';

const SALAS = [
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

async function listarSalas(req, res, next) {
  try {
    res.json({ sucesso: true, dados: SALAS });
  } catch (erro) { next(erro); }
}

module.exports = { listarSalas };
