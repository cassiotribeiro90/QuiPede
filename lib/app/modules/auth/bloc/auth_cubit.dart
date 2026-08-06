import 'dart:async';
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
import '../../enderecos/models/endereco_model.dart';
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

      if (token != null && token.isNotEmpty) {
        try {
          final response = await _apiClient.get('app/auth/me', requiresAuth: true);
          if (response.statusCode == 200 && response.data['success'] == true) {
            final data = response.data['data'];
            final authResponse = AuthResponse.fromJson(data);
            _usuario = authResponse.user;

            if (authResponse.endereco != null) {
              _localizacaoCubit.definirEnderecoCompleto(authResponse.endereco!, origem: 'endereco_padrao');
            }

            if (isGuest) {
              emit(AuthGuest(accessToken: token, user: _usuario));
            } else {
              emit(AuthAuthenticated(accessToken: token, user: _usuario));
            }

            await carregarEnderecoUsuario();
            _isProcessing = false;
            return;
          }
        } catch (e) {
          debugPrint('❌ [AuthCubit] Erro ao buscar /me, usando cache local: $e');
        }

        final userJson = _apiClient.tokenService.getUser();
        if (userJson != null) {
          _usuario = UsuarioModel.fromJson(userJson);
        }

        if (isGuest) {
          emit(AuthGuest(accessToken: token, user: _usuario));
        } else {
          emit(AuthAuthenticated(accessToken: token, user: _usuario));
        }
        await carregarEnderecoUsuario();
        _isProcessing = false;
        return;
      }

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

  Future<void> verificarOTP(String telefone, String codigo, {bool redirectToCheckout = false}) async {
    emit(AuthOtpVerificando(telefone: telefone));
    try {
      final response = await _apiClient.post('/app/auth/verify-otp',
          data: {'phone': telefone, 'code': codigo}, requiresAuth: false);

      final data = response.data['data'];
      final accessToken = data['access_token'] ?? data['token'];
      final userJson = data['usuario'] ?? data['user'];
      final enderecoJson = data['endereco'];

      if (userJson != null) {
        final usuarioMap = Map<String, dynamic>.from(userJson);
        await _apiClient.tokenService.saveTokens(accessToken, null, isGuest: false);
        _usuario = UsuarioModel.fromJson(usuarioMap);

        emit(AuthAuthenticated(accessToken: accessToken, user: _usuario));

        if (enderecoJson != null) {
          final endereco = EnderecoModel.fromJson(Map<String, dynamic>.from(enderecoJson));
          _localizacaoCubit.definirEnderecoCompleto(endereco, origem: 'endereco_padrao');
        }
        await carregarEnderecoUsuario();

        // ✅ Não navega mais daqui — o AppRouter cuida do redirecionamento
      } else {
        emit(const AuthOtpErro('Usuário não encontrado após verificação.'));
      }
    } catch (e) {
      emit(const AuthOtpErro('Código inválido. Tente novamente.'));
    }
  }

  // ============ COMPLETAR PERFIL ============

  Future<void> completarPerfil({
    required String nome,
    String? email,
  }) async {
    debugPrint('📝 [AuthCubit] Completando perfil: nome=$nome, email=$email');
    emit(AuthLoading());

    try {
      final token = _apiClient.tokenService.getAccessToken() ?? '';

      final response = await _authService.atualizarPerfil(nome: nome, email: email);

      final data = response['data'];
      final usuarioJson = data['usuario'] ?? data['user'];

      if (usuarioJson != null) {
        final usuarioMap = Map<String, dynamic>.from(usuarioJson);
        _usuario = UsuarioModel.fromJson(usuarioMap);

        debugPrint('✅ [AuthCubit] Perfil completado: ${_usuario?.nome}');

        emit(AuthPerfilCompleto(accessToken: token, user: _usuario!));
        // ✅ Não navega — o CompletarPerfilPage dá pop, AppRouter redireciona
      } else {
        debugPrint('❌ [AuthCubit] Resposta sem dados de usuário');
        emit(const AuthError('Erro ao salvar perfil. Tente novamente.'));
      }
    } catch (e) {
      debugPrint('❌ [AuthCubit] Erro ao completar perfil: $e');
      emit(AuthError('Erro ao salvar perfil. Tente novamente.'));
    }
  }

  // ============ MÉTODOS LEGADOS ============

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());
    try {
      emit(const AuthError('O login por senha foi desativado. Use o telefone.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> cadastrar(Map<String, dynamic> dados) async {
    emit(AuthLoading());
    try {
      emit(const AuthError('O cadastro direto foi desativado. Use o fluxo de telefone.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> socialLogin(String provider) async {
    emit(AuthLoading());
    try {
      emit(const AuthError('Login social temporariamente indisponível.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> completarCadastroConvidado({
    required String nome,
    required String email,
    String? senha,
    String? telefone,
  }) async {
    emit(AuthLoading());
    try {
      emit(const AuthError('Use o fluxo de completar perfil após o OTP.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ============ GESTÃO DE SESSÃO ============

  Future<void> checkAuthStatus() => inicializarApp();

  Future<void> setConvidado(String token, Map<String, dynamic> usuarioJson) async {
    debugPrint('🔐 [AuthCubit] Definindo sessão de Convidado');
    _usuario = UsuarioModel.fromJson(usuarioJson);

    await _apiClient.tokenService.saveTokens(token, null, expiresIn: 86400, isGuest: true);

    emit(AuthGuest(accessToken: token, user: _usuario));
    await carregarEnderecoUsuario();
  }

  Future<void> onEnderecoCriadoComToken(String token, Map<String, dynamic> usuarioJson) =>
      setConvidado(token, usuarioJson);

  Future<void> carregarEnderecoUsuario() async {
    try {
      await _enderecoCubit.carregarEnderecos();
      final state = _enderecoCubit.state;
      if (state is EnderecoLoaded && state.enderecoPrincipal != null) {
        _localizacaoCubit.definirEnderecoCompleto(state.enderecoPrincipal!, origem: 'endereco_padrao');
      }
    } catch (e) {
      debugPrint('⚠️ [AuthCubit] Erro ao carregar endereço: $e');
    }
  }

  Future<void> sairConvidado() async {
    debugPrint('🔐 [AuthCubit] Saindo do modo convidado...');

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
      ApiClient.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.onboarding,
            (route) => false,
      );
    });
  }

  Future<void> logout() async {
    debugPrint('🚪 [AuthCubit] Iniciando logout...');

    try {
      await _apiClient.post('app/auth/logout', requiresAuth: true);
    } catch (e) {
      debugPrint('⚠️ [AuthCubit] Erro no logout (ignorado): $e');
    }

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ApiClient.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.onboarding,
            (route) => false,
      );
    });
  }
}