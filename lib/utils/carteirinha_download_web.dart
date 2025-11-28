// lib/utils/carteirinha_download_web.dart
import 'dart:typed_data';
import 'dart:html' as html;

/// Versão específica para Flutter Web.
/// Aqui usamos dart:html para fazer o download da imagem.
Future<void> baixarCarteirinhaComoImagem(
  Uint8List bytes,
  String fileName,
) async {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..click();

  html.Url.revokeObjectUrl(url);
}
