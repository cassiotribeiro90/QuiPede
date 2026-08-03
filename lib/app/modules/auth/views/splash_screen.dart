import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    debugPrint('🎬 [SplashScreen] Iniciando inicialização do app...');
    
    final authCubit = context.read<AuthCubit>();
    final localizacaoCubit = context.read<LocalizacaoCubit>();

    // 1. Inicializar estado de autenticação e restaurar sessão (Guest ou Real)
    // O inicializarApp já cuida de carregar os endereços se houver token
    await authCubit.inicializarApp();
    
    // 2. Tentar carregar localização local caso o AuthCubit não tenha encontrado endereços remotos
    // (Útil para usuários que definiram localização mas não criaram conta/token ainda)
    if (localizacaoCubit.state is! LocalizacaoCarregada) {
      await localizacaoCubit.carregarLocalizacaoDoEnderecoPadrao();
    }
    
    // Tempo mínimo estético
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      final hasLocation = localizacaoCubit.state is LocalizacaoCarregada;
      debugPrint('🚀 [SplashScreen] Inicialização concluída. Localização ativa: $hasLocation');

      // REGRA: Sem endereço -> Onboarding | Com endereço -> Home
      final targetRoute = hasLocation ? Routes.home : Routes.onboarding;

      Navigator.of(context).pushNamedAndRemoveUntil(targetRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF57C00),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'QuiPede',
              style: TextStyle(
                fontSize: 40, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
