import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Implementação HTTP para plataformas nativas (Android/iOS/Desktop).
/// Usa dart:io com SecurityContext para mTLS (certificado de cliente).
class HttpSeguroServicePlatform {
  static IOClient? _secureClient;

  static http.Client get client {
    if (_secureClient != null) return _secureClient!;
    // Fallback sem mTLS (aceita certificados auto-assinados)
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        debugPrint('[CERT-FALLBACK] Aceite: ${cert.subject} | Host: $host:$port');
        return true;
      };
    return IOClient(httpClient);
  }

  static Future<void> inicializar() async {
    try {
      final caBytes = await rootBundle.load('assets/certs/ca.crt');
      final clienteCertBytes = await rootBundle.load('assets/certs/utilizador.crt');
      final clienteKeyBytes = await rootBundle.load('assets/certs/utilizador.key');

      final contextoSeguranca = SecurityContext(withTrustedRoots: false);

      contextoSeguranca.setTrustedCertificatesBytes(
        caBytes.buffer.asUint8List(),
      );
      contextoSeguranca.useCertificateChainBytes(
        clienteCertBytes.buffer.asUint8List(),
      );
      contextoSeguranca.usePrivateKeyBytes(
        clienteKeyBytes.buffer.asUint8List(),
      );

      final httpClient = HttpClient(context: contextoSeguranca)
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          debugPrint('[CERT] Aceite: ${cert.subject} | Host: $host:$port');
          return true;
        }
        ..connectionTimeout = const Duration(seconds: 10);

      _secureClient = IOClient(httpClient);

      debugPrint('[HttpSeguroService] mTLS inicializado com sucesso');
    } catch (e) {
      debugPrint('[HttpSeguroService] Erro ao inicializar mTLS: $e');
      _secureClient = null;
    }
  }

  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final hdrs = Map<String, String>.from(headers ?? {});
    hdrs.putIfAbsent('X-Client-Type', () => 'web');
    return client.get(Uri.parse(url), headers: hdrs);
  }

  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final hdrs = Map<String, String>.from(headers ?? {});
    hdrs.putIfAbsent('Content-Type', () => 'application/json');
    hdrs.putIfAbsent('X-Client-Type', () => 'web');
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
    final hdrs = Map<String, String>.from(headers ?? {});
    hdrs.putIfAbsent('Content-Type', () => 'application/json');
    hdrs.putIfAbsent('X-Client-Type', () => 'web');
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
    final hdrs = Map<String, String>.from(headers ?? {});
    hdrs.putIfAbsent('X-Client-Type', () => 'web');
    return client.delete(Uri.parse(url), headers: hdrs);
  }

  static Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return client.send(request);
  }
}
