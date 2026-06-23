import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_exceptions.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/autenticacao/entrar');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'senha': senha}),
          )
          .timeout(ApiConstants.timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['sucesso'] == true) {
        final dados = body['dados'] as Map<String, dynamic>;
        final token = dados['token'] as Map<String, dynamic>;
        final tokenAcesso = token['tokenAcesso'] as String;
        final utilizador = dados['utilizador'] as Map<String, dynamic>;

        await _salvarToken(tokenAcesso);
        await _salvarUtilizador(utilizador);

        return {
          'token': tokenAcesso,
          'utilizador': utilizador,
        };
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
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> register(
      String nome, String email, String senha) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}/api/v1/autenticacao/registar');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
          )
          .timeout(ApiConstants.timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && body['sucesso'] == true) {
        final dados = body['dados'] as Map<String, dynamic>;
        final token = dados['token'] as Map<String, dynamic>;
        final tokenAcesso = token['tokenAcesso'] as String;
        final utilizador = dados['utilizador'] as Map<String, dynamic>;

        await _salvarToken(tokenAcesso);
        await _salvarUtilizador(utilizador);

        return {
          'token': tokenAcesso,
          'utilizador': utilizador,
        };
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
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>?> getUtilizadorAutenticado() async {
    final token = await getToken();
    if (token == null) return null;

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/autenticacao/me');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['sucesso'] == true) {
          return body['dados'] as Map<String, dynamic>;
        }
      }

      await logout();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> _salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _salvarUtilizador(Map<String, dynamic> utilizador) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(utilizador));
  }
}
