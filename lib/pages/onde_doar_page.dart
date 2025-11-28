import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HemocentroInfo {
  final String nome;
  final String endereco; // rua + número + bairro
  final String cidadeEstado;
  final String telefone;
  final String horario;
  final String status; // "Baixo", "Médio", "Bom"

  HemocentroInfo({
    required this.nome,
    required this.endereco,
    required this.cidadeEstado,
    required this.telefone,
    required this.horario,
    required this.status,
  });

  String get enderecoCompleto => '$endereco, $cidadeEstado';
}

class OndeDoarPage extends StatefulWidget {
  const OndeDoarPage({super.key});

  @override
  State<OndeDoarPage> createState() => _OndeDoarPageState();
}

class _OndeDoarPageState extends State<OndeDoarPage> {
  final TextEditingController _buscaController = TextEditingController();

  // --- LISTA DE HEMOCENTROS EM CUIABÁ/MT ---
  final List<HemocentroInfo> _todosHemocentros = [
    HemocentroInfo(
      nome: 'MT Hemocentro - Unidade Cuiabá',
      endereco: 'Rua 13 de Junho, 1055 - Centro Sul',
      cidadeEstado: 'Cuiabá - MT',
      telefone: '(65) 3623-0044',
      horario: 'Seg–Sex: 07h às 17h • Sáb: 07h às 12h',
      status: 'Baixo', // estoque baixo
    ),
    HemocentroInfo(
      nome: 'Banco de Sangue Hemosan',
      endereco: 'Av. Miguel Sutil, 8400 - Ribeirão do Lipa',
      cidadeEstado: 'Cuiabá - MT',
      telefone: '(65) 3028-6060',
      horario: 'Seg–Sex: 07h às 17h',
      status: 'Médio',
    ),
    HemocentroInfo(
      nome: 'Banco de Sangue Santa Casa',
      endereco: 'Rua Comandante Costa, 195 - Centro',
      cidadeEstado: 'Cuiabá - MT',
      telefone: '(65) 3317-3300',
      horario: 'Seg–Sex: 07h às 17h',
      status: 'Médio',
    ),
    HemocentroInfo(
      nome: 'Banco de Sangue Santa Rosa',
      endereco: 'Av. Miguel Sutil, 7800 - Santa Rosa',
      cidadeEstado: 'Cuiabá - MT',
      telefone: '(65) 3618-8000',
      horario: 'Seg–Sex: 07h às 17h',
      status: 'Bom',
    ),
    HemocentroInfo(
      nome: 'Banco de Sangue Jardim Cuiabá (IHEMCO)',
      endereco: 'Rua dos Lírios, 533 - Jardim Cuiabá',
      cidadeEstado: 'Cuiabá - MT',
      telefone: '(65) 3028-3030',
      horario: 'Seg–Sex: 07h às 17h',
      status: 'Bom',
    ),
  ];

  String _termoBusca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // Abre o mapa (Google Maps / Waze / outro) com o endereço
  Future<void> _abrirNoMapa(HemocentroInfo h) async {
    final query = Uri.encodeComponent(h.enderecoCompleto);

    // Link genérico do Google Maps. No Android, iOS e web,
    // o sistema pode mostrar as opções de apps de mapa instalados.
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o mapa neste dispositivo.'),
          ),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'baixo':
        return const Color(0xFFFFCDD2); // vermelho clarinho
      case 'médio':
        return const Color(0xFFFFF9C4); // amarelo clarinho
      case 'bom':
      default:
        return const Color(0xFFC8E6C9); // verde clarinho
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'baixo':
        return const Color(0xFFD32F2F);
      case 'médio':
        return const Color(0xFFF9A825);
      case 'bom':
      default:
        return const Color(0xFF388E3C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hemocentrosFiltrados = _todosHemocentros.where((h) {
      if (_termoBusca.isEmpty) return true;
      final termo = _termoBusca.toLowerCase();
      return h.nome.toLowerCase().contains(termo) ||
          h.endereco.toLowerCase().contains(termo);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hemocentros'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Pesquisar por nome ou bairro',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (valor) {
                setState(() {
                  _termoBusca = valor.trim();
                });
              },
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: hemocentrosFiltrados.length,
              itemBuilder: (context, index) {
                final h = hemocentrosFiltrados[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho com nome + status
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                h.nome,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(h.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bloodtype,
                                    size: 18,
                                    color: _statusTextColor(h.status),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    h.status,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _statusTextColor(h.status),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Endereço, horário, telefone
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${h.endereco}\n${h.cidadeEstado}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    h.horario,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  h.telefone,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Botão "Como chegar"
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            backgroundColor: const Color(0xFFDB1F26),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                          ),
                          onPressed: () => _abrirNoMapa(h),
                          icon: const Icon(
                            Icons.navigation_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Como chegar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
