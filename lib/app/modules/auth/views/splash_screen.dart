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

      // ✅ 1. Inicializa autenticação (isso emite AuthLoading)
      await authCubit.inicializarApp();

      // ✅ 2. Aguarda o estado final (não pode ser AuthLoading)
      AuthState finalState = authCubit.state;
      if (finalState is AuthLoading) {
        debugPrint('🏠 [SplashScreen] Aguardando conclusão do AuthLoading...');
        await for (final state in authCubit.stream) {
          if (state is! AuthLoading) {
            finalState = state;
            debugPrint('🏠 [SplashScreen] AuthState final recebido: ${state.runtimeType}');
            break;
          }
        }
      }

      if (!mounted) return;

      // ✅ 3. Marca o NavigationCubit como inicializado
      navigationCubit.setInitialized();

      // ✅ 4. NAVEGAÇÃO MANUAL DE SEGURANÇA (Roadmap)
      // Se o NavigationCubit não disparou a navegação via listener, forçamos aqui.
      if (finalState is AuthAuthenticated || finalState is AuthGuest || finalState is AuthPerfilCompleto) {
        debugPrint('🏠 [SplashScreen] ✅ Autenticado → Indo para Home');
        navigationCubit.goToHomeDirectly();
      } else if (finalState is AuthUnauthenticated) {
        debugPrint('🏠 [SplashScreen] ❌ Não autenticado → Indo para Onboarding');
        navigationCubit.goToOnboarding();
      }

      debugPrint('🏠 [SplashScreen] Inicialização concluída');

    } catch (e) {
      debugPrint('❌ [SplashScreen] Erro no bootstrap: $e');
      if (mounted) {
        final navigationCubit = context.read<NavigationCubit>();
        navigationCubit.setInitialized();
        navigationCubit.goToOnboarding();
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