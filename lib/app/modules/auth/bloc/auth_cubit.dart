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

  AuthCubit(
      this._apiClient,
      this._localizacaoCubit,
      this._enderecoCubit,
      ) : _socialAuthService = SocialAuthService(_apiClient),
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
      debugPrint('🔐 [AuthCubit] Token: ${token != null ? "EXISTE" : "NULO"}');

      if (token != null && token.isNotEmpty) {
        debugPrint('🔐 [AuthCubit] Token existe, validando...');
        try {
          final response = await _apiClient.get('app/auth/me', requiresAuth: true);
          debugPrint('🔐 [AuthCubit] /me status: ${response.statusCode}');

          if (response.statusCode == 200 && response.data['success'] == true) {
            final data = response.data['data'];
            final authResponse = AuthResponse.fromJson(data);
            _usuario = authResponse.user;
            debugPrint('✅ [AuthCubit] Usuário autenticado: ${_usuario?.nome}');
            emit(AuthAuthenticated(accessToken: token));
            await carregarEnderecoUsuario();
            debugPrint('✅ [AuthCubit] INICIALIZAÇÃO CONCLUÍDA (AUTENTICADO)');
            return;
          }
        } catch (e) {
          debugPrint('❌ [AuthCubit] Erro ao validar token: $e');
        }
      }

      debugPrint('🔐 [AuthCubit] Criando convidado...');
      await _criarConvidado();
      debugPrint('✅ [AuthCubit] INICIALIZAÇÃO CONCLUÍDA (CONVIDADO)');
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthCubit] ERRO NA INICIALIZAÇÃO: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      emit(AuthUnauthenticated());
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _criarConvidado() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      debugPrint('🔐 [AuthCubit] DeviceId: $deviceId');

      final response = await _authService.criarConvidado(deviceId);
      debugPrint('🔐 [AuthCubit] Resposta criarConvidado: ${response['success']}');

      if (response['success'] == true) {
        final data = response['data'];
        await _apiClient.tokenService.saveTokens(
          data['token'],
          null,
          expiresIn: 86400,
        );

        final authResponse = AuthResponse.fromJson({
          'user': data['usuario'],
          'access_token': data['token'],
          'refresh_token': null,
          'expires_in': 86400,
          'endereco': null,
        });
        _usuario = authResponse.user;

        debugPrint('✅ [AuthCubit] Usuário convidado criado: ${_usuario?.id}');
        emit(AuthAuthenticated(accessToken: data['token']));
        await carregarEnderecoUsuario();
      } else {
        debugPrint('❌ [AuthCubit] Erro ao criar convidado: ${response['message']}');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('❌ [AuthCubit] Erro ao criar convidado: $e');
      emit(AuthUnauthenticated());
    }
  }

  /// 🔥 TORNOU-SE PÚBLICO: Carrega os endereços do usuário e define o principal no LocalizacaoCubit
  Future<void> carregarEnderecoUsuario() async {
    try {
      print('🔍 [AuthCubit] carregarEnderecoUsuario() chamado');
      await _enderecoCubit.carregarEnderecos();

      final state = _enderecoCubit.state;
      if (state is EnderecoLoaded && state.enderecoPrincipal != null) {
        final endereco = state.enderecoPrincipal!;
        print('🔍 [AuthCubit] Definindo endereço no LocalizacaoCubit: ${endereco.enderecoResumido}');
        _localizacaoCubit.definirEnderecoCompleto(
          endereco,
          origem: 'endereco_padrao',
        );
        print('✅ [AuthCubit] Endereço carregado: ${endereco.enderecoResumido}');
      } else {
        print('⚠️ [AuthCubit] Nenhum endereço principal encontrado');
      }
    } catch (e) {
      print('❌ [AuthCubit] Erro ao carregar endereço: $e');
    }
  }

  // ============ CHECK AUTH ============

  Future<void> checkAuthStatus() async {
    if (_isProcessing) return;
    _isProcessing = true;

    debugPrint('🔐 [AuthCubit] Iniciando checkAuthStatus...');
    emit(AuthChecking());

    try {
      final String? token = _apiClient.tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        debugPrint('🔐 [AuthCubit] Token vazio, criando convidado...');
        await _criarConvidado();
        return;
      }

      if (_apiClient.tokenService.isTokenExpired()) {
        debugPrint('🔐 [AuthCubit] Token expirado localmente, tentando refresh...');
        final refreshSuccess = await _apiClient.tokenService.refreshToken(_apiClient.dio);

        if (!refreshSuccess) {
          debugPrint('🔐 [AuthCubit] Falha no refresh token.');
          await _apiClient.tokenService.clearTokens();
          await _criarConvidado();
          return;
        }
      }

      debugPrint('🔐 [AuthCubit] Validando token no backend (/app/auth/me)...');
      try {
        final response = await _apiClient.get('app/auth/me', requiresAuth: true);

        if (response.statusCode == 200 && response.data['success'] == true) {
          final data = response.data['data'];
          final authResponse = AuthResponse.fromJson(data);
          _usuario = authResponse.user;

          if (authResponse.endereco != null) {
            _localizacaoCubit.definirEnderecoCompleto(authResponse.endereco!, origem: 'endereco_padrao');
          }

          final currentToken = _apiClient.tokenService.getAccessToken()!;
          emit(AuthAuthenticated(accessToken: currentToken));
          await carregarEnderecoUsuario();
        } else {
          debugPrint('⚠️ [AuthCubit] Token inválido, criando convidado...');
          await _apiClient.tokenService.clearTokens();
          await _criarConvidado();
        }
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 401) {
          debugPrint('⚠️ [AuthCubit] Token expirado (401), criando convidado...');
          await _apiClient.tokenService.clearTokens();
          await _criarConvidado();
        } else {
          debugPrint('⚠️ [AuthCubit] Erro na validação, mantendo token: $e');
          final currentToken = _apiClient.tokenService.getAccessToken()!;
          emit(AuthAuthenticated(accessToken: currentToken));
        }
      }
    } catch (e) {
      debugPrint('❌ [AuthCubit] Erro no checkAuthStatus: $e');
      emit(AuthUnauthenticated());
    } finally {
      _isProcessing = false;
    }
  }

  // ============ AUTENTICAÇÃO ============

  Future<void> login(String email, String senha) async {
    if (_isProcessing) return;
    _isProcessing = true;

    emit(AuthLoading());

    try {
      debugPrint('🚀 [AuthCubit] Iniciando login: $email');

      final response = await _apiClient.post(
        AppConfig.LOGIN,
        data: {'email': email, 'senha': senha},
        requiresAuth: false,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final authResponse = AuthResponse.fromJson(data);
        _usuario = authResponse.user;

        if (authResponse.endereco != null) {
          _localizacaoCubit.definirEnderecoCompleto(authResponse.endereco!, origem: 'endereco_padrao');
        }

        await _saveAuthResponse(authResponse);
        await carregarEnderecoUsuario();
      } else {
        emit(AuthError(response.data['message'] ?? 'Erro no login'));
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erro de conexão';
      emit(AuthError(message));
    } catch (e) {
      emit(const AuthError('Erro inesperado'));
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> validarEtapa1(Map<String, dynamic> dados) async {
    if (_isProcessing) return false;
    _isProcessing = true;

    emit(AuthLoading());

    try {
      final response = await _apiClient.post(
        AppConfig.VALIDAR_ETAPA1,
        data: dados,
        requiresAuth: false,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        emit(AuthInitial());
        return true;
      } else {
        emit(AuthError(response.data['message'] ?? 'Erro na validação'));
        return false;
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erro de conexão';
      emit(AuthError(message));
      return false;
    } catch (e) {
      emit(const AuthError('Erro inesperado na validação'));
      return false;
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> cadastrar(Map<String, dynamic> dados) async {
    if (_isProcessing) return;
    _isProcessing = true;

    emit(AuthLoading());

    try {
      final response = await _apiClient.post(
        AppConfig.CADASTRAR,
        data: dados,
        requiresAuth: false,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'];
        final authResponse = AuthResponse.fromJson(data);
        _usuario = authResponse.user;

        if (authResponse.endereco != null) {
          _localizacaoCubit.definirEnderecoCompleto(authResponse.endereco!, origem: 'endereco_padrao');
        }

        await _saveAuthResponse(authResponse);
        await carregarEnderecoUsuario();
      } else {
        emit(AuthError(response.data['message'] ?? 'Erro no cadastro'));
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erro de conexão';
      emit(AuthError(message));
    } catch (e) {
      emit(const AuthError('Erro inesperado no cadastro'));
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
        case 'google':
          response = await _socialAuthService.signInWithGoogle();
          break;
        case 'facebook':
          response = await _socialAuthService.signInWithFacebook();
          break;
        case 'apple':
          response = await _socialAuthService.signInWithApple();
          break;
        default:
          throw Exception('Provedor não suportado');
      }

      _usuario = response.user;

      if (response.endereco != null) {
        _localizacaoCubit.definirEnderecoCompleto(response.endereco!, origem: 'endereco_padrao');
      }

      await _saveAuthResponse(response);
      await carregarEnderecoUsuario();
    } on SocialAuthCanceledException {
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _saveAuthResponse(AuthResponse response) async {
    await _apiClient.tokenService.saveTokens(
      response.accessToken,
      response.refreshToken,
      expiresIn: response.expiresIn ?? 86400,
    );
    emit(AuthAuthenticated(accessToken: response.accessToken));
  }

  Future<void> logout() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      await _apiClient.post('app/auth/logout', requiresAuth: false);
    } catch (e) {
      // ignore
    } finally {
      _usuario = null;
      await _apiClient.tokenService.clearTokens();
      await _localizacaoCubit.limparLocalizacao();
      await _criarConvidado();
      _isProcessing = false;
    }
  }

  Future<void> checkAuth() => checkAuthStatus();
}
