import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/di/dependencies.dart';

class AuthObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _checkToken(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _checkToken(newRoute);
  }

  void _checkToken(Route<dynamic> route) {
    // Lista de rotas que não precisam de autenticação
    const publicRoutes = ['/login', '/splash', '/register'];
    
    if (publicRoutes.contains(route.settings.name)) return;

    final prefs = getIt<SharedPreferences>();
    final token = prefs.getString('access_token');

    if (token == null) {
      // Redirecionar para login se não houver token
      // Nota: O Navigator pode precisar de um delay ou usar uma chave global
      Future.microtask(() {
        navigator?.pushNamedAndRemoveUntil('/login', (route) => false);
      });
    }
  }
}
