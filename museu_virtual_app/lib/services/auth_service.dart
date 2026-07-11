import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_exceptions.dart';
import 'http_seguro_service.dart';

/// Serviço de autenticação com suporte a JWT + Refresh Token.
/// Guarda os tokens e dados do utilizador em SharedPreferences.
class AuthService {
  static const String _userKey = 'user_data';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // ── Login ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final uri = '${ApiConstants.baseUrl}/api/v1/autenticacao/entrar';
    try {
      final response = await HttpSeguroService.post(
        uri,
        body: {'email': email, 'senha': senha},
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['sucesso'] == true) {
        final dados = body['dados'] as Map<String, dynamic>;
        final utilizador = dados['utilizador'] as Map<String, dynamic>;
        final accessToken = dados['accessToken'] as String?;
        final refreshToken = dados['refreshToken'] as String?;

        await _salvarSessao(utilizador, accessToken, refreshToken);

        return {'utilizador': utilizador};
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw ApiException(
          body['mensagem'] as String? ?? 'Email ou senha incorretos.',
          statusCode: response.statusCode,
        );
      }

      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao fazer login.',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw NetworkException(
        '${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  // ── Registo ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(
    String nome, String email, String senha,
  ) async {
    final uri = '${ApiConstants.baseUrl}/api/v1/autenticacao/registar';
    try {
      final response = await HttpSeguroService.post(
        uri,
        body: {'nome': nome, 'email': email, 'senha': senha},
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && body['sucesso'] == true) {
        final dados = body['dados'] as Map<String, dynamic>;
        final utilizador = dados['utilizador'] as Map<String, dynamic>;
        final accessToken = dados['accessToken'] as String?;
        final refreshToken = dados['refreshToken'] as String?;

        await _salvarSessao(utilizador, accessToken, refreshToken);

        return {'utilizador': utilizador};
      }

      if (response.statusCode == 409) {
        throw ApiException(
          body['mensagem'] as String? ?? 'Email já registado.',
          statusCode: 409,
        );
      }

      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao registar.',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw NetworkException(
        '${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  // ── Renovar Token ──────────────────────────────────────────────

  Future<bool> renovarToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken == null) return false;

    try {
      final uri = '${ApiConstants.baseUrl}/api/v1/autenticacao/renovar';
      final response = await HttpSeguroService.post(
        uri,
        body: {'refreshToken': refreshToken},
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['sucesso'] == true) {
        final dados = body['dados'] as Map<String, dynamic>;
        final novoAccess = dados['accessToken'] as String?;
        final novoRefresh = dados['refreshToken'] as String?;
        final utilizador = dados['utilizador'] as Map<String, dynamic>;

        await _salvarSessao(utilizador, novoAccess, novoRefresh);
        return true;
      }
    } catch (e) {
      debugPrint('[AuthService] Erro ao renovar token: $e');
    }

    return false;
  }

  // ── Logout ────────────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    final accessToken = prefs.getString(_accessTokenKey);

    // Tentar notificar o servidor (best effort)
    if (accessToken != null) {
      try {
        final uri = '${ApiConstants.baseUrl}/api/v1/autenticacao/sair';
        await HttpSeguroService.post(
          uri,
          headers: {'Authorization': 'Bearer $accessToken'},
          body: {'refreshToken': refreshToken},
        );
      } catch (_) {
        // Falha silenciosa — a sessão local é limpa de qualquer forma
      }
    }

    await prefs.remove(_userKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // ── Obter dados guardados ──────────────────────────────────────

  Future<Map<String, dynamic>?> getUtilizadorAutenticado() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData == null) return null;
    return jsonDecode(userData) as Map<String, dynamic>;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey) &&
           prefs.containsKey(_accessTokenKey);
  }

  /// Obtém o access token actual para incluir em pedidos HTTP.
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // ── Helpers privados ──────────────────────────────────────────

  Future<void> _salvarSessao(
    Map<String, dynamic> utilizador,
    String? accessToken,
    String? refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(utilizador));
    if (accessToken != null) {
      await prefs.setString(_accessTokenKey, accessToken);
    }
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }
}
