// lib/shared/api/interceptors/refresh_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../app/modules/auth/bloc/auth_cubit.dart';
import '../../../app/di/dependencies.dart';
import '../../services/token_service.dart';
import '../../services/device_id_service.dart';

class RefreshInterceptor extends Interceptor {
  final Dio dio;
  final TokenService tokenService;
  final GlobalKey<NavigatorState> navigatorKey;

  static bool _isRefreshing = false;

  RefreshInterceptor({
    required this.dio,
    required this.tokenService,
    required this.navigatorKey,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      final token = tokenService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } else {
      options.headers.remove('Authorization');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ✅ Se for 401 e não for uma requisição de login/refresh
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != '/app/auth/refresh-token' &&
        err.requestOptions.path != '/app/auth/login' &&
        err.requestOptions.path != '/app/auth/phone' &&
        err.requestOptions.path != '/app/auth/verify-otp') {

      debugPrint('🔐 [RefreshInterceptor] 401 detectado, tentando refresh...');

      // ✅ Tenta refresh do token
      final refreshed = await _refreshToken();

      if (refreshed) {
        // ✅ Refaz a requisição com o novo token
        final newToken = tokenService.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // ✅ Se não conseguiu refresh, faz logout
        debugPrint('🔐 [RefreshInterceptor] ❌ Refresh falhou, fazendo logout');
        await _forceLogout();
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      // ✅ Se já está refrescando, aguarda
      await Future.delayed(const Duration(milliseconds: 500));
      return tokenService.getAccessToken() != null;
    }

    _isRefreshing = true;
    try {
      final refreshToken = tokenService.getRefreshToken();
      if (refreshToken == null) {
        debugPrint('🔐 [RefreshInterceptor] ❌ Refresh token não encontrado');
        return false;
      }

      debugPrint('🔐 [RefreshInterceptor] 🔄 Enviando refresh token...');

      final response = await dio.post(
        '/app/auth/refresh-token',
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'requiresAuth': false}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newToken = data['access_token'];

        debugPrint('🔐 [RefreshInterceptor] ✅ Token renovado com sucesso');
        debugPrint('🔐 [RefreshInterceptor] 📦 Novos dados:');
        debugPrint('   - access_token: ${newToken.substring(0, 10)}...');
        debugPrint('   - enderecos: ${data['enderecos'] != null ? "${data['enderecos'].length} endereços" : "null"}');
        debugPrint('   - usuario: ${data['usuario'] != null ? data['usuario']['nome'] : "null"}');

        // ✅ 1. SALVA O NOVO TOKEN
        await tokenService.saveAccessToken(newToken);

        // ✅ 2. SALVA O USUÁRIO (se veio)
        if (data['usuario'] != null) {
          await tokenService.saveUser(data['usuario']);
          debugPrint('🔐 [RefreshInterceptor] ✅ Usuário atualizado: ${data['usuario']['nome']}');
        }

        // ✅ 3. SALVA OS ENDEREÇOS (se veio)
        if (data['enderecos'] != null) {
          await _atualizarEnderecos(data['enderecos'], data['endereco']);
          debugPrint('🔐 [RefreshInterceptor] ✅ Endereços atualizados');
        }

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🔐 [RefreshInterceptor] ❌ Erro ao renovar token: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// ✅ ATUALIZA OS ENDEREÇOS NO AUTH CUBIT
  Future<void> _atualizarEnderecos(dynamic enderecosJson, dynamic enderecoPrincipalJson) async {
    try {
      final authCubit = getIt<AuthCubit>();
      if (authCubit != null) {
        await authCubit.atualizarEnderecos(enderecosJson, enderecoPrincipalJson);
        debugPrint('🔐 [RefreshInterceptor] ✅ Endereços sincronizados com AuthCubit');
      } else {
        debugPrint('⚠️ [RefreshInterceptor] AuthCubit não disponível');
      }
    } catch (e) {
      debugPrint('❌ [RefreshInterceptor] Erro ao atualizar endereços: $e');
    }
  }

  Future<void> _forceLogout() async {
    try {
      final authCubit = getIt<AuthCubit>();
      if (authCubit != null) {
        await authCubit.forceLogout();
        debugPrint('🔐 [RefreshInterceptor] ✅ Logout forçado realizado');
      }
    } catch (e) {
      debugPrint('🔐 [RefreshInterceptor] Erro ao chamar forceLogout: $e');
    }
  }
}