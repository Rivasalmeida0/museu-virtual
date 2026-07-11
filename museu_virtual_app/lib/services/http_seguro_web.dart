import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<Map<String, String>> _prepararHeaders(Map<String, String>? headers) async {
    final hdrs = Map<String, String>.from(headers ?? {});
    hdrs.putIfAbsent('X-Client-Type', () => 'web');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null) {
        hdrs.putIfAbsent('Authorization', () => 'Bearer $token');
      }
    } catch (e) {
      debugPrint('[HttpSeguroService] Web: erro ao obter token: $e');
    }
    
    return hdrs;
  }

  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final hdrs = await _prepararHeaders(headers);
    return client.get(Uri.parse(url), headers: hdrs);
  }

  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final hdrs = await _prepararHeaders(headers);
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
    final hdrs = await _prepararHeaders(headers);
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
    final hdrs = await _prepararHeaders(headers);
    return client.delete(Uri.parse(url), headers: hdrs);
  }

  static Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null) {
        request.headers.putIfAbsent('Authorization', () => 'Bearer $token');
      }
    } catch (e) {
      debugPrint('[HttpSeguroService] Web: erro ao obter token no send: $e');
    }
    request.headers.putIfAbsent('X-Client-Type', () => 'web');
    return client.send(request);
  }
}
