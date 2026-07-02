import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'api_exceptions.dart';
import '../../services/http_seguro_service.dart';

class ApiClient {
  http.Client get _client => HttpSeguroService.client;
  final String baseUrl;

  ApiClient({
    String? baseUrl,
  }) : baseUrl = baseUrl ?? ApiConstants.baseUrl;

  Future<Map<String, String>> get _headers async {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Type': 'web',
    };
  }

  Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$endpoint')
        .replace(queryParameters: queryParams);
    try {
      final response = await _client
          .get(uri, headers: await _headers)
          .timeout(ApiConstants.timeout);
      return _processResponse(response);
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client
          .post(uri, headers: await _headers, body: jsonEncode(body))
          .timeout(ApiConstants.timeout);
      return _processResponse(response);
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client
          .put(uri, headers: await _headers, body: jsonEncode(body))
          .timeout(ApiConstants.timeout);
      return _processResponse(response);
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client
          .delete(uri, headers: await _headers)
          .timeout(ApiConstants.timeout);
      return _processResponse(response);
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  dynamic _processResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['dados'] ?? body;
    }
    if (response.statusCode == 401) {
      throw UnauthorizedException(
          body['mensagem'] as String? ?? 'Sessão expirada. Faça login novamente.');
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

  void dispose() {}
}
