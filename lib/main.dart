// lib/main.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'models/usuario.dart';
import 'models/doacao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções geradas pelo FlutterFire
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Carrega usuário + doações do Firestore
  await _carregarEstadoDoFirebase();

  // Inicia o app
  runApp(const DoadorSangueApp());
}

/// Busca os dados salvos no Firestore e preenche
/// `usuarioAtual` e `doacoesMock`.
Future<void> _carregarEstadoDoFirebase() async {
  final db = FirebaseFirestore.instance;

  // -------------------- USUÁRIO --------------------
  try {
    final userDoc = await db.collection('usuarios').doc('usuarioAtual').get();

    if (userDoc.exists) {
      final data = userDoc.data()!;

      usuarioAtual.nome = data['nome'] ?? usuarioAtual.nome;
      usuarioAtual.telefone = data['telefone'] ?? usuarioAtual.telefone;
      usuarioAtual.email = data['email'] ?? usuarioAtual.email;
      usuarioAtual.localizacao =
          data['localizacao'] ?? usuarioAtual.localizacao;
      usuarioAtual.tipoSanguineo =
          data['tipoSanguineo'] ?? usuarioAtual.tipoSanguineo;
      usuarioAtual.sexo = data['sexo'] ?? usuarioAtual.sexo;

      final dn = data['dataNascimento'];
      if (dn is Timestamp) {
        usuarioAtual.dataNascimento = dn.toDate();
      }

      // Foto em base64
      final fotoBase64 = data['fotoBase64'];
      if (fotoBase64 is String && fotoBase64.isNotEmpty) {
        final bytes = base64Decode(fotoBase64);
        usuarioAtual.atualizarFotoComBytes(bytes);
      }
    }
  } catch (e) {
    // só loga no console para debug
    print('Erro ao carregar usuário do Firestore: $e');
  }

  // -------------------- DOAÇÕES --------------------
  try {
    final query =
        await db.collection('doacoes').orderBy('data', descending: false).get();

    doacoesMock.clear();

    for (final doc in query.docs) {
      final data = doc.data();

      DateTime dataDoacao;
      final campoData = data['data'];
      if (campoData is Timestamp) {
        dataDoacao = campoData.toDate();
      } else {
        dataDoacao = DateTime.now();
      }

      final idCampo = data['id'];
      final id = (idCampo is int) ? idCampo : 0;

      doacoesMock.add(
        Doacao(
          id: id,
          data: dataDoacao,
          tipo: (data['tipo'] ?? '') as String,
          local: (data['local'] ?? '') as String,
          observacoes: data['observacoes'] as String?,
        ),
      );
    }
  } catch (e) {
    print('Erro ao carregar doações do Firestore: $e');
  }
}
