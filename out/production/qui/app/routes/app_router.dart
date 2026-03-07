import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../modules/home/cubit/home_cubit.dart';
import '../modules/home/views/home_view.dart';
import '../modules/loja_avaliacoes/cubit/loja_avaliacoes_cubit.dart';
import '../modules/loja_avaliacoes/views/loja_avaliacoes_view.dart';
import '../modules/splash/cubit/splash_cubit.dart';
import '../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.SPLASH:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => SplashCubit(),
            child: const SplashView(),
          ),
        );
      case Routes.HOME:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => HomeCubit(),
            child: const HomeView(),
          ),
        );
      case Routes.LOJA_AVALIACOES:
        // Pega o id da loja passado como argumento
        final lojaId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            // Cria o Cubit específico para a loja selecionada
            create: (context) => LojaAvaliacoesCubit(lojaId),
            child: const LojaAvaliacoesView(),
          ),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}
