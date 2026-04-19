import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/dependencies.dart';
import '../modules/auth/views/cadastro_page.dart';
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
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case Routes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case Routes.cadastro:
        return MaterialPageRoute(builder: (_) => const CadastroPage());

      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: getIt<HomeCubit>()),
              BlocProvider.value(value: getIt<LojasCubit>()),
            ],
            child: const HomeScreen(),
          ),
        );

      case Routes.lojaHome:
        final id = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => LojaDetalhePage(lojaId: id ?? 0),
        );

      case Routes.carrinho:
        return MaterialPageRoute(builder: (_) => const CarrinhoPage());

      case Routes.pedidos:
        return MaterialPageRoute(builder: (_) => const PedidosView());

      case Routes.perfil:
        return MaterialPageRoute(builder: (_) => const PerfilView());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Rota não encontrada')),
          ),
        );
    }
  }
}
