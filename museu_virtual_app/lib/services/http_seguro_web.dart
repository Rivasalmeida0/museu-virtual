import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Implementação HTTP para Flutter Web.
/// Na web, o browser gere o TLS nativamente — não é possível usar dart:io.
/// Adicionamos o header X-Client-Type para o backend identificar o tipo de cliente.
class HttpSeguroServicePlatform {
  static http.Client? _client;

  static http.Client get client {
    _client ??= http.Client();
    return _client!;
  }

  static Future<void> inicializar() async {
    // Na web, o browser gere o TLS — não há nada a configurar
    debugPrint('[HttpSeguroService] Web: browser gere TLS nativamente');
  }

  static Map<String, String> _headersComTipo(Map<String, String>? headers) {
    final hdrs = Map<String, String>.from(headers ?? {});
    hdrs['X-Client-Type'] = 'web';
    return hdrs;
  }

  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    return client.get(Uri.parse(url), headers: _headersComTipo(headers));
  }

  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final hdrs = _headersComTipo(headers);
    hdrs.putIfAbsent('Content-Type', () => 'application/json');
    return client.post(
      Uri.parse(url),
      headers: hdrs,
      body: body is Map ? jsonEncode(body) : body,
    );
  }

  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final hdrs = _headersComTipo(headers);
    hdrs.putIfAbsent('Content-Type', () => 'application/json');
    return client.put(
      Uri.parse(url),
      headers: hdrs,
      body: body is Map ? jsonEncode(body) : body,
    );
  }

  static Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    return client.delete(Uri.parse(url), headers: _headersComTipo(headers));
  }

  static Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['X-Client-Type'] = 'web';
    return client.send(request);
  }
}
