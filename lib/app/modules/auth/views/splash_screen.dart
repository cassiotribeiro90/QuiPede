import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../bloc/auth_cubit.dart';
import '../../../routes/app_routes.dart';
import '../../../di/dependencies.dart';
import '../../../services/navigation_service.dart';

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
    // Evita executar duas vezes (hot restart reconstrói o widget)
    if (_bootstrapped) return;
    _bootstrapped = true;

    final authCubit = context.read<AuthCubit>();
    final localizacaoCubit = context.read<LocalizacaoCubit>();

    await authCubit.inicializarApp();

    if (localizacaoCubit.state is! LocalizacaoCarregada) {
      await localizacaoCubit.carregarLocalizacaoDoEnderecoPadrao();
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final hasLocation = localizacaoCubit.state is LocalizacaoCarregada;
    final targetRoute = hasLocation ? Routes.home : Routes.onboarding;

    // ✅ Verifica se já está na rota de destino para evitar push duplicado
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == targetRoute) {
      debugPrint('🛑 [SplashScreen] Já está na rota $targetRoute, ignorando navegação');
      return;
    }

    getIt<NavigationService>().pushNamedAndRemoveAll(targetRoute);
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
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}