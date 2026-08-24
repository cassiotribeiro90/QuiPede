// lib/app/modules/auth/views/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../navigation/navigation_cubit.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    debugPrint('🏠 [SplashScreen] _bootstrap iniciado');

    try {
      final authCubit = context.read<AuthCubit>();
      final navigationCubit = context.read<NavigationCubit>();

      // ✅ Aguarda a inicialização do Auth
      await authCubit.inicializarApp();

      // ✅ Aguarda 500ms para garantir que o estado foi processado
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      final authState = authCubit.state;
      debugPrint('🏠 [SplashScreen] AuthState após inicialização: ${authState.runtimeType}');

      // ✅ Verifica se é autenticado
      if (authState is AuthAuthenticated) {
        debugPrint('🏠 [SplashScreen] ✅ Usuário autenticado! Navegando para Home');
        navigationCubit.goToHomeDirectly();
        return;
      }

      if (authState is AuthGuest) {
        debugPrint('🏠 [SplashScreen] ✅ Usuário convidado! Navegando para Home');
        navigationCubit.goToHomeDirectly();
        return;
      }

      if (authState is AuthUnauthenticated) {
        debugPrint('🏠 [SplashScreen] ❌ Usuário não autenticado! Navegando para Onboarding');
        navigationCubit.goToOnboarding();
        return;
      }

      // ✅ Fallback
      debugPrint('🏠 [SplashScreen] ⚠️ Estado inesperado: ${authState.runtimeType}');
      navigationCubit.goToOnboarding();

    } catch (e) {
      debugPrint('❌ [SplashScreen] Erro no bootstrap: $e');
      if (mounted) {
        context.read<NavigationCubit>().goToOnboarding();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF57C00),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 100, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'QuiPede',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Carregando...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}