import 'dart:typed_data';
import 'download_service_nativo.dart'
    if (dart.library.html) 'download_service_web.dart'
    as platform;

/// Serviço de download de ficheiros unificado para Web e Nativo (Mobile/Desktop).
class DownloadService {
  DownloadService._();

  /// Salva os bytes recebidos num ficheiro local com o nome especificado.
  static Future<void> salvarFicheiro(Uint8List bytes, String nomeFicheiro) =>
      platform.DownloadServicePlatform.salvarFicheiro(bytes, nomeFicheiro);
}
