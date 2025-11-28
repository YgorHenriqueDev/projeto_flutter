// lib/utils/carteirinha_download_stub.dart
import 'dart:typed_data';

/// Versão padrão (mobile / desktop) que NÃO usa dart:html
/// Aqui você pode futuramente implementar salvar no armazenamento do aparelho.
Future<void> baixarCarteirinhaComoImagem(
  Uint8List bytes,
  String fileName,
) async {
  // No mobile, por enquanto não vamos fazer nada de verdade.
  // Quem chamar essa função pode tratar isso com um SnackBar.
  throw UnsupportedError(
    'Download de imagem não suportado nesta plataforma (ainda).',
  );
}
