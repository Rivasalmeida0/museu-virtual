import 'dart:html' as html;
import 'dart:typed_data';

/// Implementação do DownloadService para navegadores Web.
class DownloadServicePlatform {
  DownloadServicePlatform._();

  static Future<void> salvarFicheiro(Uint8List bytes, String nomeFicheiro) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", nomeFicheiro)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
