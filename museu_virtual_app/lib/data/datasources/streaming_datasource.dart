import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/streaming_models.dart';

class StreamingRemoteDatasource {
  final ApiClient _client;
  IO.Socket? _socket;
  bool _connected = false;

  StreamingRemoteDatasource(this._client);

  Future<List<StreamingSala>> listarSalas() async {
    final data = await _client.get(ApiConstants.streamingSalas) as List;
    return data
        .map((j) => StreamingSala.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  IO.Socket get socket {
    _socket ??= _createSocket();
    return _socket!;
  }

  IO.Socket _createSocket() {
    final sock = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .disableAutoConnect()
          .build(),
    );
    sock.onDisconnect((_) => _connected = false);
    sock.onConnect((_) => _connected = true);
    sock.onConnectError((_) => _connected = false);
    return sock;
  }

  bool get isConnected => _connected;

  Future<void> connectAsync() async {
    if (_connected) return;
    final completer = Completer<void>();
    final sock = socket;
    sock.onConnect((_) {
      _connected = true;
      if (!completer.isCompleted) completer.complete();
    });
    sock.onConnectError((_) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Falha ao conectar ao servidor de streaming.'));
      }
    });
    sock.connect();
    await completer.future;
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _connected = false;
  }

  void joinRoom(String room, String role, String identity) {
    socket.emit('join-room', {
      'room': room,
      'role': role,
      'identity': identity,
    });
  }

  void leaveRoom(String room) {
    socket.emit('leave-room', {'room': room});
  }

  void sendOffer(String targetId, Map<String, dynamic> sdp) {
    socket.emit('offer', {'targetId': targetId, 'sdp': sdp});
  }

  void sendAnswer(String targetId, Map<String, dynamic> sdp) {
    socket.emit('answer', {'targetId': targetId, 'sdp': sdp});
  }

  void sendIceCandidate(String targetId, Map<String, dynamic> candidate) {
    socket.emit('ice-candidate', {
      'targetId': targetId,
      'candidate': candidate,
    });
  }

  void onRoomState(void Function(RoomState) callback) {
    socket.on('room-state', (dynamic data) {
      callback(RoomState.fromJson(data as Map<String, dynamic>));
    });
  }

  void onUserJoined(void Function(Map<String, dynamic>) callback) {
    socket.on('user-joined', (dynamic data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onUserLeft(void Function(Map<String, dynamic>) callback) {
    socket.on('user-left', (dynamic data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onOffer(void Function(Map<String, dynamic>) callback) {
    socket.on('offer', (dynamic data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onAnswer(void Function(Map<String, dynamic>) callback) {
    socket.on('answer', (dynamic data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onIceCandidate(void Function(Map<String, dynamic>) callback) {
    socket.on('ice-candidate', (dynamic data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onHostDisconnected(void Function() callback) {
    socket.on('host-disconnected', (_) => callback());
  }

  void onError(void Function(String) callback) {
    socket.on('error', (dynamic data) {
      callback((data as Map<String, dynamic>)['message'] as String? ?? 'Erro');
    });
  }

  void clearListeners() {
    socket.off('room-state');
    socket.off('user-joined');
    socket.off('user-left');
    socket.off('offer');
    socket.off('answer');
    socket.off('ice-candidate');
    socket.off('host-disconnected');
    socket.off('error');
  }
}
