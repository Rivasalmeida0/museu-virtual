import 'package:http/http.dart' as http;

// Conditional import: usa a implementação Web ou Nativa conforme a plataforma.
// Isto é necessário porque dart:io não existe na web.
import 'http_seguro_nativo.dart'
    if (dart.library.html) 'http_seguro_web.dart'
    as platform;

/// Serviço HTTP seguro que delega para a implementação específica da plataforma.
/// - Na web: usa http.Client() simples (o browser gere o TLS)
/// - No nativo: usa IOClient com SecurityContext para mTLS
class HttpSeguroService {
  static http.Client get client => platform.HttpSeguroServicePlatform.client;

  static Future<void> inicializar() =>
      platform.HttpSeguroServicePlatform.inicializar();

  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) =>
      platform.HttpSeguroServicePlatform.get(url, headers: headers);

  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      platform.HttpSeguroServicePlatform.post(url, headers: headers, body: body);

  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      platform.HttpSeguroServicePlatform.put(url, headers: headers, body: body);

  static Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) =>
      platform.HttpSeguroServicePlatform.delete(url, headers: headers);

  /// Envia um pedido [http.BaseRequest] (ex: MultipartRequest) usando o cliente seguro
  static Future<http.StreamedResponse> send(http.BaseRequest request) =>
      platform.HttpSeguroServicePlatform.send(request);
}