import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/doacao.dart';

class EditarDoacaoPage extends StatefulWidget {
  const EditarDoacaoPage({super.key});

  @override
  State<EditarDoacaoPage> createState() => _EditarDoacaoPageState();
}

class _EditarDoacaoPageState extends State<EditarDoacaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _db = FirebaseFirestore.instance;

  late Doacao _doacao;

  DateTime? _dataSelecionada;
  String? _tipoSelecionado;
  late TextEditingController _localController;
  late TextEditingController _obsController;

  bool _carregado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_carregado) return;

    final args = ModalRoute.of(context)!.settings.arguments;
    final id = args is int ? args : int.parse(args.toString());

    _doacao = doacoesMock.firstWhere((d) => d.id == id);

    _dataSelecionada = _doacao.data;
    _tipoSelecionado = _doacao.tipo;
    _localController = TextEditingController(text: _doacao.local);
    _obsController =
        TextEditingController(text: _doacao.observacoes ?? '');

    _carregado = true;
  }

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
      initialDate: _dataSelecionada ?? hoje,
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

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataSelecionada == null) {
      _mostrarAlerta('Data obrigatória', 'Selecione a data da doação.');
      return;
    }

    final data = _dataSelecionada!;
    final dataSemHora = DateTime(data.year, data.month, data.day);

    // Atualiza o objeto em memória
    _doacao.data = dataSemHora;
    _doacao.tipo = _tipoSelecionado ?? _doacao.tipo;
    _doacao.local = _localController.text.trim();
    _doacao.observacoes =
        _obsController.text.trim().isEmpty ? null : _obsController.text.trim();

    // Atualiza também no Firestore
    try {
      await _db.collection('doacoes')
          .doc(_doacao.id.toString())
          .set({
        'id': _doacao.id,
        'data': Timestamp.fromDate(_doacao.data),
        'tipo': _doacao.tipo,
        'local': _doacao.local,
        'observacoes': _doacao.observacoes,
      }, SetOptions(merge: true));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar doação: $e')),
      );
    }
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
        title: const Text('Editar Doação'),
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

              // OBS
              TextFormField(
                controller: _obsController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvar,
                  child: const Text('Salvar alterações'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
