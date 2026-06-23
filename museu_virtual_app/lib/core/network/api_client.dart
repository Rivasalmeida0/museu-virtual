import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'api_exceptions.dart';

class ApiClient {
  final http.Client _client;
  final String baseUrl;
  final Future<String?> Function()? _tokenProvider;

  ApiClient({
    http.Client? client,
    String? baseUrl,
    Future<String?> Function()? tokenProvider,
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _tokenProvider = tokenProvider;

  Future<Map<String, String>> get _headers async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_tokenProvider != null) {
      final token = await _tokenProvider();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
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
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client
          .post(uri, headers: await _headers, body: jsonEncode(body))
          .timeout(ApiConstants.timeout);
      return _processResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client
          .put(uri, headers: await _headers, body: jsonEncode(body))
          .timeout(ApiConstants.timeout);
      return _processResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client
          .delete(uri, headers: await _headers)
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

  void dispose() => _client.close();
}
