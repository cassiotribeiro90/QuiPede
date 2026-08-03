import 'package:flutter/material.dart';
import '../../app/di/dependencies.dart';
import '../services/token_service.dart';
import '../../app/modules/auth/bloc/auth_cubit.dart';

class AuthObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _checkTokenExpiration();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _checkTokenExpiration();
  }

  void _checkTokenExpiration() {
    final tokenService = getIt<TokenService>();
    
    // ✅ Se token expirou, limpa e sincroniza o estado do Cubit de Autenticação.
    if (tokenService.hasToken() && tokenService.isTokenExpired()) {
      debugPrint('⚠️ [AuthObserver] Token expirado, limpando e sincronizando estado...');
      tokenService.clearTokens();
      
      // Notifica o Cubit para atualizar a UI para o estado deslogado ou guest
      getIt<AuthCubit>().checkAuthStatus();
    }
  }
}
