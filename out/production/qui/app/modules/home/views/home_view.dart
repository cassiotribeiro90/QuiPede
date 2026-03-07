import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../lojas/cubit/lojas_cubit.dart';
import '../../lojas/views/lojas_view.dart';
import '../cubit/home_cubit.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // Lista de telas que o BottomNavigationBar vai controlar
  final List<Widget> _widgetOptions = const <Widget>[
    // A LojasView agora é um módulo independente, e precisa do seu próprio
    // BlocProvider para funcionar corretamente.
    BlocProvider(
      create: _createLojasCubit,
      child: LojasView(),
    ),
    Center(
      child: Text('Página de Perfil'),
    ),
  ];

  // Função helper para criar o cubit
  static LojasCubit _createLojasCubit(BuildContext context) {
    return LojasCubit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // Pega o índice da aba atual a partir do HomeState
        final currentIndex = state is HomeTabChanged ? state.selectedIndex : 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Qui Delivery'),
          ),
          body: IndexedStack(
            index: currentIndex,
            children: _widgetOptions,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              // Notifica o HomeCubit para trocar de aba
              context.read<HomeCubit>().changeTab(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.store),
                label: 'Lojas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}
