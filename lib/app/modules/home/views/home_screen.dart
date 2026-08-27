import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/localizacao_cubit.dart';
import '../bloc/localizacao_state.dart';
import '../../lojas_list/views/lojas_list_screen.dart';
import '../../../navigation/navigation_cubit.dart';
import '../../../core/widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 [HomeScreen] build() chamado');
    
    return BlocBuilder<LocalizacaoCubit, LocalizacaoState>(
      builder: (context, state) {
        if (state is LocalizacaoNaoEncontrada) {
          return _buildNoAddressWidget(context);
        }
        
        try {
          return const LojasListScreen();
        } catch (e, stack) {
          debugPrint('❌ [HomeScreen] ERRO: $e');
          debugPrint(stack.toString());
          return Scaffold(
            appBar: AppBar(title: const Text('Erro')),
            body: Center(child: Text('Erro ao carregar lojas: $e')),
          );
        }
      },
    );
  }

  Widget _buildNoAddressWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔥 Ilustração minimalista (usando um ícone grande com container decorado)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_searching_outlined,
                  size: 72,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 40),

              // 🔥 Título principal
              Text(
                'Nenhum endereço cadastrado',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 🔥 Subtítulo descritivo
              Text(
                'Adicione um endereço para encontrar\nos melhores restaurantes da sua região',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 🔥 Botão principal - vai para Meus Endereços
              PrimaryButton(
                onPressed: () {
                  // 🔥 Vai para a tela de endereços
                  context.read<NavigationCubit>().goToMeusEnderecos();
                },
                label: 'Adicionar Endereço',
                icon: Icons.add_location_alt,
              ),

              const SizedBox(height: 12),

              // 🔥 Botão secundário - Explorar sem endereço (opcional)
              TextButton(
                onPressed: () {
                  // 🔥 Pular a tela de endereço (se quiser)
                  // context.read<NavigationCubit>().goToHome();
                },
                child: Text(
                  'Explorar sem endereço',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
