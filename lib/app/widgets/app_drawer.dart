import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../modules/auth/bloc/auth_cubit.dart';
import '../modules/auth/bloc/auth_state.dart';
import '../routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLogged = state is AuthAuthenticated;

        return Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                child: const Center(
                  child: Text(
                    'QuiPede',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.storefront),
                      title: const Text('Lojas'),
                      onTap: () => _goTo(context, Routes.home),
                    ),
                    if (isLogged) ...[
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Perfil'),
                        onTap: () => _goTo(context, Routes.perfil),
                      ),
                      ListTile(
                        leading: const Icon(Icons.shopping_bag),
                        title: const Text('Meus Pedidos'),
                        onTap: () => _goTo(context, Routes.pedidos),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Meus Endereços de Entrega'),
                        onTap: () => _goTo(context, Routes.meusEnderecos),
                      ),
                    ],
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Configurações'),
                      onTap: () {
                        // Implementar rota de configurações se existir
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              if (isLogged)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Sair', style: TextStyle(color: Colors.red)),
                  onTap: () => _logout(context),
                )
              else
                ListTile(
                  leading: const Icon(Icons.login, color: Colors.blue),
                  title: const Text('Entrar', style: TextStyle(color: Colors.blue)),
                  onTap: () => _goTo(context, Routes.login),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _goTo(BuildContext context, String route) {
    Navigator.pop(context); // Fecha o drawer


    if (route == Routes.login) {
      // ✅ Para o login, usamos pushNamed para "empilhar" e permitir o retorno
      Navigator.pushNamed(context, route);
    } else if (route == Routes.home) {
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    } else {
      // ✅ Para outras telas, usamos replacement para não acumular pilhas infinitas
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    }
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<AuthCubit>().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.onboarding, (route) => false);
      }
    }
  }
}
