import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../apparte/widgets/app_drawer.dart';
import '../../apparte/widgets/home_app_bar.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../../lojas_list/bloc/lojas_cubit.dart';
import '../../lojas_list/views/lojas_view.dart';
import '../../lojas_list/widgets/filter_search_bottom_sheet.dart';
import '../../perfil/views/pedidos_view.dart';
import '../../perfil/views/perfil_view.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';
import '../../carrinho/widgets/carrinho_bottom_bar.dart';
import '../bloc/home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        print('🏠 [HomeScreen] Estado de autenticação: $authState');
        
        // ✅ 1. Enquanto verifica, mostra splash/loading (pode ser o próprio SplashScreen ou um indicador aqui)
        if (authState is AuthInitial || authState is AuthChecking) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verificando autenticação...'),
                ],
              ),
            ),
          );
        }
        
        // ✅ 2. SEMPRE mostra o conteúdo principal. O acesso anônimo é permitido para ver lojas.
        return const _MainContent();
      },
    );
  }
}

class _MainContent extends StatefulWidget {
  const _MainContent();

  @override
  State<_MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<_MainContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // ✅ Inicia a verificação de autenticação de forma silenciosa se ainda não foi feita
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCubit = context.read<AuthCubit>();
      if (authCubit.state is AuthInitial) {
        authCubit.checkAuthStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Quando autenticar (ou re-autenticar via refresh), atualiza dados privados
          // context.read<CarrinhoCubit>().carregarCarrinho();
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final currentIndex = state is HomeTabChanged ? state.selectedIndex : 0;

          return Scaffold(
            key: _scaffoldKey,
            appBar: _buildAppBar(currentIndex),
            drawer: AppDrawer(
              selectedIndex: currentIndex,
              onItemSelected: (index) => _handleTabChange(context, index),
            ),
            body: _buildBody(currentIndex),
            // ✅ Bottom Bar Global do Carrinho - Reage ao estado, sem forçar login
            bottomNavigationBar: BlocBuilder<CarrinhoCubit, CarrinhoState>(
              builder: (context, carrinhoState) {
                if (carrinhoState is CarrinhoLoaded && 
                    carrinhoState.totalItens > 0 && 
                    carrinhoState.lojaNome != null) {
                  return CarrinhoBottomBar(
                    lojaNome: carrinhoState.lojaNome!,
                    onTap: () => Navigator.pushNamed(context, '/carrinho'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  void _handleTabChange(BuildContext context, int index) {
    // ✅ Só exige login para Pedidos (1) e Perfil (2)
    if (index == 1 || index == 2) {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) {
        _mostrarDialogLogin(context);
        return;
      }
    }
    
    if (index == 0) {
      context.read<LojasCubit>().refreshList();
    }
    context.read<HomeCubit>().changeTab(index);
  }

  void _mostrarDialogLogin(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entre para continuar'),
        content: const Text('Para acessar esta área, você precisa estar conectado à sua conta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agora não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Fazer login'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int currentIndex) {
    if (currentIndex == 0) {
      return HomeAppBar(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onAddressTap: () {},
        onSearchTap: () => _showFilterBottomSheet(context),
        onProfileTap: () => _handleTabChange(context, 2),
      );
    }

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu, color: context.textPrimary),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(_getPageTitle(currentIndex), style: context.titleSmall),
    );
  }

  Widget _buildBody(int currentIndex) {
    switch (currentIndex) {
      case 0: return const LojasView();
      case 1: return const PedidosView();
      case 2: return const PerfilView();
      default: return const LojasView();
    }
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0: return 'Lojas';
      case 1: return 'Meus Pedidos';
      case 2: return 'Perfil';
      default: return '';
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<LojasCubit>(),
        child: FilterSearchBottomSheet(
          onApplyFilters: (search, categoria, ordenacao) {
            context.read<LojasCubit>().applyFilters(
              search: search,
              categoria: categoria,
              ordenacao: ordenacao,
            );
          },
        ),
      ),
    );
  }
}
