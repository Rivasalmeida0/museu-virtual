class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class NetworkException extends ApiException {
  const NetworkException([String message = 'Sem conexão de rede.'])
      : super(message);
}

class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Recurso não encontrado.'])
      : super(message, statusCode: 404);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'Sessão expirada. Faça login novamente.'])
      : super(message, statusCode: 401);
}

class ServerException extends ApiException {
  const ServerException([String message = 'Erro interno do servidor.'])
      : super(message, statusCode: 500);
}
