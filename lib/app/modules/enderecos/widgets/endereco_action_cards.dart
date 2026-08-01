import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/views/cep_input_page.dart';
import '../../home/views/busca_endereco_page.dart';
import '../bloc/endereco_cubit.dart';

class EnderecoActionCards extends StatelessWidget {
  const EnderecoActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCard(
          context,
          icon: Icons.markunread_mailbox_rounded,
          title: 'Adicionar com CEP',
          subtitle: 'Rápido e preciso',
          onTap: () => _navigateToCepPage(context),
        ),
        const SizedBox(height: 12),
        _buildCard(
          context,
          icon: Icons.search_rounded,
          title: 'Buscar novo endereço',
          subtitle: 'Digite rua ou bairro',
          onTap: () => _navigateToBuscaEnderecoPage(context),
        ),
      ],
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCepPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CepInputPage()),
    ).then((result) {
      if (result == true && context.mounted) {
        context.read<EnderecoCubit>().carregarEnderecos();
      }
    });
  }

  void _navigateToBuscaEnderecoPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BuscaEnderecoPage()),
    ).then((result) {
      if (result == true && context.mounted) {
        context.read<EnderecoCubit>().carregarEnderecos();
      }
    });
  }
}