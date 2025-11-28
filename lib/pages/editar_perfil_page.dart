import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/usuario.dart';

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _db = FirebaseFirestore.instance;

  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;
  late TextEditingController _localizacaoController;

  late String _tipoSelecionado;
  late String _sexoSelecionado;
  DateTime _dataNascimento = usuarioAtual.dataNascimento;

  ImageProvider? _fotoPreview;
  Uint8List? _fotoBytes; // para conseguir salvar a foto no Firestore
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: usuarioAtual.nome);
    _telefoneController = TextEditingController(text: usuarioAtual.telefone);
    _emailController = TextEditingController(text: usuarioAtual.email);
    _localizacaoController =
        TextEditingController(text: usuarioAtual.localizacao);

    _tipoSelecionado =
        usuarioAtual.tipoSanguineo.isNotEmpty ? usuarioAtual.tipoSanguineo : 'O+';

    if (usuarioAtual.sexo == 'Masculino' || usuarioAtual.sexo == 'Feminino') {
      _sexoSelecionado = usuarioAtual.sexo;
    } else {
      _sexoSelecionado = 'Masculino';
    }

    // Se já tiver foto carregada (vinda do Firestore), mostra no preview
    _fotoPreview = usuarioAtual.foto;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _localizacaoController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    final a = data.year.toString();
    return '$d/$m/$a';
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final primeiraData = DateTime(1900, 1, 1);

    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataNascimento,
      firstDate: primeiraData,
      lastDate: hoje,
      helpText: 'Selecione sua data de nascimento',
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataNascimento = dataEscolhida;
      });
    }
  }

  Future<void> _selecionarFoto() async {
    final XFile? imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 85,
    );

    if (imagem != null) {
      final bytes = await imagem.readAsBytes();
      setState(() {
        _fotoBytes = bytes;
        _fotoPreview = MemoryImage(bytes);
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // Atualiza o "banco" mock em memória
    usuarioAtual.nome = _nomeController.text.trim();
    usuarioAtual.telefone = _telefoneController.text.trim();
    usuarioAtual.email = _emailController.text.trim();
    usuarioAtual.localizacao = _localizacaoController.text.trim();
    usuarioAtual.tipoSanguineo = _tipoSelecionado;
    usuarioAtual.sexo = _sexoSelecionado;
    usuarioAtual.dataNascimento = _dataNascimento;

    // Se o usuário escolheu uma nova foto, atualiza bytes + base64
    if (_fotoBytes != null) {
      usuarioAtual.atualizarFotoComBytes(_fotoBytes);
    }

    // --- Envia para o Firestore ---
    try {
      await _db.collection('usuarios').doc('usuarioAtual').set({
        'nome': usuarioAtual.nome,
        'telefone': usuarioAtual.telefone,
        'email': usuarioAtual.email,
        'localizacao': usuarioAtual.localizacao,
        'tipoSanguineo': usuarioAtual.tipoSanguineo,
        'sexo': usuarioAtual.sexo,
        'dataNascimento': Timestamp.fromDate(usuarioAtual.dataNascimento),
        'fotoBase64': usuarioAtual.fotoBase64, // pode ser null
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil salvo com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar no Firebase: $e')),
        );
      }
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // FOTO
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF5D5B8),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: _fotoPreview,
                        child: _fotoPreview == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF5C4033),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _selecionarFoto,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Alterar foto'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // NOME
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // SEXO
              DropdownButtonFormField<String>(
                value: _sexoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Sexo',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Masculino',
                    child: Text('Masculino'),
                  ),
                  DropdownMenuItem(
                    value: 'Feminino',
                    child: Text('Feminino'),
                  ),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      _sexoSelecionado = valor;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // TIPO SANGUÍNEO
              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo sanguíneo',
                ),
                items: const [
                  DropdownMenuItem(value: 'A+', child: Text('A+')),
                  DropdownMenuItem(value: 'A-', child: Text('A-')),
                  DropdownMenuItem(value: 'B+', child: Text('B+')),
                  DropdownMenuItem(value: 'B-', child: Text('B-')),
                  DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                  DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                  DropdownMenuItem(value: 'O+', child: Text('O+')),
                  DropdownMenuItem(value: 'O-', child: Text('O-')),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      _tipoSelecionado = valor;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // DATA DE NASCIMENTO
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Data de nascimento',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
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
                      Text(_formatarData(_dataNascimento)),
                      const Icon(Icons.calendar_today_outlined, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // TELEFONE
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o telefone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // E-MAIL
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o e-mail';
                  }
                  if (!valor.contains('@')) {
                    return 'Informe um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // LOCALIZAÇÃO
              TextFormField(
                controller: _localizacaoController,
                decoration: const InputDecoration(
                  labelText: 'Cidade / Estado',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe sua localização';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // BOTÕES
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
