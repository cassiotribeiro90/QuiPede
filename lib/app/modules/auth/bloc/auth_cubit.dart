import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/api/api_client.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../models/auth_response_model.dart';
import '../models/usuario_model.dart';
import '../services/auth_service.dart';
import '../services/social_auth_service.dart';
import 'auth_state.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import '../../../routes/app_routes.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;
  final SocialAuthService _socialAuthService;
  final LocalizacaoCubit _localizacaoCubit;
  final AuthService _authService;
  final EnderecoCubit _enderecoCubit;
  final SharedPreferences _prefs;
  bool _isProcessing = false;
  UsuarioModel? _usuario;

  // 🔥 CHAVES ESSENCIAIS PARA O CARRINHO E TOKEN SERVICE
  static const String keyAccessToken = 'access_token';
  static const String keyGuestToken = 'guest_token';

  AuthCubit(
      this._apiClient,
      this._localizacaoCubit,
      this._enderecoCubit,
      this._prefs,
      )   : _socialAuthService = SocialAuthService(_apiClient),
        _authService = AuthService(_apiClient),
        super(AuthInitial());

  UsuarioModel? get usuario => _usuario;

  // ============ INICIALIZAÇÃO ============

  Future<void> inicializarApp() async {
    if (_isProcessing) return;
    _isProcessing = true;

    debugPrint('🔐 [AuthCubit] 🔥 INICIALIZANDO APP...');
    emit(AuthLoading());

    try {
      final token = _apiClient.tokenService.getAccessToken();
      final isGuest = _apiClient.tokenService.isGuest();
      debugPrint('🔐 [AuthCubit] Token encontrado: ${token != null ? "Sim" : "Não"} (Guest: $isGuest)');

      if (token != null && token.isNotEmpty) {
        if (isGuest) {
          debugPrint('🔐 [AuthCubit] Restaurando sessão de convidado...');
          final userJson = _apiClient.tokenService.getUser();
          if (userJson != null) {
            _usuario = UsuarioModel.fromJson(userJson);
          }
          emit(AuthGuest(accessToken: token, user: _usuario));
          await carregarEnderecoUsuario();
          _isProcessing = false;
          return;
        }

        debugPrint('🔐 [AuthCubit] Validando token de usuário real...');
        try {
          final response = await _apiClient.get('app/auth/me', requiresAuth: true);
          if (response.statusCode == 200 && response.data['success'] == true) {
            final data = response.data['data'];
            final authResponse = AuthResponse.fromJson(data);
            _usuario = authResponse.user;
            await _apiClient.tokenService.saveUser(_usuario!.toJson());

            emit(AuthAuthenticated(accessToken: token, user: _usuario));
            await carregarEnderecoUsuario();
            _isProcessing = false;
            return;
          }
        } catch (e) {
          debugPrint('❌ [AuthCubit] Erro ao validar token: $e');
        }
      }

      debugPrint('🔐 [AuthCubit] Nenhuma sessão válida encontrada.');
      emit(AuthUnauthenticated());
    } catch (e) {
      debugPrint('❌ [AuthCubit] ERRO NA INICIALIZAÇÃO: $e');
      emit(AuthUnauthenticated());
    } finally {
      _isProcessing = false;
    }
  }

  // ============ MÉTODOS OTP (TELEFONE) ============

  Future<void> enviarTelefone(String telefone) async {
    emit(AuthPhoneEnviado(telefone: telefone));
    try {
      await _apiClient.post('/app/auth/phone', data: {'phone': telefone}, requiresAuth: false);
    } catch (e) {
      emit(const AuthOtpErro('Erro ao enviar código. Tente novamente.'));
    }
  }

  Future<void> verificarOTP(String telefone, String codigo) async {
    emit(AuthOtpVerificando(telefone: telefone));
    try {
      final response = await _apiClient.post('/app/auth/verify-otp', data: {
        'phone': telefone,
        'code': codigo,
      }, requiresAuth: false);

      final data = response.data['data'];
      final accessToken = data['access_token'] ?? data['token'];
      final userJson = data['usuario'] ?? data['user'];

      if (userJson != null) {
        final usuarioMap = Map<String, dynamic>.from(userJson);
        await _apiClient.tokenService.saveTokens(accessToken, null, isGuest: false);
        await _apiClient.tokenService.saveUser(usuarioMap);
        _usuario = UsuarioModel.fromJson(usuarioMap);
        emit(AuthAuthenticated(accessToken: accessToken, user: _usuario));
      } else {
        emit(const AuthOtpErro('Usuário não encontrado após verificação.'));
      }
    } catch (e) {
      emit(const AuthOtpErro('Código inválido. Tente novamente.'));
    }
  }

  // ============ MÉTODOS LEGADOS (STUBS) ============
  Future<void> login(String email, String senha) async {}
  Future<void> cadastrar(Map<String, dynamic> dados) async {}
  Future<void> socialLogin(String provider) async {}
  Future<void> completarCadastroConvidado({required String nome, required String email, String? senha, String? telefone}) async {}

  // ============ GESTÃO DE SESSÃO ============

  Future<void> checkAuthStatus() => inicializarApp();

  Future<void> setConvidado(String token, Map<String, dynamic> usuarioJson) async {
    debugPrint('🔐 [AuthCubit] Definindo sessão de Convidado');
    _usuario = UsuarioModel.fromJson(usuarioJson);

    await _apiClient.tokenService.saveTokens(
      token,
      null,
      expiresIn: 86400,
      isGuest: true,
      userJson: usuarioJson,
    );

    emit(AuthGuest(accessToken: token, user: _usuario));
    await carregarEnderecoUsuario();
  }

  Future<void> onEnderecoCriadoComToken(String token, Map<String, dynamic> usuarioJson) => setConvidado(token, usuarioJson);

  Future<void> setAutenticado(String token, Map<String, dynamic> usuarioJson, {String? refreshToken, int? expiresIn}) async {
    _usuario = UsuarioModel.fromJson(usuarioJson);
    await _apiClient.tokenService.saveTokens(token, refreshToken, expiresIn: expiresIn ?? 86400, isGuest: false, userJson: usuarioJson);
    emit(AuthAuthenticated(accessToken: token, user: _usuario));
    await carregarEnderecoUsuario();
  }

  Future<void> carregarEnderecoUsuario() async {
    try {
      await _enderecoCubit.carregarEnderecos();
      final state = _enderecoCubit.state;
      if (state is EnderecoLoaded && state.enderecoPrincipal != null) {
        _localizacaoCubit.definirEnderecoCompleto(state.enderecoPrincipal!, origem: 'endereco_padrao');
      }
    } catch (e) {}
  }

  Future<void> logout() async {
    debugPrint('🚪 [AuthCubit] Iniciando logout...');

    // Tenta invalidar token no backend COM autenticação
    try {
      await _apiClient.post('app/auth/logout', requiresAuth: true);
    } catch (e) {
      debugPrint('⚠️ [AuthCubit] Erro no logout (ignorado): $e');
    }

    // 🔥 Limpa TUDO localmente, sempre
    _usuario = null;
    await _apiClient.tokenService.clearTokens();
    await _localizacaoCubit.limparLocalizacao();

    await _prefs.remove('guest_token');
    await _prefs.remove('access_token');
    await _prefs.remove('is_guest');
    await _prefs.remove('endereco_padrao_id');
    await _prefs.remove('endereco_padrao_json');
    await _prefs.remove('endereco_convidado_id');

    emit(AuthUnauthenticated());

    // 🔥 FORÇA redirecionamento usando o navigatorKey global
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🚪 [AuthCubit] Redirecionando para onboarding');
      ApiClient.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.onboarding,
            (route) => false,
      );
    });
  }

  Future<void> sairConvidado() async {
    debugPrint('🔐 [AuthCubit] Saindo do modo convidado...');

    // Tenta remover endereço no backend COM autenticação
    try {
      final enderecoId = _prefs.getInt('endereco_convidado_id');
      if (enderecoId != null) {
        await _apiClient.delete('/app/enderecos/$enderecoId', requiresAuth: true);
      }
    } catch (e) {
      debugPrint('⚠️ [AuthCubit] Erro ao remover endereço (ignorado): $e');
    }

    _usuario = null;
    await _apiClient.tokenService.clearTokens();
    await _localizacaoCubit.limparLocalizacao();

    await _prefs.remove('guest_token');
    await _prefs.remove('is_guest');
    await _prefs.remove('endereco_padrao_id');
    await _prefs.remove('endereco_padrao_json');
    await _prefs.remove('endereco_convidado_id');

    emit(AuthUnauthenticated());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🚪 [AuthCubit] sairConvidado() concluído, redirecionando para onboarding');
      ApiClient.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.onboarding,
            (route) => false,
      );
    });
  }
}