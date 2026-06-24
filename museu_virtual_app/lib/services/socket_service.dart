import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;

  static final SocketService _instancia = SocketService._interno();
  factory SocketService() => _instancia;
  SocketService._interno();

  bool get ligado => _socket?.connected ?? false;

  void iniciar(String baseUrl) {
    if (_socket != null) return;

    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      debugPrint('Socket ligado: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket desligado');
    });

    _socket!.onError((erro) {
      debugPrint('Socket erro: $erro');
    });
  }

  void ouvir(String evento, dynamic Function(dynamic data) callback) {
    _socket?.on(evento, callback);
  }

  void removerOuvinte(String evento) {
    _socket?.off(evento);
  }

  void desligar() {
    _socket?.disconnect();
    _socket = null;
  }
}
