import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/doacao.dart';

class DetalhesDoacaoPage extends StatefulWidget {
  const DetalhesDoacaoPage({super.key});

  @override
  State<DetalhesDoacaoPage> createState() => _DetalhesDoacaoPageState();
}

class _DetalhesDoacaoPageState extends State<DetalhesDoacaoPage> {
  final _db = FirebaseFirestore.instance;

  late Doacao _doacao;
  bool _carregado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_carregado) return;

    final args = ModalRoute.of(context)!.settings.arguments;
    final id = args is int ? args : int.parse(args.toString());

    _doacao = doacoesMock.firstWhere((d) => d.id == id);

    _carregado = true;
  }

  String _formatarDataExtenso(DateTime data) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    final dia = data.day.toString().padLeft(2, '0');
    final mes = meses[data.month - 1];
    final ano = data.year.toString();
    return '$dia de $mes, $ano';
  }

  Future<void> _excluirDoacao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir doação'),
        content: const Text(
          'Tem certeza que deseja excluir esta doação? '
          'Essa ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // 1) Remove da lista em memória
    doacoesMock.removeWhere((d) => d.id == _doacao.id);

    // 2) Remove do Firestore
    try {
      await _db.collection('doacoes').doc(_doacao.id.toString()).delete();
    } catch (e) {
      // Mostra erro mas mesmo assim volta para a tela anterior
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir no Firestore: $e'),
        ),
      );
    }

    // 3) Volta para a tela anterior avisando que houve alteração
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_carregado) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Doação'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DATA
            const Text(
              'Data da Doação',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              readOnly: true,
              initialValue: _formatarDataExtenso(_doacao.data),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // TIPO
            const Text(
              'Tipo de Doação',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              readOnly: true,
              initialValue: _doacao.tipo,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // LOCAL
            const Text(
              'Local',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              readOnly: true,
              initialValue: _doacao.local,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // OBSERVAÇÕES
            const Text(
              'Observações',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              readOnly: true,
              initialValue: _doacao.observacoes ?? '',
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // BOTÃO EXCLUIR
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDB1F26),
                  side: const BorderSide(color: Color(0xFFDB1F26)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _excluirDoacao,
                child: const Text(
                  'Excluir Doação',
                  style: TextStyle(
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
