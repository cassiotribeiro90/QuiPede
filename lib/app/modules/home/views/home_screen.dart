import 'package:flutter/material.dart';
import '../../lojas_list/views/lojas_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 [HomeScreen] build() chamado');
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
  }
}
