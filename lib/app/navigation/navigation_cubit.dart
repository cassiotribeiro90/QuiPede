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

  // --- Gerenciamento de estado interno ---

  void setInitialPath(String path) {
    if (state.path != null) return;
    debugPrint('📍 [NavigationCubit] Sincronizando path inicial: $path');
    emit(NavigationState.pushTo(path));
  }

  void _handleAuthChange(AuthState authState) {
    debugPrint('🔴 [NavigationCubit] _handleAuthChange: ${authState.runtimeType}');
    
    if (isClosed) return;

    final currentPath = state.path;
    // Se não temos path no Cubit, ainda não sabemos onde o app está
    if (currentPath == null) {
      debugPrint('⏳ [NavigationCubit] Aguardando sincronização de path para decidir navegação...');
      return;
    }

    final effectivePath = currentPath;
    debugPrint('🔴 [NavigationCubit] Path atual: $effectivePath');

    // 🔥 Rotas do fluxo de onboarding
    final onboardingFlowRoutes = [
      Routes.splash,
      Routes.onboarding,
      Routes.phoneInput,
      Routes.otpVerify,
      Routes.completarPerfil,
      Routes.login,
      Routes.cepInput,
      Routes.buscaEndereco,
      Routes.enderecoConfirmacao,
    ];

    // ✅ AuthPhoneEnviado → OTP
    if (authState is AuthPhoneEnviado) {
      if (effectivePath == Routes.otpVerify) {
        debugPrint('⏭️ [NavigationCubit] Já está em OTP, ignorando');
        return;
      }
      debugPrint('🧭 [NavigationCubit] AuthPhoneEnviado → OTP');
      emit(NavigationState.pushTo(
        Routes.otpVerify,
        queryParams: {
          'telefone': authState.telefone,
          if (_isRedirectingToCheckout) 'redirectToCheckout': 'true',
          if (_pendingOrigem != null) 'origem': _pendingOrigem!,
        },
      ));
      return;
    }

    // ✅ AuthAuthenticated → HOME (direto, sem verificar localização)
    if (authState is AuthAuthenticated || authState is AuthPerfilCompleto) {
      debugPrint('🔴 [NavigationCubit] 🔥 AuthAuthenticated detectado!');
      
      final user = authState.user;
      final status = user?.status;

      // Se perfil pendente → Completar Perfil
      if (status == 'pendente' || (user != null && user.nome.isEmpty)) {
        if (effectivePath == Routes.completarPerfil) {
          debugPrint('⏭️ [NavigationCubit] Já está em Completar Perfil, ignorando');
          return;
        }
        debugPrint('🧭 [NavigationCubit] Perfil incompleto → Completar Perfil');
        emit(const NavigationState.goTo(Routes.completarPerfil));
        return;
      }

      // ✅ VAI DIRETO PARA HOME - NÃO VERIFICA LOCALIZAÇÃO NO ARRANQUE
      final isInOnboardingFlow = onboardingFlowRoutes.any((r) => 
        effectivePath.startsWith(r.replaceAll(':id', ''))
      );

      if (isInOnboardingFlow) {
        if (_isRedirectingToCheckout) {
          _isRedirectingToCheckout = false;
          _pendingOrigem = null;
          emit(const NavigationState.goTo(Routes.carrinho));
        } else {
          if (effectivePath != Routes.home) {
            debugPrint('🧭 [NavigationCubit] AuthAuthenticated → Home (direto)');
            goToHomeDirectly();
          }
        }
      } else {
        debugPrint('⏭️ [NavigationCubit] Já está em rota protegida ($effectivePath), ignorando');
      }
      return;
    }

    // ✅ AuthUnauthenticated → Onboarding
    if (authState is AuthUnauthenticated) {
      debugPrint('🔴 [NavigationCubit] 🔥 AuthUnauthenticated detectado!');
      _isRedirectingToCheckout = false;
      _pendingOrigem = null;

      final isInOnboardingFlow = onboardingFlowRoutes.any((r) => 
        effectivePath.startsWith(r.replaceAll(':id', ''))
      );

      // ✅ Permitir sair da Splash para Onboarding se não estiver autenticado
      if (!isInOnboardingFlow || effectivePath == Routes.splash) {
        debugPrint('🧭 [NavigationCubit] AuthUnauthenticated → Onboarding');
        emit(const NavigationState.goTo(Routes.onboarding));
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
    debugPrint('🔴 [NavigationCubit] goToCarrinho chamado');
    _push(Routes.carrinho, queryParams: origem != null ? {'origem': origem} : null);
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
    _go(Routes.cepInput);
  }

  void goToBuscaEndereco() {
    debugPrint('🔴 [NavigationCubit] goToBuscaEndereco chamado');
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
    _go(Routes.home);
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
    debugPrint('🔴 [NavigationCubit] navigateToCart chamado');
    final authState = authCubit.state;
    final user = authState.user;
    final status = user?.status;

    debugPrint('🔴 [NavigationCubit] authState: ${authState.runtimeType}, status: $status');

    if (authState is AuthAuthenticated || authState is AuthGuest || authState is AuthPerfilCompleto) {
      if (status == 'convidado') {
        debugPrint('🔴 [NavigationCubit] Usuário convidado → phoneInput');
        _isRedirectingToCheckout = true;
        _pendingOrigem = origem;
        emit(NavigationState.pushTo(
          Routes.phoneInput,
          queryParams: {'redirectToCheckout': 'true', 'origem': origem ?? ''},
        ));
      } else if (status == 'pendente' || (user != null && user.nome.isEmpty)) {
        debugPrint('🔴 [NavigationCubit] Perfil pendente → completarPerfil');
        _isRedirectingToCheckout = true;
        _pendingOrigem = origem;
        emit(NavigationState.pushTo(
          Routes.completarPerfil,
          queryParams: {'redirectToCheckout': 'true', 'origem': origem ?? ''},
        ));
      } else {
        debugPrint('🔴 [NavigationCubit] Usuário válido → carrinho');
        emit(const NavigationState.pushTo(Routes.carrinho));
      }
    } else {
      debugPrint('🔴 [NavigationCubit] Não autenticado → onboarding');
      _isRedirectingToCheckout = true;
      _pendingOrigem = origem;
      emit(NavigationState.pushTo(
        Routes.onboarding,
        queryParams: {'origem': origem ?? ''},
      ));
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