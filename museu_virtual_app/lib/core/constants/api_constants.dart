import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    return 'http://10.0.2.2:3000';
  }

  static String get socketUrl {
    if (kIsWeb) return 'http://localhost:3000';
    return 'http://10.0.2.2:3000';
  }

  static const String apiPrefix = '/api/v1';

  static const String computadores = '$apiPrefix/computadores';
  static const String computadoresHistoricos = '$apiPrefix/computadores/categoria/historico';
  static const String supercomputadores = '$apiPrefix/computadores/categoria/supercomputador';
  static const String pesquisaComputadores = '$apiPrefix/computadores/pesquisar';
  static const String streamingSalas = '$apiPrefix/streaming/salas';

  static const Duration timeout = Duration(seconds: 15);
}
