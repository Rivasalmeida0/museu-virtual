class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.20.55:3000';
  static const String apiPrefix = '/api/v1';

  static const String computadores = '$apiPrefix/computadores';
  static const String computadoresHistoricos = '$apiPrefix/computadores/categoria/historico';
  static const String supercomputadores = '$apiPrefix/computadores/categoria/supercomputador';
  static const String pesquisaComputadores = '$apiPrefix/computadores/pesquisar';
  static const String streamingSalas = '$apiPrefix/streaming/salas';
  static const String streamingToken = '$apiPrefix/streaming/token';

  static const Duration timeout = Duration(seconds: 15);
}
