import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../di/dependencies.dart';
import '../../appart/widgets/app_text.dart';
import '../../lojas_list/bloc/lojas_cubit.dart';
import '../../lojas_list/views/loja_view.dart';
import '../bloc/home_cubit.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static final List<Widget> _widgetOptions = <Widget>[
    BlocProvider.value(
      value: getIt<LojasCubit>(),
      child: const LojaView(),
    ),
    const Center(
      child: AppText('Página de Perfil'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final currentIndex = state is HomeTabChanged ? state.selectedIndex : 0;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  context.read<HomeCubit>().changeTab(0);
                },
                child: const Text('Qui Delivery'),
              ),
            ),
          ),
          body: IndexedStack(
            index: currentIndex,
            children: _widgetOptions,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
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
