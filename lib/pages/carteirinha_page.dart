import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html; // para download de imagem no web

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/usuario.dart';
import '../models/doacao.dart';

class CarteirinhaPage extends StatefulWidget {
  const CarteirinhaPage({super.key});

  @override
  State<CarteirinhaPage> createState() => _CarteirinhaPageState();
}

class _CarteirinhaPageState extends State<CarteirinhaPage> {
  final GlobalKey _cardKey = GlobalKey();

  // Código fictício de doador (depois pode vir do Firebase)
  String get _codigoDoador => 'DS-0001';

  // Última doação, se existir
  Doacao? get _ultimaDoacao => obterUltimaDoacao();

  String _formatarData(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    final a = data.year.toString();
    return '$d/$m/$a';
  }

  // Texto que vai dentro do QR Code (é isso que aparece no leitor de QR)
  String get _qrData {
    final ultima = _ultimaDoacao;
    final ultimaStr = ultima != null
        ? _formatarData(ultima.data)
        : 'Sem doações registradas';

    return 'CARTEIRINHA DO DOADOR\n'
        '-------------------------\n'
        'Nome: ${usuarioAtual.nome}\n'
        'Tipo sanguíneo: ${usuarioAtual.tipoSanguineo}\n'
        'Código: $_codigoDoador\n'
        'Última doação: $ultimaStr\n'
        'Telefone: ${usuarioAtual.telefone}\n'
        'E-mail: ${usuarioAtual.email}\n'
        'Cidade/UF: ${usuarioAtual.localizacao}';
  }

  // Captura o widget da carteirinha como PNG
  Future<Uint8List> _capturarCarteirinha() async {
    final boundary =
        _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  // Botão "Baixar PDF"
  Future<void> _baixarPdf() async {
    try {
      final bytes = await _capturarCarteirinha();

      final pdf = pw.Document();
      final image = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Center(
              child: pw.Container(
                width: 350,
                child: pw.Image(image),
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e')),
      );
    }
  }

  // Botão "Baixar como Imagem" (download de PNG no navegador)
  Future<void> _baixarComoImagem() async {
    try {
      final bytes = await _capturarCarteirinha();

      final blob = html.Blob([bytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..download = 'carteirinha_doador.png'
        ..click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar imagem: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultima = _ultimaDoacao;
    final String ultimaDoacaoTexto = ultima != null
        ? _formatarData(ultima.data)
        : 'Sem doações registradas';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carteirinha de Doador'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------------- CARTÃO DA CARTEIRINHA ----------------
            RepaintBoundary(
              key: _cardKey,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Lado esquerdo: texto + foto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usuarioAtual.nome,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Código: $_codigoDoador',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Última Doação: $ultimaDoacaoTexto',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: const Color(0xFFFFE0B2),
                                backgroundImage: usuarioAtual.foto,
                                child: usuarioAtual.foto == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Color(0xFF5C4033),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Lado direito: tipo sanguíneo + QR Code real
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tipo sanguíneo
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDB1F26),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            usuarioAtual.tipoSanguineo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // QR Code de verdade
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCCBC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: QrImageView(
                            data: _qrData,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ---------------- BOTÃO BAIXAR PDF ----------------
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _baixarPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDB1F26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Baixar PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------------- BOTÃO BAIXAR COMO IMAGEM ----------------
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _baixarComoImagem,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDB1F26)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: const Color(0xFFFDF5F5),
                ),
                icon: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFFDB1F26),
                ),
                label: const Text(
                  'Baixar como Imagem',
                  style: TextStyle(
                    color: Color(0xFFDB1F26),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
