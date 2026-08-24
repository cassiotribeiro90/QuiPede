import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/localizacao_cubit.dart';
import '../bloc/localizacao_state.dart';
import '../../lojas_list/views/lojas_list_screen.dart';
import '../../../navigation/navigation_cubit.dart';

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
      appBar: AppBar(
        title: const Text('QuiPede'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              const Text(
                'Onde você está?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Adicione um endereço para ver as lojas que entregam na sua região',
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<NavigationCubit>().goToBuscaEndereco();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Adicionar Endereço',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
