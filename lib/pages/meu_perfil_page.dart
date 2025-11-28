import 'package:flutter/material.dart';
import '../models/usuario.dart';

class MeuPerfilPage extends StatefulWidget {
  const MeuPerfilPage({super.key});

  @override
  State<MeuPerfilPage> createState() => _MeuPerfilPageState();
}

class _MeuPerfilPageState extends State<MeuPerfilPage> {
  String _formatarData(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    final a = data.year.toString();
    return '$d/$m/$a';
  }

  @override
  Widget build(BuildContext context) {
    final u = usuarioAtual;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // FOTO DO PERFIL
          Center(
            child: Column(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF5D5B8), // fundo bege da foto
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: u.foto,
                    child: u.foto == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF5C4033),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  u.nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // CARTÕES DE INFORMAÇÃO
          _InfoTile(
            icon: Icons.person_outline,
            label: 'Sexo',
            value: u.sexo,
          ),
          _InfoTile(
            icon: Icons.bloodtype,
            label: 'Tipo Sanguíneo',
            value: u.tipoSanguineo,
          ),
          _InfoTile(
            icon: Icons.calendar_today_outlined,
            label: 'Data de Nascimento',
            value: _formatarData(u.dataNascimento),
          ),
          _InfoTile(
            icon: Icons.phone,
            label: 'Telefone',
            value: u.telefone,
          ),
          _InfoTile(
            icon: Icons.email_outlined,
            label: 'E-mail',
            value: u.email,
          ),
          _InfoTile(
            icon: Icons.location_on_outlined,
            label: 'Localização',
            value: u.localizacao,
          ),

          const SizedBox(height: 20),

          // CARTÃO CARTEIRINHA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Carteirinha de Doador de Sangue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/carteirinha');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: Color(0xFFDB1F26),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      backgroundColor: const Color(0xFFFFF1F2),
                      foregroundColor: const Color(0xFFDB1F26),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Gerar Carteirinha'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // BOTÃO EDITAR PERFIL
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result =
                    await Navigator.pushNamed(context, '/editar-perfil');

                if (result == true) {
                  setState(() {});
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B1B30),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // BOTÃO CANCELAR
          TextButton(
            onPressed: () {
              Navigator.maybePop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFDB1F26),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFDE4EA),
            ),
            child: Icon(
              icon,
              size: 22,
              color: const Color(0xFFDB1F26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
