import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../services/token_service.dart';

class RefreshInterceptor extends Interceptor {
  final Dio dio;
  final TokenService tokenService;
  final GlobalKey<NavigatorState> navigatorKey;

  RefreshInterceptor({
    required this.dio,
    required this.tokenService,
    required this.navigatorKey,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 🔥 VERIFICA SE REQUER AUTENTICAÇÃO
    final requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      final token = tokenService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } else {
      // 🔥 REMOVE O HEADER DE AUTENTICAÇÃO SE NÃO FOR NECESSÁRIO
      options.headers.remove('Authorization');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Verifica se é erro 401 e se há token
    if (err.response?.statusCode == 401) {
      final refreshToken = tokenService.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Tenta renovar o token
          final success = await tokenService.refreshToken(dio);

          if (success) {
            // Repete a requisição original com o novo token
            final newToken = tokenService.getAccessToken();
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

            final response = await dio.fetch(err.requestOptions);
            return handler.resolve(response);
          }
        } catch (e) {
          // Falha no refresh
        }
      }

      // Se não tem refresh token ou falhou, redireciona para login
      _redirectToLogin();
    }

    handler.next(err);
  }

  void _redirectToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Usa um postFrameCallback para evitar problemas de navegação durante a construção
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Implemente sua navegação para login
        // Navigator.pushReplacementNamed(context, Routes.login);
      });
    }
  }
}