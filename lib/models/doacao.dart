import 'package:flutter/material.dart';
import 'usuario.dart';

/// Intervalo mínimo entre doações, de acordo com o sexo do usuário:
/// - Masculino: 2 meses (~60 dias)
/// - Feminino: 3 meses (~90 dias)
int obterIntervaloMinimoDiasPorSexo() {
  if (usuarioAtual.sexo == 'Masculino') {
    return 60;
  } else {
    return 90;
  }
}

class Doacao {
  final int id;
  DateTime data;
  String tipo;
  String local;
  String? observacoes;

  Doacao({
    required this.id,
    required this.data,
    required this.tipo,
    required this.local,
    this.observacoes,
  });
}

/// LISTA CENTRAL DE DOAÇÕES (mock em memória)
List<Doacao> doacoesMock = [
  Doacao(
    id: 1,
    data: DateTime(2025, 11, 20),
    tipo: 'Sangue Total',
    local: 'Hemocentro Central',
    observacoes: 'Primeira doação registrada.',
  ),
  // você pode adicionar mais mocks aqui se quiser
];

/// Retorna a última doação (mais recente) ou null se não houver.
Doacao? obterUltimaDoacao() {
  if (doacoesMock.isEmpty) return null;

  final listaOrdenada = [...doacoesMock]
    ..sort((a, b) => b.data.compareTo(a.data)); // mais recente primeiro

  return listaOrdenada.first;
}
