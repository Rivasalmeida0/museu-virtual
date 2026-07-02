import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  /// URL base da API.
  /// - Web: usa HTTP na porta 3001 (servidor HTTP de desenvolvimento)
  ///   porque o browser não consegue usar os certificados mTLS auto-assinados.
  /// - Mobile: usa HTTPS com mTLS (certificados carregados pelo HttpSeguroService).
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3001';
    return 'http://192.168.20.77:3001';
  }

  static String get socketUrl {
    if (kIsWeb) return 'http://localhost:3001';
    return 'http://192.168.20.77:3001';
  }

  static const String apiPrefix = '/api/v1';

  static const String computadores = '$apiPrefix/computadores';
  static const String computadoresHistoricos = '$apiPrefix/computadores/categoria/historico';
  static const String supercomputadores = '$apiPrefix/computadores/categoria/supercomputador';
  static const String pesquisaComputadores = '$apiPrefix/computadores/pesquisar';
  static const String streamingSalas = '$apiPrefix/streaming/salas';
  static const String streamingAoVivo = '$apiPrefix/streaming-ao-vivo';
  static const String liveRoomId = 'live-principal';

  static const Duration timeout = Duration(seconds: 15);
}
