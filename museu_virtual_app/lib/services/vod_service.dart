import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import 'auth_service.dart';
import 'http_seguro_service.dart';

/// Serviço VOD — Favoritos, Histórico, Continuar a Assistir, Categorias.
/// Todos os endpoints requerem autenticação JWT.
class VodService {
  static const String _api = ApiConstants.apiPrefix;

  // ── Headers com JWT ────────────────────────────────────────────

  static Future<Map<String, String>> _headersAutenticados() async {
    final token = await AuthService.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ══════════════════════════════════════════════════════════════
  //  FAVORITOS
  // ══════════════════════════════════════════════════════════════

  /// Lista todos os favoritos do utilizador autenticado.
  static Future<List<Map<String, dynamic>>> listarFavoritos() async {
    final url = '${ApiConstants.baseUrl}$_api/favoritos';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(body['dados'] ?? []);
    }
    debugPrint('[VodService] Erro ao listar favoritos: ${response.statusCode}');
    return [];
  }

  /// Verifica se um conteúdo é favorito.
  static Future<bool> verificarFavorito(int idConteudo) async {
    final url = '${ApiConstants.baseUrl}$_api/favoritos/verificar/$idConteudo';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['favorito'] == true;
    }
    return false;
  }

  /// Adiciona um conteúdo aos favoritos.
  static Future<bool> adicionarFavorito(int idConteudo) async {
    final url = '${ApiConstants.baseUrl}$_api/favoritos/$idConteudo';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.post(url, headers: headers);

    return response.statusCode == 201;
  }

  /// Remove um conteúdo dos favoritos.
  static Future<bool> removerFavorito(int idConteudo) async {
    final url = '${ApiConstants.baseUrl}$_api/favoritos/$idConteudo';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.delete(url, headers: headers);

    return response.statusCode == 200;
  }

  // ══════════════════════════════════════════════════════════════
  //  HISTÓRICO
  // ══════════════════════════════════════════════════════════════

  /// Lista o histórico de visualizações.
  static Future<List<Map<String, dynamic>>> listarHistorico({
    int limite = 50,
  }) async {
    final url = '${ApiConstants.baseUrl}$_api/historico?limite=$limite';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(body['dados'] ?? []);
    }
    return [];
  }

  /// Regista uma visualização no histórico.
  static Future<bool> registarVisualizacao(int idConteudo) async {
    final url = '${ApiConstants.baseUrl}$_api/historico/$idConteudo';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.post(url, headers: headers);

    return response.statusCode == 201;
  }

  /// Limpa todo o histórico.
  static Future<bool> limparHistorico() async {
    final url = '${ApiConstants.baseUrl}$_api/historico';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.delete(url, headers: headers);

    return response.statusCode == 200;
  }

  /// Remove um item individual do histórico.
  static Future<bool> removerItemHistorico(int id) async {
    final url = '${ApiConstants.baseUrl}$_api/historico/$id';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.delete(url, headers: headers);

    return response.statusCode == 200;
  }

  // ══════════════════════════════════════════════════════════════
  //  CONTINUAR A ASSISTIR (progresso de reprodução)
  // ══════════════════════════════════════════════════════════════

  /// Lista conteúdos em progresso.
  static Future<List<Map<String, dynamic>>> listarProgresso() async {
    final url = '${ApiConstants.baseUrl}$_api/continuar';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(body['dados'] ?? []);
    }
    return [];
  }

  /// Obtém o progresso de um conteúdo específico.
  static Future<Map<String, dynamic>?> obterProgresso(int idConteudo) async {
    final url = '${ApiConstants.baseUrl}$_api/continuar/$idConteudo';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['dados'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Guarda a posição de reprodução.
  static Future<bool> guardarProgresso({
    required int idConteudo,
    required int posicaoSegundos,
    required int duracaoTotalSegundos,
  }) async {
    final url = '${ApiConstants.baseUrl}$_api/continuar';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.post(
      url,
      headers: headers,
      body: {
        'idConteudo': idConteudo,
        'posicaoSegundos': posicaoSegundos,
        'duracaoTotalSegundos': duracaoTotalSegundos,
      },
    );

    return response.statusCode == 200;
  }

  /// Remove o progresso de um conteúdo.
  static Future<bool> removerProgresso(int idConteudo) async {
    final url = '${ApiConstants.baseUrl}$_api/continuar/$idConteudo';
    final headers = await _headersAutenticados();
    final response = await HttpSeguroService.delete(url, headers: headers);

    return response.statusCode == 200;
  }

  // ══════════════════════════════════════════════════════════════
  //  CATEGORIAS
  // ══════════════════════════════════════════════════════════════

  /// Lista todas as categorias VOD (endpoint público).
  static Future<List<Map<String, dynamic>>> listarCategorias() async {
    final url = '${ApiConstants.baseUrl}$_api/categorias';
    final response = await HttpSeguroService.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(body['dados'] ?? []);
    }
    return [];
  }

  /// Lista os conteúdos de uma categoria.
  static Future<List<Map<String, dynamic>>> listarConteudosPorCategoria(
    int idCategoria,
  ) async {
    final url = '${ApiConstants.baseUrl}$_api/categorias/$idCategoria/conteudos';
    final response = await HttpSeguroService.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(body['dados'] ?? []);
    }
    return [];
  }
}
