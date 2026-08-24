// lib/app/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modules/auth/views/splash_screen.dart';
import '../modules/auth/views/phone_input_page.dart';
import '../modules/auth/views/otp_verification_page.dart';
import '../modules/auth/views/completar_perfil_page.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/home/views/onboarding_page.dart';
import '../modules/loja_home/views/loja_detalhe_page.dart';
import '../modules/carrinho/views/carrinho_page.dart';
import '../modules/perfil/views/pedidos_view.dart';
import '../modules/perfil/views/perfil_view.dart';
import '../modules/enderecos/views/enderecos_list_view.dart';
import '../modules/home/views/busca_endereco_page.dart';
import '../modules/home/views/cep_input_page.dart';
import '../modules/home/views/endereco_confirmacao_page.dart';
import '../modules/enderecos/views/endereco_edit_view.dart';
import '../modules/pedido/views/pedido_detalhe_page.dart';
import '../modules/enderecos/models/endereco_model.dart';

import '../../shared/api/api_client.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: ApiClient.navigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,

  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/phone-input',
      name: 'phone-input',
      builder: (context, state) => const PhoneInputPage(),
    ),
    // lib/app/routes/app_router.dart

    // lib/app/routes/app_router.dart

    GoRoute(
      path: '/otp-verify',
      name: 'otp-verify',
      builder: (context, state) {
        // ✅ CORRETO: usa state.uri.queryParameters
        final queryParams = state.uri.queryParameters;
        final telefone = queryParams['telefone'] ?? '';
        final redirectToCheckout = queryParams['redirectToCheckout'] == 'true';
        final origem = queryParams['origem'];

        debugPrint('🔍 [GoRouter] OtpVerificationPage - telefone: "$telefone"');
        debugPrint('🔍 [GoRouter] OtpVerificationPage - queryParams: $queryParams');

        return OtpVerificationPage(
          telefone: telefone,
          redirectToCheckout: redirectToCheckout,
          origem: origem,
        );
      },
    ),
    GoRoute(
      path: '/completar-perfil',
      name: 'completar-perfil',
      builder: (context, state) => const CompletarPerfilPage(),
    ),
    GoRoute(
      path: '/pedidos',
      name: 'pedidos',
      builder: (context, state) => const PedidosView(),
      routes: [
        GoRoute(
          path: 'detalhe/:id',
          name: 'pedido-detalhe',
          builder: (context, state) {
            final idStr = state.pathParameters['id'] ?? '0';
            final id = int.tryParse(idStr) ?? 0;
            return PedidoDetalhePage(pedidoId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'loja/:id',
          name: 'loja-home',
          builder: (context, state) {
            final idStr = state.pathParameters['id'] ?? '0';
            final id = int.tryParse(idStr) ?? 0;
            return LojaDetalhePage(lojaId: id);
          },
        ),
        GoRoute(
          path: 'carrinho',
          name: 'carrinho',
          builder: (context, state) => const CarrinhoPage(),
        ),
        GoRoute(
          path: 'perfil',
          name: 'perfil',
          builder: (context, state) => const PerfilView(),
        ),
        GoRoute(
          path: 'meus-enderecos',
          name: 'meus-enderecos',
          builder: (context, state) => const EnderecosListView(),
        ),
        GoRoute(
          path: 'busca-endereco',
          name: 'busca-endereco',
          builder: (context, state) => const BuscaEnderecoPage(),
        ),
        GoRoute(
          path: 'cep-input',
          name: 'cep-input',
          builder: (context, state) => const CepInputPage(),
        ),
        GoRoute(
          path: 'endereco-confirmacao',
          name: 'endereco-confirmacao',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/busca-endereco');
              });
              return const SizedBox.shrink();
            }
            final endereco = extra['endereco'] as Map<String, dynamic>? ?? {};
            final latitude = extra['latitude'] as double? ?? 0.0;
            final longitude = extra['longitude'] as double? ?? 0.0;
            return EnderecoConfirmacaoPage(
              endereco: endereco,
              latitude: latitude,
              longitude: longitude,
            );
          },
        ),
        GoRoute(
          path: 'endereco-edit',
          name: 'endereco-edit',
          builder: (context, state) {
            final endereco = state.extra as EnderecoModel?;
            return EnderecoEditView(endereco: endereco);
          },
        ),
      ],
    ),
  ],
);