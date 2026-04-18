import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../bloc/auth_cubit.dart';
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
    print('🎬 [SplashScreen] Iniciando inicialização...');
    
    // 1. Verificar autenticação silenciosamente
    final authCubit = context.read<AuthCubit>();
    await authCubit.checkAuthStatus();
    
    // 2. Verificar se já existe um endereço definido (salvo localmente)
    final localizacaoCubit = context.read<LocalizacaoCubit>();
    await localizacaoCubit.carregarLocalizacaoDoEnderecoPadrao();
    
    // Tempo mínimo para a splash ser visível e passar sensação de carregamento
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      final hasLocation = localizacaoCubit.state is LocalizacaoCarregada;
      
      print('🚀 [Navigation] Endereço definido: $hasLocation');

      String targetRoute;
      
      // Regra: Se não tem localização definida, SEMPRE vai para Onboarding
      if (!hasLocation) {
        targetRoute = Routes.onboarding;
      } else {
        // Se tem localização, vai para a Home (Lojas)
        targetRoute = Routes.home;
      }

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
