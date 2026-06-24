import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class DownloadService {
  final AuthService _auth;

  DownloadService(this._auth);

  Future<String> getUrlVideo(String filename) async {
    final token = await _auth.getToken();
    return '${ApiConstants.baseUrl}/api/v1/download/video/$filename?token=$token';
  }

  Future<String> getUrlAudio(String filename) async {
    final token = await _auth.getToken();
    return '${ApiConstants.baseUrl}/api/v1/download/audio/$filename?token=$token';
  }

  Future<String> getUrlImagem(String filename) async {
    final token = await _auth.getToken();
    return '${ApiConstants.baseUrl}/api/v1/download/imagem/$filename?token=$token';
  }
}
