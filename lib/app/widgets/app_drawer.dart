import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../modules/auth/bloc/auth_cubit.dart';
import '../modules/auth/bloc/auth_state.dart';
import '../routes/app_routes.dart';
import '../di/dependencies.dart';
import '../services/navigation_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isLogged = authState is AuthAuthenticated;
        final isGuest = authState is AuthGuest;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(context, isLogged, isGuest),
              const Divider(),

              // Lojas (sempre visível)
              _buildMenuItem(
                icon: Icons.storefront,
                label: 'Lojas',
                onTap: () => _navigateAndClose(context, Routes.home),
              ),

              // Carrinho (sempre visível)
              _buildMenuItem(
                icon: Icons.shopping_cart,
                label: 'Carrinho',
                onTap: () => _navigateAndClose(context, Routes.carrinho),
              ),

              const Divider(),

              // ===== SE LOGADO REAL =====
              if (isLogged) ...[
                _buildMenuItem(
                  icon: Icons.shopping_bag,
                  label: 'Meus Pedidos',
                  onTap: () => _navigateAndClose(context, Routes.pedidos),
                ),
                _buildMenuItem(
                  icon: Icons.person,
                  label: 'Meu Perfil',
                  onTap: () => _navigateAndClose(context, Routes.perfil),
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  label: 'Sair',
                  isLogout: true,
                  onTap: () => _confirmarLogout(context),
                ),
              ],

              // ===== SE CONVIDADO OU DESLOGADO =====
              if (!isLogged) ...[
                _buildMenuItem(
                  icon: Icons.login,
                  label: isGuest ? 'Identificar-se' : 'Entrar',
                  isLogin: true,
                  onTap: () => _navigateAndClose(context, Routes.login),
                ),
                if (isGuest)
                  _buildMenuItem(
                    icon: Icons.exit_to_app,
                    label: 'Sair do Convidado',
                    isLogout: true,
                    onTap: () => _confirmarSairConvidado(context),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isLogged, bool isGuest) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'QuiPede',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLogged ? 'Bem-vindo de volta!' : (isGuest ? 'Modo Visitante' : 'Faça login para mais recursos'),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
    bool isLogin = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : (isLogin ? Colors.green : null),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isLogout ? Colors.red : (isLogin ? Colors.green : null),
        ),
      ),
      onTap: onTap,
    );
  }

  void _navigateAndClose(BuildContext context, String route) {
    getIt<NavigationService>().pop(); // Fecha o drawer
    getIt<NavigationService>().pushNamed(route);
  }

  void _confirmarLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (context.mounted) {
        getIt<NavigationService>().pop(); // Fecha o drawer
        await context.read<AuthCubit>().logout();
      }
    }
  }

  void _confirmarSairConvidado(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Seu endereço será removido e você voltará à tela inicial.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (context.mounted) {
        getIt<NavigationService>().pop(); // Fecha o drawer
        await context.read<AuthCubit>().sairConvidado();
      }
    }
  }
}
