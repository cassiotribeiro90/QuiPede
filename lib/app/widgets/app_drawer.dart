import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../modules/auth/bloc/auth_cubit.dart';
import '../modules/auth/bloc/auth_state.dart';
import '../navigation/navigation_cubit.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        debugPrint('🧭 [AppDrawer] Reconstruindo com estado: ${authState.runtimeType}');
        final isLogged = authState is AuthAuthenticated;
        final isGuest = authState is AuthGuest;
        final navigationCubit = context.read<NavigationCubit>();

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(context, authState),
              const Divider(),

              // Lojas (sempre visível)
              _buildMenuItem(
                icon: Icons.storefront,
                label: 'Lojas',
                onTap: () => _navigateAndClose(context, navigationCubit.goToHome),
              ),

              // Carrinho (sempre visível)
              _buildMenuItem(
                icon: Icons.shopping_cart,
                label: 'Carrinho',
                onTap: () => _navigateAndClose(context, navigationCubit.goToCarrinho),
              ),

              const Divider(),

              // ===== SE LOGADO REAL =====
              if (isLogged) ...[
                _buildMenuItem(
                  icon: Icons.shopping_bag,
                  label: 'Meus Pedidos',
                  onTap: () => _navigateAndClose(context, navigationCubit.goToPedidos),
                ),
                _buildMenuItem(
                  icon: Icons.person,
                  label: 'Meu Perfil',
                  onTap: () => _navigateAndClose(context, navigationCubit.goToPerfil),
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  label: 'Sair',
                  isLogout: true,
                  onTap: () => _confirmarLogout(context, navigationCubit),
                ),
              ],

              // ===== SE CONVIDADO OU DESLOGADO =====
              if (!isLogged) ...[
                _buildMenuItem(
                  icon: Icons.login,
                  label: isGuest ? 'Identificar-se' : 'Entrar',
                  isLogin: true,
                  onTap: () => _navigateAndClose(context, navigationCubit.goToLogin),
                ),
                if (isGuest)
                  _buildMenuItem(
                    icon: Icons.exit_to_app,
                    label: 'Sair do Convidado',
                    isLogout: true,
                    onTap: () => _confirmarSairConvidado(context, navigationCubit),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AuthState authState) {
    final user = context.read<AuthCubit>().usuario;
    final isGuest = authState is AuthGuest;
    final isLogged = authState is AuthAuthenticated;

    final nomeExibicao = (user?.nome != null && user!.nome.isNotEmpty)
        ? user.nome
        : (isGuest ? 'Olá, Convidado' : 'QuiPede');

    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            nomeExibicao,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLogged
                ? (user?.email ?? 'Bem-vindo de volta!')
                : (isGuest ? 'Modo Visitante' : 'Faça login para mais recursos'),
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

  // 🔥 Fecha o drawer e executa a navegação
  void _navigateAndClose(BuildContext context, VoidCallback navigationAction) {
    context.pop(); // Fecha o drawer usando go_router
    navigationAction(); // Executa a navegação via NavigationCubit
  }

  void _confirmarLogout(BuildContext context, NavigationCubit cubit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (context.mounted) {
        context.pop(); // Fecha o drawer
        await cubit.logout(); // Delega ao NavigationCubit
      }
    }
  }

  void _confirmarSairConvidado(BuildContext context, NavigationCubit cubit) async {
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
        context.pop(); // Fecha o drawer
        await cubit.logoutGuest(); // Delega ao NavigationCubit
      }
    }
  }
}