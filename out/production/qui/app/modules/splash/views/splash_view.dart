import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_routes.dart';
import '../cubit/splash_cubit.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicia o processo de carregamento
    context.read<SplashCubit>().loadAndNavigate();

    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        // Navega para a home quando o estado correto for emitido
        if (state is SplashNavigateToHome) {
          Navigator.of(context).pushReplacementNamed(Routes.HOME);
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
