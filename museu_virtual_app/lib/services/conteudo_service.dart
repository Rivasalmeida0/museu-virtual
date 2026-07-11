import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_exceptions.dart';
import 'http_seguro_service.dart';

class ConteudoService {
  ConteudoService();

  Future<List<dynamic>> listarTodos() async {
    final uri = '${ApiConstants.baseUrl}/api/v1/conteudos';
    try {
      final response = await HttpSeguroService.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body['dados'] as List<dynamic>;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao listar conteúdos.',
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Map<String, dynamic>> obterPorId(int id) async {
    final uri = '${ApiConstants.baseUrl}/api/v1/conteudos/$id';
    try {
      final response = await HttpSeguroService.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
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
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Map<String, dynamic>> criar(Map<String, dynamic> dados) async {
    final uri = '${ApiConstants.baseUrl}/api/v1/conteudos';
    try {
      final response = await HttpSeguroService.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: dados,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if ((response.statusCode == 201 || response.statusCode == 200) && body['sucesso'] == true) {
        return body['dados'] as Map<String, dynamic>;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao criar conteúdo.',
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Map<String, dynamic>> actualizar(int id, Map<String, dynamic> dados) async {
    final uri = '${ApiConstants.baseUrl}/api/v1/conteudos/$id';
    try {
      final response = await HttpSeguroService.put(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: dados,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body['dados'] as Map<String, dynamic>;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao actualizar conteúdo.',
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<void> apagar(int id) async {
    final uri = '${ApiConstants.baseUrl}/api/v1/conteudos/$id';
    try {
      final response = await HttpSeguroService.delete(
        uri,
        headers: {'Accept': 'application/json'},
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao apagar conteúdo.',
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Map<String, dynamic>> uploadImagem(int id, Uint8List bytes, {String filename = 'imagem.jpg'}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/conteudos/$id/imagem');
    try {
      final request = http.MultipartRequest('POST', uri);

      final extensao = filename.split('.').last.toLowerCase();
      final mimeType = _mimeType(extensao);
      request.files.add(http.MultipartFile.fromBytes(
        'ficheiro',
        bytes,
        filename: filename,
        contentType: mimeType,
      ));

      final streamedResponse = await HttpSeguroService.send(request).timeout(ApiConstants.timeout);
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao enviar imagem.',
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Map<String, dynamic>> uploadAudio(int id, Uint8List bytes, {String filename = 'audio.mp3'}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/uploads/audio/$id');
    try {
      final request = http.MultipartRequest('POST', uri);

      final extensao = filename.split('.').last.toLowerCase();
      final mimeType = _mimeType(extensao);
      request.files.add(http.MultipartFile.fromBytes(
        'ficheiro',
        bytes,
        filename: filename,
        contentType: mimeType,
      ));

      final streamedResponse = await HttpSeguroService.send(request).timeout(const Duration(minutes: 5));
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao enviar áudio.',
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Map<String, dynamic>> uploadVideo(int id, Uint8List bytes, {String filename = 'video.mp4'}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/uploads/video/$id');
    try {
      final request = http.MultipartRequest('POST', uri);

      final extensao = filename.split('.').last.toLowerCase();
      final mimeType = _mimeType(extensao);
      request.files.add(http.MultipartFile.fromBytes(
        'ficheiro',
        bytes,
        filename: filename,
        contentType: mimeType,
      ));

      final streamedResponse = await HttpSeguroService.send(request).timeout(const Duration(minutes: 30));
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao enviar vídeo.',
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Map<String, dynamic>> obterRelatoriosCompressao() async {
    final uri = '${ApiConstants.baseUrl}/api/v1/uploads/relatorio';
    try {
      final headers = <String, String>{'Accept': 'application/json'};
      final response = await HttpSeguroService.get(uri, headers: headers);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao obter relatórios.',
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /// Processamento multimédia unificado — envia imagem, áudio e vídeo de uma vez
  /// e recebe relatório comparativo de todos os codecs.
  Future<Map<String, dynamic>> uploadProcessar(
    int id, {
    Uint8List? imagemBytes,
    String? imagemFilename,
    Uint8List? audioBytes,
    String? audioFilename,
    Uint8List? videoBytes,
    String? videoFilename,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/uploads/processar/$id');
    try {
      final request = http.MultipartRequest('POST', uri);

      if (imagemBytes != null) {
        final ext = (imagemFilename ?? 'img.jpg').split('.').last.toLowerCase();
        request.files.add(http.MultipartFile.fromBytes(
          'imagem', imagemBytes,
          filename: imagemFilename ?? 'imagem.jpg',
          contentType: _mimeType(ext),
        ));
      }
      if (audioBytes != null) {
        final ext = (audioFilename ?? 'audio.mp3').split('.').last.toLowerCase();
        request.files.add(http.MultipartFile.fromBytes(
          'audio', audioBytes,
          filename: audioFilename ?? 'audio.mp3',
          contentType: _mimeType(ext),
        ));
      }
      if (videoBytes != null) {
        final ext = (videoFilename ?? 'video.mp4').split('.').last.toLowerCase();
        request.files.add(http.MultipartFile.fromBytes(
          'video', videoBytes,
          filename: videoFilename ?? 'video.mp4',
          contentType: _mimeType(ext),
        ));
      }

      final streamedResponse = await HttpSeguroService.send(request)
          .timeout(const Duration(minutes: 30));
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro no processamento.',
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /// Publica as versões selecionadas pelo administrador.
  Future<Map<String, dynamic>> publicarVersoes(
    int id, {
    String? imagemFicheiro,
    String? audioFicheiro,
    String? videoFicheiro,
    Map<String, dynamic>? relatorio,
  }) async {
    final uri = '${ApiConstants.baseUrl}/api/v1/uploads/publicar/$id';
    try {
      final dados = <String, dynamic>{};
      if (imagemFicheiro != null) dados['imagem_ficheiro'] = imagemFicheiro;
      if (audioFicheiro != null) dados['audio_ficheiro'] = audioFicheiro;
      if (videoFicheiro != null) dados['video_ficheiro'] = videoFicheiro;
      if (relatorio != null) dados['relatorio'] = relatorio;

      final response = await HttpSeguroService.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: dados,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['sucesso'] == true) {
        return body;
      }
      throw ApiException(
        body['mensagem'] as String? ?? 'Erro ao publicar.',
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      throw NetworkException('${e.runtimeType}: ${e.toString().replaceFirst("Exception: ", "")}');
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
      case 'mp3':
      case 'mpeg':
        return MediaType('audio', 'mpeg');
      case 'ogg':
        return MediaType('audio', 'ogg');
      case 'wav':
        return MediaType('audio', 'wav');
      case 'aac':
        return MediaType('audio', 'aac');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'webm':
        return MediaType('video', 'webm');
      case 'mov':
        return MediaType('video', 'quicktime');
      default:
        return null;
    }
  }
}
