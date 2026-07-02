import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_exceptions.dart';
import 'http_seguro_service.dart';

class AuthService {
  static const String _userKey = 'user_data';

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

        await _salvarUtilizador(utilizador);

        return {
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
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Map<String, dynamic>> register(
      String nome, String email, String senha) async {
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

        await _salvarUtilizador(utilizador);

        return {
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
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Map<String, dynamic>?> getUtilizadorAutenticado() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData == null) return null;
    return jsonDecode(userData) as Map<String, dynamic>;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> _salvarUtilizador(Map<String, dynamic> utilizador) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(utilizador));
  }
}
