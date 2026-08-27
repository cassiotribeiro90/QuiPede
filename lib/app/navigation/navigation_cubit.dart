// lib/app/navigation/navigation_cubit.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../modules/auth/bloc/auth_cubit.dart';
import '../modules/auth/bloc/auth_state.dart';
import '../modules/home/bloc/localizacao_cubit.dart';
import '../modules/home/bloc/localizacao_state.dart';
import '../routes/app_routes.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  final AuthCubit authCubit;
  final LocalizacaoCubit localizacaoCubit;
  late final StreamSubscription _authSubscription;
  late final StreamSubscription _locSubscription;

  bool _isRedirectingToCheckout = false;
  String? _pendingOrigem;
  bool _isInitialized = false;

  // 🔥 FILA DE NAVEGAÇÃO PARA REDIRECIONAMENTO
  String? _pendingRoute;
  Map<String, String>? _pendingRouteParams;

  NavigationCubit({
    required this.authCubit,
    required this.localizacaoCubit,
  }) : super(const NavigationState.idle()) {
    debugPrint('🔴 [NavigationCubit] 🏗️ CONSTRUTOR CHAMADO');
    _authSubscription = authCubit.stream.listen((authState) {
      debugPrint('🔴 [NavigationCubit] 📡 AuthState recebido no stream: ${authState.runtimeType}');
      _handleAuthChange(authState);
    });
    _locSubscription = localizacaoCubit.stream.listen((locState) {
      _handleLocalizacaoChange(locState);
    });
  }

  // 🔥 SALVA A ROTA PENDENTE
  void savePendingRoute(String route, {Map<String, String>? params}) {
    _pendingRoute = route;
    _pendingRouteParams = params;
    debugPrint('🧭 [NavigationCubit] Rota pendente salva: $route');
  }

  // 🔥 EXECUTA A ROTA PENDENTE (se existir)
  Future<void> executePendingRoute() async {
    if (_pendingRoute != null) {
      debugPrint('🧭 [NavigationCubit] Executando rota pendente: $_pendingRoute');
      final route = _pendingRoute!;
      _pendingRoute = null;
      final params = _pendingRouteParams;
      _pendingRouteParams = null;
      
      // 🔥 Pequeno delay para garantir que a UI está pronta
      await Future.delayed(const Duration(milliseconds: 300));
      _go(route, queryParams: params);
    }
  }

  /// 🔥 Marca o app como inicializado e processa navegação inicial
  void setInitialized() {
    debugPrint('🧭 [NavigationCubit] 🔥 APP MARCADO COMO INICIALIZADO');
    _isInitialized = true;
    
    // 🔥 Se já terminou de carregar o Auth, decide para onde ir imediatamente
    final authState = authCubit.state;
    if (authState is! AuthLoading) {
      debugPrint('🧭 [NavigationCubit] AuthState atual: ${authState.runtimeType} → Processando navegação inicial');
      _handleAuthChange(authState);
    }
  }

  // --- Gerenciamento de estado interno ---

  void setInitialPath(String path) {
    debugPrint('📍 [NavigationCubit] Sincronizando path inicial: $path');
    emit(NavigationState.pushTo(path));
  }

  void _handleAuthChange(AuthState authState) {
    debugPrint('🔴 [NavigationCubit] _handleAuthChange: ${authState.runtimeType}');
    
    if (isClosed) return;

    // 🔥 Só navega depois que o app estiver inicializado
    if (!_isInitialized) {
      debugPrint('🧭 [NavigationCubit] App não inicializado, ignorando navegação');
      return;
    }

    // 🔥 AuthLoading não navega (mantém Splash)
    if (authState is AuthLoading) {
      debugPrint('🧭 [NavigationCubit] AuthLoading detectado, mantendo Splash');
      return;
    }

    final currentPath = state.path;
    debugPrint('🔴 [NavigationCubit] Path atual no estado: $currentPath');

    // 1. PRIORIDADE: NÃO AUTENTICADO
    if (authState is AuthUnauthenticated) {
      debugPrint('🔴 [NavigationCubit] 🔥 AuthUnauthenticated detectado!');
      _isRedirectingToCheckout = false;
      _pendingOrigem = null;

      // Se não sabemos o path (null) ou não estamos em rota pública, vai para onboarding
      final publicRoutes = [Routes.onboarding, Routes.phoneInput, Routes.otpVerify, Routes.splash];
      if (currentPath == null || !publicRoutes.contains(currentPath)) {
        debugPrint('🧭 [NavigationCubit] Redirecionando para Onboarding');
        emit(const NavigationState.goTo(Routes.onboarding));
      }
      return;
    }

    // 2. AUTH PHONE ENVIADO (Fluxo intermediário)
    if (authState is AuthPhoneEnviado) {
      if (currentPath != Routes.otpVerify) {
        debugPrint('🧭 [NavigationCubit] AuthPhoneEnviado → OTP');
        emit(NavigationState.pushTo(
          Routes.otpVerify,
          queryParams: {
            'telefone': authState.telefone,
            if (_isRedirectingToCheckout) 'redirectToCheckout': 'true',
            if (_pendingOrigem != null) 'origem': _pendingOrigem!,
          },
        ));
      }
      return;
    }

    // 3. AUTENTICADO
    if (authState is AuthAuthenticated || authState is AuthPerfilCompleto || authState is AuthGuest) {
      debugPrint('🔴 [NavigationCubit] 🔥 Auth State (${authState.runtimeType}) detectado!');
      
      final user = authState.user;
      
      // Se perfil pendente → Completar Perfil (Exceto se for AuthGuest)
      if (authState is! AuthGuest && user != null && (user.status == 'pendente' || user.nome.isEmpty)) {
        if (currentPath != Routes.completarPerfil) {
          debugPrint('🧭 [NavigationCubit] Perfil incompleto → Completar Perfil');
          emit(const NavigationState.goTo(Routes.completarPerfil));
        }
        return;
      }

      // 🔥 EXECUTA ROTA PENDENTE SE EXISTIR
      if (_pendingRoute != null) {
        debugPrint('🧭 [NavigationCubit] Finalizando fluxo de autenticação, executando rota pendente: $_pendingRoute');
        executePendingRoute();
        return;
      }

      // Se estiver em rota de Onboarding/Splash ou se o path inicial ainda não foi sincronizado → Decide para onde ir
      final onboardingFlowRoutes = [Routes.splash, Routes.onboarding, Routes.phoneInput, Routes.otpVerify];
      if (currentPath == null || onboardingFlowRoutes.contains(currentPath)) {
        if (_isRedirectingToCheckout) {
          _isRedirectingToCheckout = false;
          _pendingOrigem = null;
          emit(const NavigationState.goTo(Routes.carrinho));
        } else {
          debugPrint('🧭 [NavigationCubit] No Onboarding/Splash → Verificando endereço para Home');
          final locState = localizacaoCubit.state;
          if (locState is LocalizacaoCarregada) {
            goToHomeDirectly();
          } else {
            debugPrint('🧭 [NavigationCubit] Sem endereço → Busca Endereço');
            goToBuscaEndereco();
          }
        }
      }
      return;
    }
  }

  void _handleLocalizacaoChange(LocalizacaoState locState) {
    debugPrint('🔴 [NavigationCubit] _handleLocalizacaoChange: ${locState.runtimeType}');
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isClosed) return;
      if (state.path == Routes.home && locState is LocalizacaoNaoEncontrada) {
        debugPrint('🧭 [NavigationCubit] Localização não encontrada → verificar');
        _checkLocationAndGoHome();
      }
    });
  }

  // lib/app/navigation/navigation_cubit.dart

  void _checkLocationAndGoHome() {
    debugPrint('🔴 [NavigationCubit] _checkLocationAndGoHome INICIADO');
    final locState = localizacaoCubit.state;
    final authState = authCubit.state;
    debugPrint('🔴 [NavigationCubit] locState: ${locState.runtimeType}');
    debugPrint('🔴 [NavigationCubit] authState: ${authState.runtimeType}');
    debugPrint('🔴 [NavigationCubit] state.path: ${state.path}');

    // ✅ PRIORIDADE 1: Se está na splash, sai dela
    if (state.path == Routes.splash) {
      debugPrint('🧭 [NavigationCubit] Saindo da splash');
      _navigateAfterSplash();
      return;
    }

    // ✅ PRIORIDADE 2: Se usuário está autenticado, vai para HOME (mesmo sem endereço)
    if (authState is AuthAuthenticated || authState is AuthPerfilCompleto) {
      debugPrint('🧭 [NavigationCubit] Usuário autenticado → Home (com ou sem endereço)');
      emit(const NavigationState.goTo(Routes.home));
      return;
    }

    // ✅ PRIORIDADE 3: Se é convidado e não tem endereço
    if (authState is AuthGuest && locState is LocalizacaoNaoEncontrada) {
      debugPrint('🧭 [NavigationCubit] Convidado sem endereço → Busca Endereço');
      emit(const NavigationState.goTo(Routes.buscaEndereco));
      return;
    }

    // ✅ PRIORIDADE 4: Se tem endereço, vai para Home
    if (locState is LocalizacaoCarregada) {
      debugPrint('🧭 [NavigationCubit] Com endereço → Home');
      emit(const NavigationState.goTo(Routes.home));
      return;
    }

    // ✅ PRIORIDADE 5: FALLBACK - se não sabe o que fazer, vai para Home
    debugPrint('🧭 [NavigationCubit] Fallback → Home');
    emit(const NavigationState.goTo(Routes.home));
  }

  void _navigateAfterSplash() {
    final authState = authCubit.state;
    final locState = localizacaoCubit.state;

    // ✅ Se não está autenticado → Onboarding
    if (authState is AuthUnauthenticated) {
      debugPrint('🧭 [NavigationCubit] Não autenticado → Onboarding');
      emit(const NavigationState.goTo(Routes.onboarding));
      return;
    }

    // ✅ Se está autenticado → Home
    if (authState is AuthAuthenticated || authState is AuthPerfilCompleto) {
      debugPrint('🧭 [NavigationCubit] Autenticado → Home');
      emit(const NavigationState.goTo(Routes.home));
      return;
    }

    // ✅ Convidado sem endereço → Busca Endereço
    if (authState is AuthGuest && locState is LocalizacaoNaoEncontrada) {
      debugPrint('🧭 [NavigationCubit] Convidado sem endereço → Busca Endereço');
      emit(const NavigationState.goTo(Routes.buscaEndereco));
      return;
    }

    // ✅ Fallback
    debugPrint('🧭 [NavigationCubit] Fallback → Home');
    emit(const NavigationState.goTo(Routes.home));
  }

  // --- Métodos públicos de navegação ---

  void goToHomeDirectly() {
    debugPrint('🧭 [NavigationCubit] goToHomeDirectly → Home');
    // ✅ Usa _go para garantir substituição da pilha (especialmente na splash)
    _go(Routes.home);
  }

  void goToLogin({String? origem}) {
    debugPrint('🔴 [NavigationCubit] goToLogin chamado');
    _push(Routes.login, queryParams: origem != null ? {'origem': origem} : null);
  }

  void goToPhoneInput({bool redirectToCheckout = false, String? origem}) {
    debugPrint('🔴 [NavigationCubit] goToPhoneInput chamado');
    final params = <String, String>{};
    if (redirectToCheckout) params['redirectToCheckout'] = 'true';
    if (origem != null) params['origem'] = origem;
    _push(Routes.phoneInput, queryParams: params.isEmpty ? null : params);
  }

  void goToOtpVerify(String phone, {bool redirectToCheckout = false, String? origem}) {
    debugPrint('🔴 [NavigationCubit] goToOtpVerify chamado');
    final params = <String, String>{'telefone': phone};
    if (redirectToCheckout) params['redirectToCheckout'] = 'true';
    if (origem != null) params['origem'] = origem;
    _go(Routes.otpVerify, queryParams: params);
  }

  void goToCompletarPerfil({bool redirectToCheckout = false, String? origem}) {
    debugPrint('🔴 [NavigationCubit] goToCompletarPerfil chamado');
    final params = <String, String>{};
    if (redirectToCheckout) params['redirectToCheckout'] = 'true';
    if (origem != null) params['origem'] = origem;
    _push(Routes.completarPerfil, queryParams: params.isEmpty ? null : params);
  }

  void goToCarrinho({String? origem}) {
    debugPrint('🧭 [NavigationCubit] goToCarrinho → /carrinho');
    navigateToCart(origem: origem);
  }

  void goToMeusEnderecos() {
    debugPrint('🔴 [NavigationCubit] goToMeusEnderecos chamado');
    _push(Routes.meusEnderecos);
  }

  void goToEnderecoEdit(dynamic endereco) {
    debugPrint('🔴 [NavigationCubit] goToEnderecoEdit chamado');
    _push(Routes.enderecoEdit, extra: endereco);
  }

  void goToPedidoDetalhe(int pedidoId) {
    debugPrint('🔴 [NavigationCubit] goToPedidoDetalhe chamado: $pedidoId');
    _push('/pedidos/detalhe/$pedidoId');
  }

  void goToPerfil() {
    debugPrint('🔴 [NavigationCubit] goToPerfil chamado');
    _push(Routes.perfil);
  }

  void goToPedidos() {
    debugPrint('🔴 [NavigationCubit] goToPedidos chamado');
    _push(Routes.pedidos);
  }

  void goToLojaHome(int lojaId) {
    debugPrint('🔴 [NavigationCubit] goToLojaHome chamado: $lojaId');
    _push('/loja/$lojaId');
  }

  void goToCepInput() {
    debugPrint('🔴 [NavigationCubit] goToCepInput chamado');
    _push(Routes.cepInput);
  }

  void goToBuscaEndereco() {
    debugPrint('🧭 [NavigationCubit] goToBuscaEndereco → /busca-endereco');
    _go(Routes.buscaEndereco);
  }

  void goToSplash() {
    debugPrint('🔴 [NavigationCubit] goToSplash chamado');
    _go(Routes.splash);
  }

  void goToHome() {
    debugPrint('🔴 [NavigationCubit] goToHome chamado');
    _checkLocationAndGoHome();
  }

  void goToOnboarding({String? origem}) {
    debugPrint('🔴 [NavigationCubit] goToOnboarding chamado');
    _go(Routes.onboarding, queryParams: origem != null ? {'origem': origem} : null);
  }

  void goToHomeAndRemoveAll() {
    debugPrint('🔴 [NavigationCubit] goToHomeAndRemoveAll chamado');
    final locState = localizacaoCubit.state;
    if (locState is LocalizacaoCarregada) {
      _go(Routes.home);
    } else {
      debugPrint('🧭 [NavigationCubit] Sem endereço → Busca Endereço');
      goToBuscaEndereco();
    }
  }

  void goToCarrinhoAndRemoveAll() {
    debugPrint('🔴 [NavigationCubit] goToCarrinhoAndRemoveAll chamado');
    _go(Routes.carrinho);
  }

  void pop() {
    debugPrint('🔴 [NavigationCubit] pop chamado');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    emit(NavigationState.pop(timestamp: timestamp));
    debugPrint('🔴 [NavigationCubit] pop emitido');
  }

  Future<void> logout() async {
    debugPrint('🔴 [NavigationCubit] logout chamado');
    await authCubit.logout();
  }

  Future<void> logoutGuest() async {
    debugPrint('🔴 [NavigationCubit] logoutGuest chamado');
    await authCubit.sairConvidado();
  }

  void setRedirectToCheckout(bool value, {String? origem}) {
    debugPrint('🔴 [NavigationCubit] setRedirectToCheckout: $value, origem: $origem');
    _isRedirectingToCheckout = value;
    _pendingOrigem = origem;
  }

  void navigateToCart({String? origem}) {
    debugPrint('🔴 [NavigationCubit] navigateToCart chamado. origem: $origem');
    final authState = authCubit.state;
    final user = authCubit.usuario;
    final status = user?.status;

    debugPrint('🔴 [NavigationCubit] authState: ${authState.runtimeType}, status: $status, user: ${user?.nome}');

    // 🔥 SALVA A ROTA PENDENTE
    savePendingRoute(Routes.carrinho);

    if (authState is AuthAuthenticated || authState is AuthGuest || authState is AuthPerfilCompleto) {
      if (status == 'convidado' || (user != null && user.nome == 'Convidado')) {
        debugPrint('🔴 [NavigationCubit] Usuário convidado → phoneInput');
        _isRedirectingToCheckout = true;
        _pendingOrigem = origem;
        // NavigationState.pushTo already handles the emission
        _push(Routes.phoneInput, queryParams: {'redirectToCheckout': 'true', 'origem': origem ?? ''});
      } else if (status == 'pendente' || (user != null && user.nome.isEmpty)) {
        debugPrint('🔴 [NavigationCubit] Perfil pendente → completarPerfil');
        _isRedirectingToCheckout = true;
        _pendingOrigem = origem;
        _push(Routes.completarPerfil, queryParams: {'redirectToCheckout': 'true', 'origem': origem ?? ''});
      } else {
        debugPrint('🔴 [NavigationCubit] Usuário válido → carrinho');
        // Se já é válido, limpa a rota pendente e vai direto
        _pendingRoute = null;
        _go(Routes.carrinho);
      }
    } else {
      debugPrint('🔴 [NavigationCubit] Não autenticado → onboarding');
      _isRedirectingToCheckout = true;
      _pendingOrigem = origem;
      _push(Routes.onboarding, queryParams: {'origem': origem ?? ''});
    }
  }

  void _go(String path, {Map<String, String>? queryParams, Object? extra}) {
    debugPrint('🧭 [NavigationCubit] _go: $path');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    emit(NavigationState.goTo(path, queryParams: queryParams, extra: extra, timestamp: timestamp));
  }

  void _push(String path, {Map<String, String>? queryParams, Object? extra}) {
    debugPrint('🧭 [NavigationCubit] _push: $path');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    emit(NavigationState.pushTo(path, queryParams: queryParams, extra: extra, timestamp: timestamp));
  }

  @override
  Future<void> close() {
    debugPrint('🔴 [NavigationCubit] close chamado');
    _authSubscription.cancel();
    _locSubscription.cancel();
    return super.close();
  }
}