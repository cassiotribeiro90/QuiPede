import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_config.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../shared/services/device_id_service.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../models/auth_response_model.dart';
import '../models/usuario_model.dart';
import '../services/auth_service.dart';
import '../services/social_auth_service.dart';
import 'auth_state.dart';
import '../../enderecos/models/endereco_model.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;
  final SocialAuthService _socialAuthService;
  final LocalizacaoCubit _localizacaoCubit;
  final AuthService _authService;
  final EnderecoCubit _enderecoCubit;
  bool _isProcessing = false;
  UsuarioModel? _usuario;

  // 🔥 CHAVES SEPARADAS PARA SHAREDPREFERENCES (Refletidas no TokenService)
  static const String keyGuestToken = 'guest_token';
  static const String keyAccessToken = 'access_token';

  AuthCubit(
    this._apiClient,
    this._localizacaoCubit,
    this._enderecoCubit,
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
    if (_isProcessing) return;
    _isProcessing = true;
    emit(AuthLoading());

    try {
      debugPrint('🔐 [AuthCubit] Enviando telefone: $telefone');
      final response = await _apiClient.post('/app/auth/phone', data: {'phone': telefone}, requiresAuth: false);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        emit(AuthOtpEnviado(telefone: telefone, sucesso: true));
      } else {
        emit(AuthOtpErro(response.data['message'] ?? 'Erro ao enviar código.'));
      }
    } catch (e) {
      debugPrint('❌ [AuthCubit] Erro ao enviar telefone: $e');
      emit(const AuthOtpErro('Erro ao enviar código. Tente novamente.'));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> verificarOTP(String telefone, String codigo) async {
    if (_isProcessing) return;
    _isProcessing = true;
    emit(AuthOtpVerificando(telefone: telefone));

    try {
      debugPrint('🔐 [AuthCubit] Verificando OTP: $codigo para $telefone');
      final deviceId = await DeviceIdService.getDeviceId();
      final response = await _apiClient.post('/app/auth/verify-otp', data: {
        'phone': telefone,
        'code': codigo,
        'device_id': deviceId,
      }, requiresAuth: false);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['access_token'] ?? data['token'];
        final userJson = data['user'] ?? data['usuario'];
        
        await setAutenticado(
          token, 
          userJson, 
          refreshToken: data['refresh_token'], 
          expiresIn: data['expires_in']
        );
      } else {
        emit(AuthOtpErro(response.data['message'] ?? 'Código inválido.'));
      }
    } catch (e) {
      debugPrint('❌ [AuthCubit] Erro ao verificar OTP: $e');
      emit(const AuthOtpErro('Erro de conexão ou código inválido.'));
    } finally {
      _isProcessing = false;
    }
  }

  // ============ GERENCIAMENTO DE ESTADOS ============

  /// Define o estado como convidado (chamado após cadastro de endereço)
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

  /// Define o estado como autenticado (chamado após login/cadastro completo)
  Future<void> setAutenticado(String token, Map<String, dynamic> usuarioJson, {String? refreshToken, int? expiresIn}) async {
    debugPrint('🔐 [AuthCubit] Definindo sessão Autenticada');
    _usuario = UsuarioModel.fromJson(usuarioJson);
    
    await _apiClient.tokenService.saveTokens(
      token,
      refreshToken,
      expiresIn: expiresIn ?? 86400,
      isGuest: false,
      userJson: usuarioJson,
    );

    emit(AuthAuthenticated(accessToken: token, user: _usuario));
    await carregarEnderecoUsuario();
  }

  /// Converte um convidado em usuário normal ao completar o cadastro
  Future<void> completarCadastroConvidado({
    required String nome,
    required String email,
    required String senha,
    String? telefone,
  }) async {
    if (_isProcessing) return;
    _isProcessing = true;
    emit(AuthLoading());
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final response = await _apiClient.post(AppConfig.CADASTRAR, data: {
        'device_id': deviceId,
        'nome': nome,
        'email': email,
        'senha': senha,
        'confirmar_senha': senha,
        'telefone': telefone ?? '',
        'termos_aceitos': 1,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'];
        final token = data['access_token'] ?? data['token'];
        final userJson = data['user'] ?? data['usuario'];
        
        debugPrint('✅ [AuthCubit] Cadastro completado com sucesso.');
        await setAutenticado(
          token, 
          userJson, 
          refreshToken: data['refresh_token'],
          expiresIn: data['expires_in']
        );
      } else {
        emit(AuthError(response.data['message'] ?? 'Erro ao completar cadastro'));
      }
    } catch (e) {
      debugPrint('❌ [AuthCubit] Erro ao completar cadastro: $e');
      emit(const AuthError('Erro ao completar cadastro. Tente novamente.'));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> carregarEnderecoUsuario() async {
    try {
      debugPrint('🔍 [AuthCubit] carregarEnderecoUsuario() chamado');
      await _enderecoCubit.carregarEnderecos();

      final state = _enderecoCubit.state;
      if (state is EnderecoLoaded && state.enderecoPrincipal != null) {
        final address = state.enderecoPrincipal!;
        debugPrint('✅ [AuthCubit] Endereço carregado: ${address.resumido}');
        _localizacaoCubit.definirEnderecoCompleto(
          address,
          origem: 'endereco_padrao',
        );
      } else {
        debugPrint('⚠️ [AuthCubit] Nenhum endereço principal encontrado');
      }
    } catch (e) {
      debugPrint('❌ [AuthCubit] Erro ao carregar endereço: $e');
    }
  }

  Future<void> checkAuthStatus() => inicializarApp();

  Future<void> login(String email, String senha) async {
    if (_isProcessing) return;
    _isProcessing = true;
    emit(AuthLoading());

    try {
      final response = await _apiClient.post(
        AppConfig.LOGIN, 
        data: {'email': email, 'senha': senha}, 
        requiresAuth: false
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['access_token'] ?? data['token'];
        final userJson = data['user'] ?? data['usuario'];
        
        await setAutenticado(token, userJson, refreshToken: data['refresh_token'], expiresIn: data['expires_in']);
      } else {
        emit(AuthError(response.data['message'] ?? 'Erro no login'));
      }
    } catch (e) {
      emit(const AuthError('Erro de conexão ou dados inválidos'));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> cadastrar(Map<String, dynamic> dados) async {
    if (_isProcessing) return;
    _isProcessing = true;
    emit(AuthLoading());

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final payload = {...dados, 'device_id': deviceId};

      final response = await _apiClient.post(AppConfig.CADASTRAR, data: payload, requiresAuth: false);
      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['access_token'] ?? data['token'];
        final userJson = data['user'] ?? data['usuario'];
        
        await setAutenticado(token, userJson, refreshToken: data['refresh_token'], expiresIn: data['expires_in']);
      } else {
        emit(AuthError(response.data['message'] ?? 'Erro no cadastro'));
      }
    } catch (e) {
      emit(const AuthError('Erro ao realizar cadastro'));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> socialLogin(String provider) async {
    if (_isProcessing) return;
    _isProcessing = true;
    emit(AuthLoading());
    try {
      AuthResponse response;
      switch (provider) {
        case 'google': response = await _socialAuthService.signInWithGoogle(); break;
        case 'facebook': response = await _socialAuthService.signInWithFacebook(); break;
        case 'apple': response = await _socialAuthService.signInWithApple(); break;
        default: throw Exception('Provedor não suportado');
      }
      
      await setAutenticado(
        response.accessToken, 
        response.user.toJson(), 
        refreshToken: response.refreshToken, 
        expiresIn: response.expiresIn
      );
    } on SocialAuthCanceledException {
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('app/auth/logout', requiresAuth: false);
    } finally {
      _usuario = null;
      await _apiClient.tokenService.clearTokens();
      await _localizacaoCubit.limparLocalizacao();
      emit(AuthUnauthenticated());
    }
  }

  /// Remove tokens de convidado e endereço salvo, voltando ao estado inicial
  Future<void> sairConvidado() async {
    debugPrint('🔐 [AuthCubit] Saindo do modo convidado...');
    _usuario = null;
    await _apiClient.tokenService.clearTokens();
    await _localizacaoCubit.limparLocalizacao();
    // Opcional: Limpar estado do carrinho aqui se necessário
    emit(AuthUnauthenticated());
  }

  // 🔥 Alias para manter compatibilidade com roteiros anteriores, se necessário
  Future<void> onEnderecoCriadoComToken(String token, Map<String, dynamic> usuarioJson) => setConvidado(token, usuarioJson);
}
