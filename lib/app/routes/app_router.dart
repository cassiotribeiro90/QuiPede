// lib/app/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../modules/auth/bloc/auth_cubit.dart';
import '../modules/auth/bloc/auth_state.dart';

import '../../shared/api/api_client.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: ApiClient.navigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,

  redirect: (context, state) {
    // Busca o estado de autenticação
    final authState = context.read<AuthCubit>().state;

    // 🔥 VERIFICA SE ESTÁ AUTENTICADO (inclui Guest, Authenticated, PerfilCompleto)
    final isAuthenticated = authState is AuthAuthenticated ||
        authState is AuthGuest ||
        authState is AuthPerfilCompleto;

    final path = state.matchedLocation;
    debugPrint('🚦 [GoRouter Redirect] Path: $path, Auth: ${authState.runtimeType}');

    // 🔥 1. Se está carregando, fica no Splash
    if (authState is AuthLoading) {
      debugPrint('🚦 [GoRouter Redirect] AuthLoading → Mantendo Splash');
      return path == '/splash' ? null : '/splash';
    }

    // 🔥 2. Se está na splash e já terminou de carregar, o NavigationCubit vai lidar
    if (path == '/splash') return null;

    // 🔥 3. LISTA DE ROTAS PÚBLICAS (NÃO exigem autenticação completa)
    // 🔥 HOME (/) AGORA É PÚBLICA PARA CONVIDADOS
    const publicRoutes = [
      '/splash',
      '/onboarding',
      '/phone-input',
      '/otp-verify',
      '/completar-perfil',
      '/cep-input',
      '/busca-endereco',
      '/endereco-confirmacao',
      '/', // 🔥 HOME É PÚBLICA PARA CONVIDADOS
    ];

    final isPublic = publicRoutes.any((route) => path.startsWith(route));

    // 🔥 4. Se é pública, permite o acesso (inclusive Home para convidados)
    if (isPublic) {
      debugPrint('🚦 [GoRouter Redirect] Rota pública: $path → permitir');
      return null;
    }

    // 🔥 5. Se NÃO está autenticado e tenta acessar rota privada → /onboarding
    if (!isAuthenticated && !isPublic) {
      debugPrint('🚦 [GoRouter Redirect] Não autenticado em rota protegida: $path → Onboarding');
      return '/onboarding';
    }

    // 🔥 6. Se está autenticado e na raiz, mantém
    if (isAuthenticated && path == '/') {
      debugPrint('🚦 [GoRouter Redirect] Autenticado na raiz → mantendo');
      return null;
    }

    return null;
  },

  routes: [
    // ============================================================
    // 🔥 ROTAS PÚBLICAS (NÃO exigem autenticação)
    // ============================================================

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
      builder: (context, state) {
        final queryParams = state.uri.queryParameters;
        final redirectToCheckout = queryParams['redirectToCheckout'] == 'true';
        final origem = queryParams['origem'];

        return PhoneInputPage(
          redirectToCheckout: redirectToCheckout,
          origem: origem,
        );
      },
    ),
    GoRoute(
      path: '/otp-verify',
      name: 'otp-verify',
      builder: (context, state) {
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
      builder: (context, state) {
        final queryParams = state.uri.queryParameters;
        final redirectToCheckout = queryParams['redirectToCheckout'] == 'true';
        final origem = queryParams['origem'];

        return CompletarPerfilPage(
          redirectToCheckout: redirectToCheckout,
          origem: origem,
        );
      },
    ),

    // ============================================================
    // 🔥 ROTAS PÚBLICAS DE ENDEREÇO (com parentNavigatorKey)
    // ============================================================

    GoRoute(
      path: '/busca-endereco',
      name: 'busca-endereco',
      parentNavigatorKey: ApiClient.navigatorKey,
      builder: (context, state) => const BuscaEnderecoPage(),
    ),
    GoRoute(
      path: '/cep-input',
      name: 'cep-input',
      parentNavigatorKey: ApiClient.navigatorKey,
      builder: (context, state) => const CepInputPage(),
    ),

    // ============================================================
    // 🔥 ROTAS PROTEGIDAS (exigem autenticação completa)
    // ============================================================

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

    // ============================================================
    // 🔥 ROTA HOME (com sub-rotas)
    // ============================================================

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