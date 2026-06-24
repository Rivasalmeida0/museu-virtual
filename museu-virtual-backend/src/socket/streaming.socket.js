'use strict';

const jwt = require('jsonwebtoken');
const salasDisponiveis = ['visita-guiada', 'apresentacao-peca', 'evento-especial'];

function configurarStreamingSocket(io) {
  io.on('connection', (socket) => {
    let salaAtual = null;
    let identidadeAtual = null;
    let papelAtual = null;

    let utilizadorAutenticado = null;
    try {
      const token = socket.handshake.auth?.token;
      if (token) {
        utilizadorAutenticado = jwt.verify(token, process.env.JWT_SECRET);
      }
    } catch (_) {}

    socket.on('join-room', ({ room, role, identity }) => {
      if (!salasDisponiveis.includes(room)) {
        socket.emit('error', { message: 'Sala não encontrada.' });
        return;
      }
      if (!role || !identity) {
        socket.emit('error', { message: 'Papel e identidade são obrigatórios.' });
        return;
      }

      if (role === 'anfitriao') {
        const funcao = utilizadorAutenticado?.funcao ?? '';
        if (funcao !== 'gestor' && funcao !== 'admin') {
          socket.emit('error', { message: 'Apenas gestores podem transmitir.' });
          return;
        }
      }

      salaAtual = room;
      identidadeAtual = identity;
      papelAtual = role;

      socket._papel = role;
      socket._identidade = identity;

      socket.join(room);

      socket.to(room).emit('user-joined', { identity, role, socketId: socket.id });

      const clients = io.sockets.adapter.rooms.get(room);
      const memberCount = clients ? clients.size : 1;

      const host = _findHost(io, room);
      const viewers = _getViewers(io, room, socket.id);

      socket.emit('room-state', {
        host: host || null,
        viewers,
        count: memberCount,
      });
    });

    socket.on('offer', ({ targetId, sdp }) => {
      socket.to(targetId).emit('offer', {
        identity: identidadeAtual,
        socketId: socket.id,
        sdp,
      });
    });

    socket.on('answer', ({ targetId, sdp }) => {
      socket.to(targetId).emit('answer', {
        identity: identidadeAtual,
        socketId: socket.id,
        sdp,
      });
    });

    socket.on('ice-candidate', ({ targetId, candidate }) => {
      socket.to(targetId).emit('ice-candidate', {
        identity: identidadeAtual,
        socketId: socket.id,
        candidate,
      });
    });

    socket.on('disconnect', () => {
      _notifyLeave(io, socket, salaAtual, identidadeAtual);
    });

    socket.on('leave-room', () => {
      _notifyLeave(io, socket, salaAtual, identidadeAtual);
      if (salaAtual) {
        socket.leave(salaAtual);
      }
      salaAtual = null;
      identidadeAtual = null;
      papelAtual = null;
    });
  });
}

function _findHost(io, room) {
  const clients = io.sockets.adapter.rooms.get(room);
  if (!clients) return null;
  for (const socketId of clients) {
    const sock = io.sockets.sockets.get(socketId);
    if (sock && sock._papel === 'anfitriao') {
      return sock._identidade;
    }
  }
  return null;
}

function _getViewers(io, room, excludeSocketId) {
  const clients = io.sockets.adapter.rooms.get(room);
  if (!clients) return [];
  const viewers = [];
  for (const socketId of clients) {
    if (socketId === excludeSocketId) continue;
    const sock = io.sockets.sockets.get(socketId);
    if (sock && sock._papel === 'viewer') {
      viewers.push({ identity: sock._identidade, socketId });
    }
  }
  return viewers;
}

function _notifyLeave(io, socket, room, identity) {
  if (room && identity) {
    socket.to(room).emit('user-left', { identity, role: socket._papel, socketId: socket.id });
    if (socket._papel === 'anfitriao') {
      socket.to(room).emit('host-disconnected');
    }
  }
}

module.exports = { configurarStreamingSocket };
