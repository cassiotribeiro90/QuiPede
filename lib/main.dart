import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/core/theme/app_theme.dart';
import 'app/di/dependencies.dart';
import 'app/modules/auth/bloc/auth_cubit.dart';
import 'app/modules/home/bloc/address_cubit.dart';
import 'app/modules/home/bloc/localizacao_cubit.dart';
import 'app/modules/lojas_list/bloc/lojas_cubit.dart';
import 'app/modules/carrinho/bloc/carrinho_cubit.dart';
import 'app/modules/pedido/bloc/pedido_cubit.dart';
import 'app/modules/enderecos/bloc/endereco_cubit.dart';
import 'app/routes/app_router.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/web_navigation_observer.dart';
import 'app/theme/theme_cubit.dart';
import 'shared/auth/auth_observer.dart';
import 'app/core/services/fcm_service.dart';
import 'firebase_options.dart';  // 🔥 DEVE ESTAR AQUI

// ✅ Definição global do RouteObserver para uso com RouteAware
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> setupApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 INICIALIZA FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 INICIALIZA FCM
  await FcmService().init();

  await setupDependencies();
}

Future<void> main() async {
  await setupApp();
  runApp(const QuiPedeApp());
}

class QuiPedeApp extends StatelessWidget {
  const QuiPedeApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'QuiPede',
            debugShowCheckedModeBanner: false,
            navigatorKey: getIt<GlobalKey<NavigatorState>>(),
            theme: AppTheme.lightTheme,
            themeMode: themeState.themeMode,
            initialRoute: Routes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
            navigatorObservers: [
              AuthObserver(),
              if (kIsWeb) WebNavigationObserver(),
              routeObserver, // ✅ Adicionado observer para RouteAware
            ],
            builder: (context, child) {
              return child!;
            },
          );
        },
      ),
    );
  }
}
