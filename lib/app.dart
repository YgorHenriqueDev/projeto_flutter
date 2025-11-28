import 'package:flutter/material.dart';

import 'pages/inicio_page.dart';
import 'pages/minhas_doacoes_page.dart';
import 'pages/nova_doacao_page.dart';
import 'pages/detalhes_doacao_page.dart';
import 'pages/editar_doacao_page.dart';
import 'pages/meu_perfil_page.dart';
import 'pages/editar_perfil_page.dart';
import 'pages/carteirinha_page.dart';
import 'pages/onde_doar_page.dart';
import 'pages/notificacoes_page.dart';

class DoadorSangueApp extends StatelessWidget {
  const DoadorSangueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doador de Sangue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,

        // Fundo padrão de todas as telas
        scaffoldBackgroundColor: const Color(0xFFF8F6F6),

        // Fonte global
        fontFamily: 'Roboto',

        // Cores principais
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDB1F26),
          primary: const Color(0xFFDB1F26),
          secondary: const Color(0xFFE57373),
        ),

        // AppBar padrão
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1C1C1C),
          elevation: 0.5,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1C),
          ),
        ),

        // Campos de texto padrão
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFDB1F26),
              width: 2,
            ),
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
          ),
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF424242),
          ),
        ),

        // Botões elevados padrão
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDB1F26),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        // BottomNavigationBar padrão
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFDB1F26),
          unselectedItemColor: Color(0xFF939393),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const InicioPage(),
        '/minhas-doacoes': (context) => const MinhasDoacoesPage(),
        '/nova-doacao': (context) => const NovaDoacaoPage(),
        '/detalhes-doacao': (context) => const DetalhesDoacaoPage(),

        // telas com formulário / lógica → sem const
        '/editar-doacao': (context) => EditarDoacaoPage(),
        '/meu-perfil': (context) => const MeuPerfilPage(),
        '/editar-perfil': (context) => EditarPerfilPage(),

        '/carteirinha': (context) => const CarteirinhaPage(),
        '/onde-doar': (context) => const OndeDoarPage(),
        '/notificacoes': (context) => const NotificacoesPage(),
      },
    );
  }
}
