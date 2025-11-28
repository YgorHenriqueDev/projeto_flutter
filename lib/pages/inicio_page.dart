import 'package:flutter/material.dart';
import '../models/doacao.dart';
import 'minhas_doacoes_page.dart';
import 'onde_doar_page.dart';
import 'meu_perfil_page.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int _selectedIndex = 0;

  /// Pega a última doação da lista global `doacoesMock`
  Doacao? get _ultimaDoacao {
    if (doacoesMock.isEmpty) return null;
    final lista = [...doacoesMock];
    lista.sort((a, b) => b.data.compareTo(a.data)); // mais recente primeiro
    return lista.first;
  }

  /// Data da próxima doação, baseada na última doação e no sexo
  DateTime get _proximaDoacao {
    final ultima = _ultimaDoacao;
    if (ultima == null) return DateTime.now();

    final intervaloDias = obterIntervaloMinimoDiasPorSexo();
    return ultima.data.add(Duration(days: intervaloDias));
  }

  /// Regra: está apto se já passou o prazo da próxima doação
  bool get estaAptoParaDoar {
    final hoje = DateTime.now();
    final proxima = _proximaDoacao;

    // Retorna verdadeiro se HOJE for igual ou depois da data permitida
    return !hoje.isBefore(DateTime(proxima.year, proxima.month, proxima.day));
  }

  /// Progresso do prazo para a barra laranja
  double get progressoPrazo {
    final ultima = _ultimaDoacao;
    if (ultima == null) return 1.0;

    final intervaloDias = obterIntervaloMinimoDiasPorSexo().toDouble();
    final hoje = DateTime.now();
    final diasDecorridos =
        hoje.difference(ultima.data).inDays.clamp(0, intervaloDias);

    return diasDecorridos / intervaloDias;
  }

  /// Alerta quando tenta doar sem estar no prazo
  void _mostrarAlertaNaoApto(BuildContext context) {
    final d = _proximaDoacao.day.toString().padLeft(2, '0');
    final m = _proximaDoacao.month.toString().padLeft(2, '0');
    final a = _proximaDoacao.year.toString();
    final dataFormatada = '$d/$m/$a';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ainda não está no prazo'),
        content: Text(
          'De acordo com as regras de doação, '
          'você só poderá registrar uma nova doação a partir de $dataFormatada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final ultima = _ultimaDoacao;

    final List<Widget> pages = [
      _InicioTab(
        estaApto: estaAptoParaDoar,
        dataProximaDoacao: _proximaDoacao,
        ultimaDoacao: ultima,
        progressoPrazo: progressoPrazo,
      ),
      const MinhasDoacoesPage(),
      const OndeDoarPage(),
      const MeuPerfilPage(),
    ];

    final List<String> titles = [
      'Início',
      'Minhas Doações',
      'Hemocentros',
      'Meu Perfil',
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(titles[_selectedIndex]),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notificacoes');
                  },
                ),
              ]
            : null,
      ),
      body: pages[_selectedIndex],

      /// BOTÃO FLUTUANTE (+) — apenas na página inicial
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFDB1F26),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                if (!estaAptoParaDoar) {
                  _mostrarAlertaNaoApto(context);
                  return;
                }

                final result =
                    await Navigator.pushNamed(context, '/nova-doacao');

                if (result == true) {
                  setState(() {}); // atualiza após nova doação
                }
              },
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype_outlined),
            activeIcon: Icon(Icons.bloodtype),
            label: 'Doação',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Hemocentros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// ---------------------- TELA PRINCIPAL ----------------------
// ------------------------------------------------------------

class _InicioTab extends StatelessWidget {
  final bool estaApto;
  final DateTime dataProximaDoacao;
  final Doacao? ultimaDoacao;
  final double progressoPrazo;

  const _InicioTab({
    required this.estaApto,
    required this.dataProximaDoacao,
    required this.ultimaDoacao,
    required this.progressoPrazo,
  });

  String formatarDataExtenso(DateTime data) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    final dia = data.day.toString().padLeft(2, '0');
    final mesTexto = meses[data.month - 1];
    final ano = data.year.toString();
    return '$dia de $mesTexto, $ano';
  }

  String formatarDataSimples(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    final a = data.year.toString();
    return '$d/$m/$a';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _StatusCard(
            estaApto: estaApto,
            dataProximaDoacao: formatarDataSimples(dataProximaDoacao),
            progressoPrazo: progressoPrazo,
          ),
          const SizedBox(height: 16),
          if (ultimaDoacao != null)
            _UltimoRegistroCard(
              localUltima: ultimaDoacao!.local,
              dataUltima: formatarDataExtenso(ultimaDoacao!.data),
              idUltima: ultimaDoacao!.id,
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// ----------------------- CARD STATUS ------------------------
// ------------------------------------------------------------

class _StatusCard extends StatelessWidget {
  final bool estaApto;
  final String dataProximaDoacao;
  final double progressoPrazo;

  const _StatusCard({
    required this.estaApto,
    required this.dataProximaDoacao,
    required this.progressoPrazo,
  });

  @override
  Widget build(BuildContext context) {
    final aguardando = !estaApto;

    final Color corFundo =
        aguardando ? const Color(0xFFFFA000) : const Color(0xFF2E7D32);

    final IconData icone =
        aguardando ? Icons.hourglass_bottom : Icons.verified;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icone,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  aguardando
                      ? 'Aguardando prazo'
                      : 'Você está apto para doar!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            aguardando
                ? 'Sua próxima doação pode ser a partir de $dataProximaDoacao.'
                : 'Sua solidariedade salva vidas.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),

          if (!aguardando)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Encontre um hemocentro próximo para fazer sua doação.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),

          if (aguardando) ...[
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progressoPrazo.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// ------------------- CARD ÚLTIMO REGISTRO ------------------
// ------------------------------------------------------------

class _UltimoRegistroCard extends StatelessWidget {
  final String localUltima;
  final String dataUltima;
  final int idUltima;

  const _UltimoRegistroCard({
    required this.localUltima,
    required this.dataUltima,
    required this.idUltima,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Último Registro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bloodtype,
                  color: Color(0xFFDB1F26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localUltima,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dataUltima,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/detalhes-doacao',
                    arguments: idUltima,
                  );
                },
                child: const Text(
                  'Ver detalhes',
                  style: TextStyle(
                    color: Color(0xFFDB1F26),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
