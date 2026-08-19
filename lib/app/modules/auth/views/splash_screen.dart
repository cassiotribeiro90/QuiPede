import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../bloc/auth_cubit.dart';
import '../../../routes/app_routes.dart';
import '../../../di/dependencies.dart';
import '../../../services/navigation_service.dart';
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

    final authCubit = context.read<AuthCubit>();
    final localizacaoCubit = context.read<LocalizacaoCubit>();

    // 1. Autentica
    await authCubit.inicializarApp();

    // ✅ Inicia listener de endereços
    localizacaoCubit.iniciarListenerEnderecos();

    // 2. Carrega localização (apenas se autenticado)
    final authState = authCubit.state;
    if (authState is AuthAuthenticated || authState is AuthGuest) {
      await localizacaoCubit.carregarLocalizacaoDoEnderecoPadrao();
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // 3. Navega
    final locState = localizacaoCubit.state;
    final targetRoute = locState is LocalizacaoCarregada
        ? Routes.home
        : Routes.onboarding;

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == targetRoute) return;

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