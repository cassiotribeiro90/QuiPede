import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/modules/home/views/onboarding_page.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import 'home_screen.dart';
import '../../perfil/views/perfil_view.dart';

class BottomNavWrapper extends StatefulWidget {
  const BottomNavWrapper({super.key});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Scaffold(body: Center(child: Text('Pedidos'))), // Placeholder
    const Scaffold(body: Center(child: Text('Favoritos'))), // Placeholder
    const PerfilView(),
  ];

  void _onItemTapped(int index) {
    debugPrint('🖱️ Clicou no índice: $index');
    
    final authState = context.read<AuthCubit>().state;
    final isLogged = authState is AuthAuthenticated;

    // Índice 3 é Perfil/Entrar
    if (index == 3 && !isLogged) {
      debugPrint('🚀 Navegando para login');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      ).then((_) {
        setState(() {});
      });
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isLogged = authState is AuthAuthenticated;
        
        debugPrint('🔐 AuthState: ${isLogged ? "Logado" : "Deslogado"}');

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped, 
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Lojas'),
              const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Pedidos'),
              const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
              BottomNavigationBarItem(
                icon: Icon(isLogged ? Icons.person : Icons.login),
                label: isLogged ? 'Perfil' : 'Entrar',
              ),
            ],
          ),
        );
      },
    );
  }
}
