import 'dart:developer' as developer;
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/core/theme/app_theme.dart';
import 'app/di/dependencies.dart';
import 'app/modules/auth/bloc/auth_cubit.dart';
import 'app/modules/auth/bloc/auth_state.dart';
import 'app/modules/home/bloc/address_cubit.dart';
import 'app/modules/home/bloc/localizacao_cubit.dart';
import 'app/modules/lojas_list/bloc/lojas_cubit.dart';
import 'app/modules/carrinho/bloc/carrinho_cubit.dart';
import 'app/modules/pedido/bloc/pedido_cubit.dart';
import 'app/modules/enderecos/bloc/endereco_cubit.dart';
import 'app/routes/app_router.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/theme_cubit.dart';
import 'app/core/services/fcm_service.dart';
import 'app/navigation/app_router_listener.dart';
import 'app/navigation/navigation_cubit.dart';
import 'firebase_options.dart';

// ✅ Definição global do RouteObserver para uso com RouteAware
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> setupApp() async {
  developer.log('📌 [setupApp] Iniciando...', name: 'APP');
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('✅ [setupApp] WidgetsFlutterBinding initialized', name: 'APP');

  // 🔥 INICIALIZA FIREBASE
  developer.log('📌 [setupApp] Inicializando Firebase...', name: 'APP');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  developer.log('✅ [setupApp] Firebase inicializado', name: 'APP');

  // 🔥 INICIALIZA FCM
  developer.log('📌 [setupApp] Inicializando FCM...', name: 'APP');
  await FcmService().init();
  developer.log('✅ [setupApp] FCM inicializado', name: 'APP');

  developer.log('📌 [setupApp] Configurando dependências...', name: 'APP');
  await setupDependencies();
  developer.log('✅ [setupApp] Dependências configuradas', name: 'APP');
}

Future<void> main() async {
  developer.log('🚀 [main] INICIANDO APP', name: 'APP');
  
  try {
    developer.log('📌 [main] Configurando URL Strategy...', name: 'APP');
    usePathUrlStrategy();
    
    developer.log('📌 [main] Chamando setupApp...', name: 'APP');
    await setupApp();
    
    developer.log('📌 [main] Chamando runApp...', name: 'APP');
    runApp(const QuiPedeApp());
    
    developer.log('✅ [main] APP INICIADO COM SUCESSO', name: 'APP');
  } catch (e, stack) {
    developer.log('❌ [main] ERRO FATAL: $e', name: 'APP', error: e, stackTrace: stack);
    runApp(ErrorApp(error: e.toString()));
  }

  // 🔥 SOLICITA PERMISSÃO APÓS O APP ABRIR (Evita tela branca na Web)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(const Duration(seconds: 2), () {
      FcmService().requestPermissionAndGetToken();
    });
  });
}

// ✅ WIDGET DE ERRO PARA DEBUG
class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Erro ao iniciar o aplicativo'),
                const SizedBox(height: 16),
                Text(error, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

class QuiPedeApp extends StatefulWidget {
  const QuiPedeApp({super.key});

  @override
  State<QuiPedeApp> createState() => _QuiPedeAppState();
}

class _QuiPedeAppState extends State<QuiPedeApp> {
  static bool _initialized = false;

  @override
  void initState() {
    super.initState();
    developer.log('🏗️ [QuiPedeApp] initState chamado', name: 'APP');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (_initialized) {
      developer.log('⏭️ [QuiPedeApp] Já inicializado, ignorando', name: 'APP');
      return;
    }
    _initialized = true;

    developer.log('🚀 [QuiPedeApp] INICIANDO INICIALIZAÇÃO...', name: 'APP');
    
    try {
      // ✅ Usa getIt diretamente pois providers no build ainda não estão disponíveis no initState context
      final authCubit = getIt<AuthCubit>();
      final localizacaoCubit = getIt<LocalizacaoCubit>();
      final enderecoCubit = getIt<EnderecoCubit>();
      
      developer.log('📌 [QuiPedeApp] AuthCubit carregado de getIt', name: 'APP');
      
      // ✅ Inicializa autenticação
      developer.log('📌 [QuiPedeApp] Chamando AuthCubit.inicializarApp()...', name: 'APP');
      await authCubit.inicializarApp();
      
      // ✅ Carrega endereços se estiver autenticado
      final authState = authCubit.state;
      if (authState is AuthAuthenticated || authState is AuthGuest || authState is AuthPerfilCompleto) {
        developer.log('📌 [QuiPedeApp] Carregando endereços...', name: 'APP');
        await enderecoCubit.carregarEnderecos(mostrarLoading: false);
      }

      // ✅ Inicializa localização (listener)
      developer.log('📌 [QuiPedeApp] Chamando LocalizacaoCubit.iniciarListenerEnderecos()...', name: 'APP');
      localizacaoCubit.iniciarListenerEnderecos();
      
      // ✅ Carrega endereço se estiver autenticado
      if (authState is AuthAuthenticated || authState is AuthGuest || authState is AuthPerfilCompleto) {
        developer.log('📌 [QuiPedeApp] Carregando endereço padrão...', name: 'APP');
        await localizacaoCubit.carregarLocalizacaoDoEnderecoPadrao();
      }
      
      developer.log('✅ [QuiPedeApp] INICIALIZAÇÃO CONCLUÍDA COM SUCESSO', name: 'APP');
    } catch (e, stack) {
      developer.log('❌ [QuiPedeApp] ERRO NA INICIALIZAÇÃO: $e', name: 'APP', error: e, stackTrace: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('🏗️ [QuiPedeApp] build() chamado', name: 'APP');

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<AddressCubit>(create: (_) => getIt<AddressCubit>()),
        BlocProvider<LojasCubit>(create: (_) => getIt<LojasCubit>()),
        BlocProvider<CarrinhoCubit>(create: (_) => getIt<CarrinhoCubit>()),
        BlocProvider<EnderecoCubit>(create: (_) => getIt<EnderecoCubit>()),
        BlocProvider<LocalizacaoCubit>(create: (_) => getIt<LocalizacaoCubit>()),
        BlocProvider<PedidoCubit>(create: (_) => getIt<PedidoCubit>()),
        BlocProvider<NavigationCubit>(create: (_) => getIt<NavigationCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'QuiPede',
            debugShowCheckedModeBanner: false,
            scrollBehavior: AppScrollBehavior(),
            routerConfig: appRouter,
            theme: AppTheme.lightTheme,
            themeMode: themeState.themeMode,
            builder: (context, child) {
              developer.log('🏗️ [QuiPedeApp] builder() chamado', name: 'APP');
              return AppRouterListener(child: child!);
            },
          );
        },
      ),
    );
  }
}
