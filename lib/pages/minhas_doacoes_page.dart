import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doacao.dart';

class MinhasDoacoesPage extends StatefulWidget {
  const MinhasDoacoesPage({super.key});

  @override
  State<MinhasDoacoesPage> createState() => _MinhasDoacoesPageState();
}

class _MinhasDoacoesPageState extends State<MinhasDoacoesPage> {
  final _db = FirebaseFirestore.instance;

  List<Doacao> get _doacoesOrdenadas {
    final lista = [...doacoesMock];
    lista.sort((a, b) => b.data.compareTo(a.data)); // mais recente primeiro
    return lista;
  }

  Future<void> _excluirDoacao(Doacao doacao) async {
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

    // 1) Remove da lista em memória e atualiza UI
    setState(() {
      doacoesMock.removeWhere((d) => d.id == doacao.id);
    });

    // 2) Remove do Firestore
    try {
      await _db.collection('doacoes').doc('${doacao.id}').delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doação excluída com sucesso.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir no Firebase: $e')),
        );
      }
    }
  }

  String _formatarDataSimples(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    final a = data.year.toString();
    return '$d/$m/$a';
  }

  @override
  Widget build(BuildContext context) {
    final lista = _doacoesOrdenadas;

    if (lista.isEmpty) {
      return const Center(
        child: Text(
          'Você ainda não registrou nenhuma doação.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final doacao = lista[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              doacao.tipo,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  _formatarDataSimples(doacao.data),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  doacao.local,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ver detalhes
                IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined),
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/detalhes-doacao',
                      arguments: doacao.id,
                    );

                    // Se voltou com true, atualiza lista (caso tenha excluído por lá)
                    if (result == true && mounted) {
                      setState(() {});
                    }
                  },
                ),

                // Editar
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/editar-doacao',
                      arguments: doacao.id,
                    );

                    // Se houve alteração, recarrega a lista
                    if (result == true && mounted) {
                      setState(() {});
                    }
                  },
                ),

                // Excluir
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _excluirDoacao(doacao),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
