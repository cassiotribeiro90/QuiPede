import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_config.dart';
import '../../../../shared/api/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/usuario_model.dart';
import '../services/social_auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;
  final SocialAuthService _socialAuthService;
  bool _isProcessing = false;
  UsuarioModel? _usuario;

  AuthCubit(this._apiClient) 
      : _socialAuthService = SocialAuthService(_apiClient),
        super(AuthInitial());

  UsuarioModel? get usuario => _usuario;

  Future<void> checkAuthStatus() async {
    if (_isProcessing) return;
    _isProcessing = true;

    print('🔐 [AuthCubit] Iniciando checkAuthStatus...');
    emit(AuthChecking());
    
    try {
      final String? token = _apiClient.tokenService.getAccessToken();
      
      if (token == null || token.isEmpty) {
        emit(AuthUnauthenticated());
        return;
      }
      
      // 1. Validar expiração local
      if (_apiClient.tokenService.isTokenExpired()) {
        print('🔐 [AuthCubit] Token expirado localmente, tentando refresh...');
        final refreshSuccess = await _apiClient.tokenService.refreshToken(_apiClient.dio);
        
        if (!refreshSuccess) {
          print('🔐 [AuthCubit] Falha no refresh token.');
          await _apiClient.tokenService.clearTokens();
          emit(AuthUnauthenticated());
          return;
        }
      }

      // 2. Validar token com o backend e obter dados do usuário
      print('🔐 [AuthCubit] Validando token com o backend (/app/auth/me)...');
      try {
        final response = await _apiClient.get('app/auth/me', requiresAuth: true);
        
        if (response.statusCode == 200 && response.data['success'] == true) {
          final userData = response.data['data'];
          _usuario = UsuarioModel.fromJson(userData);
          final currentToken = _apiClient.tokenService.getAccessToken()!;
          emit(AuthAuthenticated(accessToken: currentToken));
          print('🔐 [AuthCubit] Usuário autenticado: ${_usuario?.nome}');
        } else {
          print('🔐 [AuthCubit] Backend rejeitou o token.');
          await _apiClient.tokenService.clearTokens();
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        print('🔐 [AuthCubit] Erro ao validar token no backend: $e');
        // Se for erro de rede, podemos manter o estado ou tentar novamente. 
        // Se for 401, deslogar.
        if (e is DioException && e.response?.statusCode == 401) {
          await _apiClient.tokenService.clearTokens();
          emit(AuthUnauthenticated());
        } else {
          // Erro de conexão, assume autenticado se tiver token (modo offline básico ou retry posterior)
          final currentToken = _apiClient.tokenService.getAccessToken()!;
          emit(AuthAuthenticated(accessToken: currentToken));
        }
      }
    } catch (e) {
      print('🔐 [AuthCubit] Erro crítico no checkAuthStatus: $e');
      emit(AuthUnauthenticated());
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> login(String email, String senha) async {
    if (_isProcessing) return;
    _isProcessing = true;

    emit(AuthLoading());

    try {
      final response = await _apiClient.post(
        AppConfig.LOGIN, 
        data: {'email': email, 'senha': senha},
        requiresAuth: false,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final authResponse = AuthResponse.fromJson(data);
        _usuario = authResponse.user;
        await _saveAuthResponse(authResponse);
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
      await _saveAuthResponse(response);
    } on SocialAuthCanceledException {
      emit(AuthUnauthenticated()); 
    } catch (e) {
      print('🔐 [AuthCubit] Erro no socialLogin ($provider): $e');
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _saveAuthResponse(AuthResponse response) async {
    await _apiClient.tokenService.saveTokens(
      response.accessToken, 
      response.refreshToken, 
      expiresIn: response.expiresIn
    );
    emit(AuthAuthenticated(accessToken: response.accessToken));
  }

  Future<void> logout() async {
    if (_isProcessing) return;
    _isProcessing = true;

    print('📱 [LOGOUT] Iniciando logout...');
    try {
      await _apiClient.post('app/auth/logout', requiresAuth: false);
    } catch (e) {
      print('📱 [LOGOUT] Erro no request de logout (ignorado): $e');
    } finally {
      _usuario = null;
      await _apiClient.tokenService.clearTokens();
      emit(AuthUnauthenticated());
      _isProcessing = false;
    }
  }

  Future<void> checkAuth() => checkAuthStatus();
}
