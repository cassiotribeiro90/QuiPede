import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
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
    // 1. Verificar autenticação ativamente com o backend
    final authCubit = context.read<AuthCubit>();
    await authCubit.checkAuthStatus();
    
    // 2. Solicitar permissão de localização e obter posição
    final localizacaoCubit = context.read<LocalizacaoCubit>();
    
    // Tenta carregar do endereço padrão primeiro (mais rápido)
    await localizacaoCubit.carregarLocalizacaoDoEnderecoPadrao();
    
    // Se não tiver endereço padrão, tenta o GPS
    if (localizacaoCubit.state is! LocalizacaoCarregada) {
      final status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          try {
            final posicao = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 5),
              ),
            );
            localizacaoCubit.atualizarPosicao(posicao);
          } catch (e) {
            print('📍 [SplashScreen] Erro ao obter GPS: $e');
          }
        }
      }
    }

    // Aguarda um pequeno delay para garantir que a Splash seja visível por um tempo mínimo
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. Determinar rota inicial baseada na árvore de decisão
    if (mounted) {
      final authState = authCubit.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final hasLocation = localizacaoCubit.state is LocalizacaoCarregada;

      print('🚀 [Navigation] Auth: $isAuthenticated, Location: $hasLocation');

      String initialRoute;
      
      if (!isAuthenticated) {
        // Usuário não autenticado -> Login
        initialRoute = Routes.login;
      } else {
        // Usuário autenticado
        if (!hasLocation) {
          // Usuário autenticado mas sem localização -> Home (que deve lidar com a falta de endereço ou abrir modal)
          // Se houver uma tela específica de "Cadastrar Endereço", redirecionar para ela.
          initialRoute = Routes.home; 
        } else {
          // Usuário autenticado e com localização -> Lista de Lojas (Home)
          initialRoute = Routes.home;
        }
      }

      Navigator.of(context).pushNamedAndRemoveUntil(initialRoute, (route) => false);
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
