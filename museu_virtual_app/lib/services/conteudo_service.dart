import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_exceptions.dart';
import 'auth_service.dart';

class ConteudoService {
  final AuthService _authService;

  ConteudoService(this._authService);

  Future<Map<String, String>> _headersComToken() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> listarTodos() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/conteudos');
    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(ApiConstants.timeout);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body['dados'] as List<dynamic>;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao listar conteúdos.',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> obterPorId(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/conteudos/$id');
    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(ApiConstants.timeout);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body['dados'] as Map<String, dynamic>;
      }
      if (response.statusCode == 404) {
        throw NotFoundException('Conteúdo não encontrado.');
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao obter conteúdo.',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> criar(Map<String, dynamic> dados) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/conteudos');
    try {
      final response = await http.post(
        uri,
        headers: await _headersComToken(),
        body: jsonEncode(dados),
      ).timeout(ApiConstants.timeout);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if ((response.statusCode == 201 || response.statusCode == 200) && body['sucesso'] == true) {
        return body['dados'] as Map<String, dynamic>;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao criar conteúdo.',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> actualizar(int id, Map<String, dynamic> dados) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/conteudos/$id');
    try {
      final response = await http.put(
        uri,
        headers: await _headersComToken(),
        body: jsonEncode(dados),
      ).timeout(ApiConstants.timeout);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body['dados'] as Map<String, dynamic>;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao actualizar conteúdo.',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<void> apagar(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/conteudos/$id');
    try {
      final response = await http.delete(
        uri,
        headers: await _headersComToken(),
      ).timeout(ApiConstants.timeout);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao apagar conteúdo.',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> uploadImagem(int id, XFile imagem) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/conteudos/$id/imagem');
    try {
      final token = await _authService.getToken();
      final request = http.MultipartRequest('POST', uri);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (kIsWeb) {
        final bytes = await imagem.readAsBytes();
        final extensao = imagem.name.split('.').last.toLowerCase();
        final mimeType = _mimeType(extensao);
        request.files.add(http.MultipartFile.fromBytes(
          'ficheiro',
          bytes,
          filename: imagem.name,
          contentType: mimeType,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('ficheiro', imagem.path));
      }

      final streamedResponse = await request.send().timeout(ApiConstants.timeout);
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body['dados'] as Map<String, dynamic>;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao enviar imagem.',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  MediaType? _mimeType(String extensao) {
    switch (extensao) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return null;
    }
  }
}
