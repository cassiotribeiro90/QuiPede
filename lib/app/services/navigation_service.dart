import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationService(this.navigatorKey);

  // --- Navegações básicas ---

  void goToSplash() => pushNamedAndRemoveAll(Routes.splash);
  void goToOnboarding({String? origem}) => pushNamedAndRemoveAll(Routes.onboarding, arguments: {'origem': origem});
  void goToHome() => pushNamedAndRemoveAll(Routes.home);
  void goToLogin({String? origem}) => pushNamed(Routes.login, arguments: {'origem': origem});
  
  void goToPhoneInput({bool redirectToCheckout = false, String? origem}) {
    pushNamed(Routes.phoneInput, arguments: {
      'redirectToCheckout': redirectToCheckout,
      'origem': origem,
    });
  }

  void goToOtpVerify(String phone, {bool redirectToCheckout = false, String? origem}) {
    pushNamed(Routes.otpVerify, arguments: {
      'telefone': phone,
      'redirectToCheckout': redirectToCheckout,
      'origem': origem,
    });
  }

  void goToCompletarPerfil({bool redirectToCheckout = false, String? origem}) {
    pushNamed(Routes.completarPerfil, arguments: {
      'redirectToCheckout': redirectToCheckout,
      'origem': origem,
    });
  }

  void goToCarrinho({String? origem}) => pushNamed(Routes.carrinho, arguments: {'origem': origem});
  void goToMeusEnderecos() => pushNamed(Routes.meusEnderecos);
  void goToEnderecoEdit(dynamic endereco) => pushNamed(Routes.enderecoEdit, arguments: endereco);
  void goToLojaHome(int lojaId) => pushNamed(Routes.lojaHome, arguments: lojaId);
  void goToPedidoDetalhe(int pedidoId) => pushNamed(Routes.pedidoDetalhe, arguments: pedidoId);
  void goToPerfil() => pushNamed(Routes.perfil);

  void goToHomeAndRemoveAll() => pushNamedAndRemoveAll(Routes.home);
  void goToCarrinhoAndRemoveAll() => pushNamedAndRemoveAll(Routes.carrinho);

  // --- Métodos de navegação ---

  Future<T?> pushNamed<T>(String route, {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(route, arguments: arguments);
  }

  Future<T?> pushReplacementNamed<T, TO>(String route, {dynamic arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(route, arguments: arguments);
  }

  Future<T?> pushNamedAndRemoveAll<T>(String route, {dynamic arguments}) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return Future.value(null);
    
    return navigator.pushNamedAndRemoveUntil<T>(route, (r) => false, arguments: arguments);
  }

  Future<T?> pushNamedAndRemoveUntil<T>(String route, RoutePredicate predicate, {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(route, predicate, arguments: arguments);
  }

  void pop<T>([T? result]) {
    navigatorKey.currentState?.pop(result);
  }

  void popUntil(String route) {
    navigatorKey.currentState?.popUntil((r) => r.settings.name == route || r.isFirst);
  }

  bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }
}
