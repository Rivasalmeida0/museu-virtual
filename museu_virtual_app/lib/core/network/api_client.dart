import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'api_exceptions.dart';

class ApiClient {
  final http.Client _client;
  final String baseUrl;

  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConstants.baseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$endpoint')
        .replace(queryParameters: queryParams);
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConstants.timeout);
      return _processResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  dynamic _processResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['dados'] ?? body;
    }
    if (response.statusCode == 404) {
      throw NotFoundException(body['mensagem'] as String? ?? 'Recurso não encontrado.');
    }
    if (response.statusCode >= 500) {
      throw ServerException(body['mensagem'] as String? ?? 'Erro interno do servidor.');
    }
    throw ApiException(
      body['mensagem'] as String? ?? 'Erro desconhecido.',
      statusCode: response.statusCode,
    );
  }

  void dispose() => _client.close();
}
