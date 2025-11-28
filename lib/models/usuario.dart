import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Modelo de usuário do aplicativo
class Usuario {
  String nome;
  String tipoSanguineo;
  DateTime dataNascimento;
  String telefone;
  String email;
  String localizacao;

  /// "Masculino" ou "Feminino"
  String sexo;

  /// Foto em memória (usada nos Avatars)
  ImageProvider? foto;

  /// Foto codificada em texto (base64) para salvar no Firestore
  String? fotoBase64;

  Usuario({
    required this.nome,
    required this.tipoSanguineo,
    required this.dataNascimento,
    required this.telefone,
    required this.email,
    required this.localizacao,
    required this.sexo,
    this.foto,
    this.fotoBase64,
  });

  /// Atualiza a foto a partir de bytes (ex: selecionados pelo image_picker)
  void atualizarFotoComBytes(Uint8List? bytes) {
    if (bytes == null) {
      foto = null;
      fotoBase64 = null;
    } else {
      fotoBase64 = base64Encode(bytes);
      foto = MemoryImage(bytes);
    }
  }
}

/// "Banco de dados" mock: usuário atual logado
Usuario usuarioAtual = Usuario(
  nome: 'Carlos Alberto de Souza',
  tipoSanguineo: 'O+',
  dataNascimento: DateTime(1985, 5, 15),
  telefone: '(11) 98765-4321',
  email: 'carlos.souza@email.com',
  localizacao: 'São Paulo, SP',
  sexo: 'Masculino', // padrão inicial
);

/// Regras de intervalo mínimo entre doações:
/// Masculino → 60 dias
/// Feminino  → 90 dias
int obterIntervaloMinimoDiasPorSexo() {
  if (usuarioAtual.sexo == 'Masculino') {
    return 60;
  }
  return 90;
}
