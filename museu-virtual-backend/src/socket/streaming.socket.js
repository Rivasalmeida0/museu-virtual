'use strict';

const {
  SALA_LIVE,
  obterLiveAtiva,
  terminarLive,
  emitirLiveTerminada,
} = require('../service/streaming_ao_vivo.servico');

const PAPEIS_GESTOR = new Set(['gestor', 'admin']);

function configurarStreamingSocket(io) {
  io.on('connection', (socket) => {
    let salaAtual = null;
    let identidadeAtual = null;

    socket.on('join-room', async ({ room, role, identity, funcao }) => {
      if (room !== SALA_LIVE) {
        socket.emit('error', { message: 'Sala não encontrada.' });
        return;
      }
      if (!role || !identity) {
        socket.emit('error', { message: 'Papel e identidade são obrigatórios.' });
        return;
      }

      if (role === 'anfitriao') {
        const funcaoNormalizada = String(funcao || '').toLowerCase();
        if (!PAPEIS_GESTOR.has(funcaoNormalizada)) {
          socket.emit('error', {
            message: 'Apenas gestores podem transmitir ao vivo.',
          });
          return;
        }

        const liveAtiva = await obterLiveAtiva();
        if (!liveAtiva) {
          socket.emit('error', {
            message: 'Não existe transmissão activa. Inicie a live no painel do gestor.',
          });
          return;
        }

        const hostExistente = _findHost(io, room);
        if (hostExistente) {
          socket.emit('error', {
            message: 'Já existe um gestor a transmitir nesta live.',
          });
          return;
        }
      }

      if (role === 'viewer') {
        const liveAtiva = await obterLiveAtiva();
        if (!liveAtiva) {
          socket.emit('error', {
            message: 'Não há transmissão ao vivo disponível de momento.',
          });
          return;
        }
      }

      salaAtual = room;
      identidadeAtual = identity;

      socket._papel = role;
      socket._identidade = identity;

      socket.join(room);

      socket.to(room).emit('user-joined', { identity, role, socketId: socket.id });

      const clients = io.sockets.adapter.rooms.get(room);
      const memberCount = clients ? clients.size : 1;
      const hostInfo = _findHost(io, room);
      const viewers = _getViewers(io, room, socket.id);

      socket.emit('room-state', {
        host: hostInfo ? hostInfo.identity : null,
        hostSocketId: hostInfo ? hostInfo.socketId : null,
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

    socket.on('request-offer', ({ hostSocketId }) => {
      if (!hostSocketId) return;
      const hostSock = io.sockets.sockets.get(hostSocketId);
      if (hostSock && hostSock._papel === 'anfitriao') {
        hostSock.emit('user-joined', {
          identity: identidadeAtual,
          role: 'viewer',
          socketId: socket.id,
        });
      }
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
    });
  });
}

function _findHost(io, room) {
  const clients = io.sockets.adapter.rooms.get(room);
  if (!clients) return null;
  for (const socketId of clients) {
    const sock = io.sockets.sockets.get(socketId);
    if (sock && sock._papel === 'anfitriao') {
      return { identity: sock._identidade, socketId };
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

async function _notifyLeave(io, socket, room, identity) {
  if (!room || !identity) return;

  socket.to(room).emit('user-left', {
    identity,
    role: socket._papel,
    socketId: socket.id,
  });

  if (socket._papel === 'anfitriao') {
    socket.to(room).emit('host-disconnected');
    try {
      await terminarLive();
      emitirLiveTerminada(io);
    } catch (_) {
      // ignorar falha ao actualizar estado
    }
  }
}

module.exports = { configurarStreamingSocket, SALA_LIVE };
