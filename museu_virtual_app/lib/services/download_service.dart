import '../../core/constants/api_constants.dart';

class DownloadService {

  Future<String> getUrlVideo(String filename) async {
    return '${ApiConstants.baseUrl}/api/v1/download/video/$filename';
  }

  Future<String> getUrlAudio(String filename) async {
    return '${ApiConstants.baseUrl}/api/v1/download/audio/$filename';
  }

  Future<String> getUrlImagem(String filename) async {
    return '${ApiConstants.baseUrl}/api/v1/download/imagem/$filename';
  }
}
