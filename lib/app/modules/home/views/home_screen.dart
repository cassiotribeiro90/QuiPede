import 'package:flutter/material.dart';
import '../../lojas_list/views/lojas_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏠 [HomeScreen] build() chamado');
    try {
      return const LojasListScreen();
    } catch (e, stack) {
      print('❌ [HomeScreen] ERRO: $e');
      print(stack);
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(child: Text('Erro ao carregar lojas: $e')),
      );
    }
  }
}
