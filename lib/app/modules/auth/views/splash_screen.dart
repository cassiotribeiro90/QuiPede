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
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authCubit = context.read<AuthCubit>();
    final localizacaoCubit = context.read<LocalizacaoCubit>();

    // Inicializa autenticação (recupera sessão, endereços remotos etc.)
    await authCubit.inicializarApp();

    // Carrega localização local se necessário (executa em paralelo se possível,
    // mas aqui depende do authCubit ter terminado, então mantemos sequencial).
    if (localizacaoCubit.state is! LocalizacaoCarregada) {
      await localizacaoCubit.carregarLocalizacaoDoEnderecoPadrao();
    }

    // Tempo mínimo para transição suave (evita flash)
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final hasLocation = localizacaoCubit.state is LocalizacaoCarregada;
    final targetRoute = hasLocation ? Routes.home : Routes.onboarding;

    // Navegação sem animação para dar percepção de velocidade
    Navigator.of(context).pushNamedAndRemoveUntil(
      targetRoute,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF57C00),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone simples, mas sugiro usar sua logo em PNG para qualidade
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
            // Removido o CircularProgressIndicator.
            // Se quiser um feedback sutil, pode usar um pequeno ponto animado,
            // mas não é necessário para um MVP.
            SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}