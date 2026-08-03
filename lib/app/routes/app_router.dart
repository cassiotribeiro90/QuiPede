import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/dependencies.dart';
import '../modules/auth/views/cadastro_page.dart';
import '../modules/auth/views/completar_cadastro_page.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/splash_screen.dart';
import '../modules/carrinho/views/carrinho_page.dart';
import '../modules/home/bloc/home_cubit.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/home/views/onboarding_page.dart';
import '../modules/loja_home/views/loja_detalhe_page.dart';
import '../modules/lojas_list/bloc/lojas_cubit.dart';
import '../modules/perfil/views/pedidos_view.dart';
import '../modules/perfil/views/perfil_view.dart';
import '../modules/pedido/views/pedido_detalhe_page.dart';
import '../modules/pedido/bloc/pedido_cubit.dart';
import '../modules/enderecos/views/enderecos_list_view.dart';
import '../modules/enderecos/views/endereco_form_view.dart';
import '../modules/enderecos/bloc/endereco_cubit.dart';
import '../modules/home/bloc/localizacao_cubit.dart';
import '../modules/auth/bloc/auth_cubit.dart';
import '../modules/carrinho/bloc/carrinho_cubit.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      
      case Routes.onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingPage(),
        );
      
      case Routes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case Routes.cadastro:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CadastroPage(),
        );

      case Routes.completarCadastro:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CompletarCadastroPage(),
        );

      case Routes.home:
        print('🏠 [AppRouter] Montando MultiBlocProvider para HomeScreen');
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: getIt<HomeCubit>()),
              BlocProvider.value(value: getIt<LojasCubit>()),
              BlocProvider.value(value: getIt<EnderecoCubit>()),
              BlocProvider.value(value: getIt<LocalizacaoCubit>()),
              BlocProvider.value(value: getIt<AuthCubit>()),
              BlocProvider.value(value: getIt<CarrinhoCubit>()),
            ],
            child: const HomeScreen(),
          ),
        );

      case Routes.lojaHome:
        final id = settings.arguments as int?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LojaDetalhePage(lojaId: id ?? 0),
        );

      case Routes.carrinho:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CarrinhoPage(),
        );

      case Routes.pedidos:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<PedidoCubit>(),
            child: const PedidosView(),
          ),
        );

      case Routes.pedidoDetalhe:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<PedidoCubit>()..carregarDetalhes(id),
            child: PedidoDetalhePage(pedidoId: id),
          ),
        );

      case Routes.perfil:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PerfilView(),
        );

      case Routes.meusEnderecos:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<EnderecoCubit>(),
            child: const EnderecosListView(),
          ),
        );

      case Routes.enderecoForm:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<EnderecoCubit>(),
            child: EnderecoFormView(
              endereco: args?['endereco'],
              isEditing: args?['isEditing'] ?? false,
              modo: args?['modo'],
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Rota não encontrada')),
          ),
        );
    }
  }
}
