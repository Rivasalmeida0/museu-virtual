import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Implementação do DownloadService para plataformas nativas (iOS, Android, Desktop).
class DownloadServicePlatform {
  DownloadServicePlatform._();

  static Future<void> salvarFicheiro(Uint8List bytes, String nomeFicheiro) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$nomeFicheiro');
    await file.writeAsBytes(bytes);
  }
}
