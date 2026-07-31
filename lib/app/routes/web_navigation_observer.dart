import 'package:flutter/material.dart';

class WebNavigationObserver extends NavigatorObserver {
  static final List<String> _history = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _history.add(route.settings.name ?? '/');
    print('📌 [WebNav] Push: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (_history.isNotEmpty) {
      _history.removeLast();
    }
    print('📌 [WebNav] Pop: ${route.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (_history.isNotEmpty) {
      _history.removeLast();
    }
    print('📌 [WebNav] Remove: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (_history.isNotEmpty) {
      _history.removeLast();
    }
    if (newRoute != null) {
      _history.add(newRoute.settings.name ?? '/');
    }
    print('📌 [WebNav] Replace: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
  }

  static bool canPop() {
    return _history.length > 1;
  }

  static String? getCurrentRoute() {
    return _history.isNotEmpty ? _history.last : null;
  }

  static void clearHistory() {
    _history.clear();
    _history.add('/');
  }
}
