// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../routes/app_routes.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isLogged = authState is AuthAuthenticated;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(context, isLogged),
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

              // ===== SE LOGADO =====
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

              // ===== SE DESLOGADO =====
              if (!isLogged) ...[
                _buildMenuItem(
                  icon: Icons.login,
                  label: 'Entrar',
                  isLogin: true,
                  onTap: () => _navigateAndClose(context, Routes.login),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isLogged) {
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
            isLogged ? 'Bem-vindo de volta!' : 'Faça login para mais recursos',
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
    Navigator.pop(context); // Fecha o drawer
    Navigator.pushReplacementNamed(context, route);
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
      Navigator.pop(context); // Fecha o drawer
      await context.read<AuthCubit>().logout();
      if (context.mounted) {
        // ✅ Após logout, vai para a home
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    }
  }
}
