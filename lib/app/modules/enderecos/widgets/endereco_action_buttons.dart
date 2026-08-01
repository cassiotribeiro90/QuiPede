import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/views/widgets/onboarding_option_card.dart';
import '../../home/views/cep_input_page.dart';
import '../../home/views/busca_endereco_page.dart';
import '../bloc/endereco_cubit.dart';

class EnderecoActionButtons extends StatelessWidget {
  const EnderecoActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔥 CARD 1: ADICIONAR COM CEP → NAVEGA PARA CepInputPage
        OnboardingOptionCard(
          icon: Icons.markunread_mailbox_rounded,
          title: 'Adicionar com CEP',
          subtitle: 'Rápido e preciso',
          onTap: () => _navigateToCepPage(context),
        ),
        const SizedBox(height: 8),

        // 🔥 CARD 2: BUSCAR NOVO ENDEREÇO → NAVEGA PARA BuscaEnderecoPage
        OnboardingOptionCard(
          icon: Icons.search_rounded,
          title: 'Buscar novo endereço',
          subtitle: 'Digite rua ou bairro',
          onTap: () => _navigateToBuscaEnderecoPage(context),
        ),
      ],
    );
  }

  void _navigateToCepPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CepInputPage(),
      ),
    ).then((result) {
      // 🔥 QUANDO VOLTAR DA TELA, RECARREGA A LISTA DE ENDEREÇOS SE O RESULTADO FOR TRUE
      if (result == true && context.mounted) {
        context.read<EnderecoCubit>().carregarEnderecos();
      }
    });
  }

  void _navigateToBuscaEnderecoPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BuscaEnderecoPage(),
      ),
    ).then((result) {
      // 🔥 QUANDO VOLTAR DA TELA, RECARREGA A LISTA DE ENDEREÇOS SE O RESULTADO FOR TRUE
      if (result == true && context.mounted) {
        context.read<EnderecoCubit>().carregarEnderecos();
      }
    });
  }
}
