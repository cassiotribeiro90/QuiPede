// lib/app/di/dependencies.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/loja_home/repository/loja_repository.dart';
import '../modules/lojas_list/repository/loja_repository.dart';
import '../modules/lojas_list/repository/loja_repository_impl.dart';
import '../modules/home/bloc/address_cubit.dart';
import '../modules/home/bloc/home_cubit.dart';
import '../modules/home/bloc/localizacao_cubit.dart';
import '../modules/lojas_list/bloc/lojas_cubit.dart';
import '../modules/auth/bloc/auth_cubit.dart';
import '../theme/theme_cubit.dart';
import '../../shared/api/api_client.dart';
import '../../shared/services/token_service.dart';
import '../modules/loja_home/bloc/loja_home_cubit.dart';
import '../modules/carrinho/bloc/carrinho_cubit.dart';
import '../modules/carrinho/services/carrinho_service.dart';
import '../modules/pedido/services/pedido_service.dart';
import '../modules/pedido/bloc/pedido_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // ✅ 1. Inicializar TokenService
  await TokenService.initialize();
  getIt.registerSingleton<TokenService>(TokenService());

  // ✅ 2. Navigator Key
  getIt.registerSingleton<GlobalKey<NavigatorState>>(ApiClient.navigatorKey);

  // ✅ 3. ApiClient (baixo nível)
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // ✅ 4. Services
  getIt.registerLazySingleton<CarrinhoService>(() => CarrinhoService(getIt<ApiClient>()));
  getIt.registerLazySingleton<PedidoService>(() => PedidoService(getIt<ApiClient>()));

  // ✅ 5. Repositories
  getIt.registerLazySingleton<LojaRepository>(() => LojaRepositoryImpl(getIt<ApiClient>()));
  getIt.registerLazySingleton<LojaHomeRepository>(() => LojaHomeRepository(getIt<ApiClient>()));

  // ✅ 6. ThemeCubit (independente)
  getIt.registerSingleton<ThemeCubit>(ThemeCubit(getIt<SharedPreferences>()));

  // ✅ 7. LocalizacaoCubit (Necessário para o AuthCubit)
  getIt.registerSingleton<LocalizacaoCubit>(LocalizacaoCubit(getIt<SharedPreferences>()));

  // ✅ 8. AuthCubit (Depende do ApiClient e do LocalizacaoCubit)
  getIt.registerSingleton<AuthCubit>(
    AuthCubit(
      getIt<ApiClient>(),
      getIt<LocalizacaoCubit>(),
    ),
  );

  // ✅ 9. CarrinhoCubit (depende do AuthCubit)
  getIt.registerSingleton<CarrinhoCubit>(
    CarrinhoCubit(
      getIt<CarrinhoService>(),
      getIt<AuthCubit>(),
      getIt<SharedPreferences>(),
    ),
  );

  // ✅ 10. PedidoCubit
  getIt.registerFactory(() => PedidoCubit(getIt<PedidoService>()));

  // ✅ 11. Outros Cubits
  getIt.registerFactory(() => AddressCubit());
  getIt.registerFactory(() => HomeCubit());

  getIt.registerFactory(() => LojasCubit(
    getIt<LojaRepository>(),
    getIt<LocalizacaoCubit>(),
  ));

  getIt.registerFactoryParam<LojaHomeCubit, int, void>(
        (lojaId, _) => LojaHomeCubit(getIt<LojaHomeRepository>(), lojaId),
  );

  print('✅ [DI] setupDependencies concluído');
}
