import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/doacao.dart';
import '../models/usuario.dart' hide obterIntervaloMinimoDiasPorSexo; // para obterIntervaloMinimoDiasPorSexo()

class NovaDoacaoPage extends StatefulWidget {
  const NovaDoacaoPage({super.key});

  @override
  State<NovaDoacaoPage> createState() => _NovaDoacaoPageState();
}

class _NovaDoacaoPageState extends State<NovaDoacaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _db = FirebaseFirestore.instance;

  DateTime? _dataSelecionada;
  String? _tipoSelecionado;
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();

  @override
  void dispose() {
    _localController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: DateTime(2000),
      lastDate: DateTime(hoje.year + 1),
    );

    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Selecione a data';

    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    final a = data.year.toString();
    return '$d/$m/$a';
  }

  void _mostrarAlerta(String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _salvarDoacao() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataSelecionada == null) {
      _mostrarAlerta(
        'Data obrigatória',
        'Selecione a data da doação.',
      );
      return;
    }

    if (_tipoSelecionado == null || _tipoSelecionado!.isEmpty) {
      _mostrarAlerta(
        'Tipo de doação',
        'Selecione o tipo de doação.',
      );
      return;
    }

    final hoje = DateTime.now();
    final data = _dataSelecionada!;

    final dataSemHora = DateTime(data.year, data.month, data.day);
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);

    // 1) Não permitir data no futuro
    if (dataSemHora.isAfter(hojeSemHora)) {
      _mostrarAlerta(
        'Data inválida',
        'A data da doação não pode ser no futuro.',
      );
      return;
    }

    // 2) Regra de intervalo mínimo baseado no sexo
    final ultima = obterUltimaDoacao();
    final intervaloMinimoDias = obterIntervaloMinimoDiasPorSexo();

    if (ultima != null) {
      final ultimaSemHora = DateTime(
        ultima.data.year,
        ultima.data.month,
        ultima.data.day,
      );

      final diasDiferenca =
          dataSemHora.difference(ultimaSemHora).inDays; // pode ser negativo

      if (diasDiferenca > 0 && diasDiferenca < intervaloMinimoDias) {
        final proximaDataPermitida =
            ultimaSemHora.add(Duration(days: intervaloMinimoDias));

        final d = proximaDataPermitida.day.toString().padLeft(2, '0');
        final m = proximaDataPermitida.month.toString().padLeft(2, '0');
        final a = proximaDataPermitida.year.toString();
        final dataFormatada = '$d/$m/$a';

        _mostrarAlerta(
          'Ainda não está no prazo',
          'De acordo com o histórico de doações, você só poderá registrar '
          'uma nova doação a partir de $dataFormatada.',
        );
        return;
      }
    }

    // 3) Se passou em tudo, cria a doação
    final novoId = doacoesMock.isEmpty
        ? 1
        : (doacoesMock.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1);

    final novaDoacao = Doacao(
      id: novoId,
      data: dataSemHora,
      tipo: _tipoSelecionado!,
      local: _localController.text.trim(),
      observacoes: _obsController.text.trim().isEmpty
          ? null
          : _obsController.text.trim(),
    );

    // Atualiza lista em memória
    doacoesMock.add(novaDoacao);

    // Salva no Firestore com id conhecido (string do id)
    try {
      await _db.collection('doacoes').doc(novoId.toString()).set({
        'id': novoId,
        'data': Timestamp.fromDate(novaDoacao.data),
        'tipo': novaDoacao.tipo,
        'local': novaDoacao.local,
        'observacoes': novaDoacao.observacoes,
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar no Firestore: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nova Doação'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // DATA
              Text(
                'Data da Doação',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatarData(_dataSelecionada)),
                      const Icon(Icons.calendar_today_outlined, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // TIPO
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Doação',
                ),
                value: _tipoSelecionado,
                items: const [
                  DropdownMenuItem(
                    value: 'Sangue Total',
                    child: Text('Sangue Total'),
                  ),
                  DropdownMenuItem(
                    value: 'Plaquetas',
                    child: Text('Plaquetas'),
                  ),
                  DropdownMenuItem(
                    value: 'Plasma',
                    child: Text('Plasma'),
                  ),
                ],
                onChanged: (valor) {
                  setState(() {
                    _tipoSelecionado = valor;
                  });
                },
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Selecione o tipo de doação';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // LOCAL
              TextFormField(
                controller: _localController,
                decoration: const InputDecoration(
                  labelText: 'Local da Doação',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o local da doação';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // OBSERVAÇÕES
              TextFormField(
                controller: _obsController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _salvarDoacao,
                child: const Text('Salvar Doação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
