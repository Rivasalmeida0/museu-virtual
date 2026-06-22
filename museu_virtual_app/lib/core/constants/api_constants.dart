class ApiConstants {
  ApiConstants._();

  // Android emulator -> 10.0.2.2
  // iOS simulator   -> localhost
  // Dispositivo físico -> IP do teu computador (ex: 192.168.1.100)
  // Web             -> localhost
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String apiPrefix = '/api/v1';

  static const String computadores = '$apiPrefix/computadores';
  static const String computadoresHistoricos = '$apiPrefix/computadores/categoria/historico';
  static const String supercomputadores = '$apiPrefix/computadores/categoria/supercomputador';
  static const String pesquisaComputadores = '$apiPrefix/computadores/pesquisar';
  static const String streamingSalas = '$apiPrefix/streaming/salas';
  static const String streamingToken = '$apiPrefix/streaming/token';

  static const Duration timeout = Duration(seconds: 15);
}
