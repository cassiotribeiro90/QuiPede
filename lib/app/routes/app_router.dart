import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/dependencies.dart';
import '../modules/auth/views/completar_perfil_page.dart';
import '../modules/auth/views/phone_input_page.dart';
import '../modules/auth/views/otp_verification_page.dart';
import '../modules/auth/views/splash_screen.dart';
import '../modules/carrinho/views/carrinho_page.dart';
import '../modules/home/bloc/home_cubit.dart';
import '../modules/home/views/endereco_confirmacao_page.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/home/views/onboarding_page.dart';
import '../modules/loja_home/views/loja_detalhe_page.dart';
import '../modules/lojas_list/bloc/lojas_cubit.dart';
import '../modules/perfil/views/pedidos_view.dart';
import '../modules/perfil/views/perfil_view.dart';
import '../modules/pedido/views/pedido_detalhe_page.dart';
import '../modules/pedido/bloc/pedido_cubit.dart';
import '../modules/enderecos/views/enderecos_list_view.dart';
import '../modules/enderecos/views/endereco_edit_view.dart';
import '../modules/enderecos/bloc/endereco_cubit.dart';
import '../modules/home/bloc/localizacao_cubit.dart';
import '../modules/home/bloc/localizacao_state.dart';
import '../modules/auth/bloc/auth_cubit.dart';
import '../modules/auth/bloc/auth_state.dart';
import '../modules/carrinho/bloc/carrinho_cubit.dart';
import '../modules/enderecos/models/endereco_model.dart';
import '../core/constants/navigation_origins.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case Routes.onboarding:
        final args = settings.arguments as Map<String, dynamic>?;
        final String? origem = args?['origem'];
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OnboardingPage(origem: origem),
        );

      case Routes.login:
        final args = settings.arguments as Map<String, dynamic>?;
        final String? origem = args?['origem'];
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PhoneInputPage(origem: origem),
        );

      case Routes.phoneInput:
        final args = settings.arguments as Map<String, dynamic>?;
        final bool redirectToCheckout = args?['redirectToCheckout'] as bool? ?? false;
        final String? origem = args?['origem'];
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PhoneInputPage(
            redirectToCheckout: redirectToCheckout,
            origem: origem,
          ),
        );

      case Routes.otpVerify:
        final args = settings.arguments as Map<String, dynamic>;
        final String phone = args['telefone'] as String;
        final bool redirectToCheckout = args['redirectToCheckout'] as bool? ?? false;
        final String? origem = args['origem'];

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OtpVerificationPage(
            telefone: phone,
            redirectToCheckout: redirectToCheckout,
            origem: origem,
          ),
        );

      case Routes.cadastro:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PhoneInputPage(),
        );

      case Routes.completarPerfil:
        final args = settings.arguments as Map<String, dynamic>?;
        final bool redirectToCheckout = args?['redirectToCheckout'] as bool? ?? false;
        final String? origem = args?['origem'];
        debugPrint('🧭 [AppRouter] Abrindo CompletarPerfilPage (redirectToCheckout: $redirectToCheckout, origem: $origem)');
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CompletarPerfilPage(
            redirectToCheckout: redirectToCheckout,
            origem: origem,
          ),
        );

      case Routes.home:
        final locCubit = getIt<LocalizacaoCubit>();
        final authCubit = getIt<AuthCubit>();
        final locState = locCubit.state;
        
        debugPrint('🏠 [AppRouter] Acessando Home. Localização: ${locState.runtimeType}');

        if (locState is LocalizacaoNaoEncontrada) {
          final authState = authCubit.state;
          if (authState is AuthAuthenticated || authState is AuthGuest || authState is AuthPerfilCompleto) {
             debugPrint('🏠 [AppRouter] Sem endereço + logado → MeusEnderecos');
             return MaterialPageRoute(
               settings: settings,
               builder: (_) => BlocProvider.value(
                 value: getIt<EnderecoCubit>(),
                 child: const EnderecosListView(),
               ),
             );
          } else {
            debugPrint('🏠 [AppRouter] Sem endereço + deslogado → Onboarding');
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const OnboardingPage(origem: NavigationOrigins.home),
            );
          }
        }

        debugPrint('🏠 [AppRouter] Montando MultiBlocProvider para HomeScreen');
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: getIt<HomeCubit>()),
              BlocProvider.value(value: getIt<LojasCubit>()),
              BlocProvider.value(value: getIt<EnderecoCubit>()),
              BlocProvider.value(value: getIt<LocalizacaoCubit>()),
              BlocProvider.value(value: getIt<AuthCubit>()),
              BlocProvider.value(value: getIt<CarrinhoCubit>()),
            ],
            child: const HomeScreen(),
          ),
        );

      case Routes.lojaHome:
        final id = settings.arguments as int?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LojaDetalhePage(lojaId: id ?? 0),
        );

      case Routes.carrinho:
        // ✅ Validação síncrona baseada no status do usuário
        final authCubit = getIt<AuthCubit>();
        final authState = authCubit.state;
        final user = authState.user;
        final args = settings.arguments as Map<String, dynamic>?;
        final String? origem = args?['origem'];

        debugPrint('🛡️ [AppRouter] processando /carrinho');
        debugPrint('🛡️ [AppRouter] authState = ${authState.runtimeType}');
        debugPrint('🛡️ [AppRouter] status = ${user?.status}');
        debugPrint('🛡️ [AppRouter] telefone = ${user?.telefone}');
        debugPrint('🛡️ [AppRouter] nome = ${user?.nome}');

        // Se não há sessão alguma, aí sim mandamos para onboarding
        if (authState is! AuthAuthenticated && authState is! AuthGuest && authState is! AuthPerfilCompleto) {
          debugPrint('🚀 [AppRouter] Sem sessão ativa → onboarding');
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => OnboardingPage(origem: origem),
          );
        }

        final String? status = user?.status;

        // 1. Convidado (sem telefone) → pedir telefone
        if (status == 'convidado') {
          debugPrint('🛡️ [AppRouter] → PhoneInput (convidado)');
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => PhoneInputPage(
              redirectToCheckout: true,
              origem: origem ?? NavigationOrigins.carrinho,
            ),
          );
        }

        // 2. Pendente (tem telefone, falta nome) → completar perfil
        if (status == 'pendente') {
          debugPrint('🛡️ [AppRouter] → CompletarPerfil (pendente)');
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => CompletarPerfilPage(
              redirectToCheckout: true,
              origem: origem ?? NavigationOrigins.carrinho,
            ),
          );
        }

        // 3. Ativo → carrinho liberado
        if (status == 'ativo') {
          debugPrint('🛡️ [AppRouter] → CarrinhoPage (ativo)');
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const CarrinhoPage(),
          );
        }

        // 🔥 Fallback seguro para usuários autenticados mas sem status definido:
        // Verificamos telefone e nome, mas NUNCA redirecionamos para Onboarding.
        debugPrint('🛡️ [AppRouter] ⚠️ Status desconhecido ou nulo ($status). Fallback para telefone/nome.');
        
        final String telefone = user?.telefone ?? '';
        final String nome = user?.nome ?? '';

        if (telefone.isEmpty) {
          debugPrint('🛡️ [AppRouter] Fallback → phoneInput');
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => PhoneInputPage(
              redirectToCheckout: true,
              origem: origem ?? NavigationOrigins.carrinho,
            ),
          );
        }
        if (nome.isEmpty) {
          debugPrint('🛡️ [AppRouter] Fallback → completarPerfil');
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => CompletarPerfilPage(
              redirectToCheckout: true,
              origem: origem ?? NavigationOrigins.carrinho,
            ),
          );
        }

        debugPrint('✅ [AppRouter] Fallback → CarrinhoPage');
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CarrinhoPage(),
        );

      case Routes.pedidos:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<PedidoCubit>(),
            child: const PedidosView(),
          ),
        );

      case Routes.pedidoDetalhe:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<PedidoCubit>()..carregarDetalhes(id),
            child: PedidoDetalhePage(pedidoId: id),
          ),
        );

      case Routes.perfil:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PerfilView(),
        );

      case Routes.meusEnderecos:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<EnderecoCubit>(),
            child: const EnderecosListView(),
          ),
        );

      case Routes.enderecoEdit:
        final endereco = settings.arguments as EnderecoModel;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<EnderecoCubit>(),
            child: EnderecoEditView(endereco: endereco),
          ),
        );

      case Routes.enderecoConfirmacao:
        final args = settings.arguments as Map<String, dynamic>;
        final enderecoMap = args['endereco'] as Map<String, dynamic>;
        final latitude = args['latitude'] as double;
        final longitude = args['longitude'] as double;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<EnderecoCubit>(),
            child: EnderecoConfirmacaoPage(
              endereco: enderecoMap,
              latitude: latitude,
              longitude: longitude,
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Rota não encontrada')),
          ),
        );
    }
  }
}