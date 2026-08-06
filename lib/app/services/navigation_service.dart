import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationService(this.navigatorKey);

  // --- Navegações básicas ---

  void goToSplash() => pushNamedAndRemoveAll(Routes.splash);
  void goToOnboarding() => pushNamedAndRemoveAll(Routes.onboarding);
  void goToHome() => pushNamedAndRemoveAll(Routes.home);
  void goToLogin() => pushNamed(Routes.login);
  
  void goToPhoneInput({bool redirectToCheckout = false}) {
    pushNamed(Routes.phoneInput, arguments: redirectToCheckout);
  }

  void goToOtpVerify(String phone, {bool redirectToCheckout = false}) {
    pushNamed(Routes.otpVerify, arguments: {
      'telefone': phone,
      'redirectToCheckout': redirectToCheckout,
    });
  }

  void goToCompletarPerfil({bool redirectToCheckout = false}) {
    pushNamed(Routes.completarPerfil, arguments: redirectToCheckout);
  }

  void goToCarrinho() => pushNamed(Routes.carrinho);
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

  Future<T?> pushNamedAndRemoveAll<T>(String route) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(route, (r) => false);
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
