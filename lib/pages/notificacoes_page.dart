import 'package:flutter/material.dart';

class NotificacoesPage extends StatelessWidget {
  const NotificacoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Depois: buscar notificações reais do Firebase
    final notificacoes = [
      'Está chegando o período recomendado para uma nova doação.',
      'Obrigado por salvar vidas! Sua última doação foi registrada.',
      'Lembre-se de manter seus dados atualizados no aplicativo.',
    ];

    // Depois: também mostrar "últimos registros" de doação aqui

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: ListView.builder(
        itemCount: notificacoes.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notificacoes[index]),
          );
        },
      ),
    );
  }
}
