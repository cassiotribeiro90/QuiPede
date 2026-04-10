
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_config.dart';
import '../../../../shared/api/api_client.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;
  bool _isProcessing = false;

  AuthCubit(this._apiClient) : super(AuthInitial());

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
      
      if (_apiClient.tokenService.isTokenExpired()) {
        final refreshSuccess = await _apiClient.tokenService.refreshToken(_apiClient.dio);
        
        if (refreshSuccess) {
          final newToken = _apiClient.tokenService.getAccessToken();
          if (newToken != null) {
            emit(AuthAuthenticated(accessToken: newToken));
          } else {
            // Caso bizarro onde refresh deu true mas token sumiu
            await _apiClient.tokenService.clearTokens();
            emit(AuthUnauthenticated());
          }
        } else {
          await _apiClient.tokenService.clearTokens();
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthAuthenticated(accessToken: token));
      }
    } catch (e) {
      print('🔐 [AuthCubit] Erro no checkAuthStatus: $e');
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
        final String accessToken = data['access_token']?.toString() ?? '';
        final String? refreshToken = data['refresh_token']?.toString();
        final int expiresIn = data['expires_in'] ?? 7200;
        
        await _apiClient.tokenService.saveTokens(accessToken, refreshToken, expiresIn: expiresIn);
        emit(AuthAuthenticated(accessToken: accessToken));
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

  Future<void> logout() async {
    if (_isProcessing) return;
    _isProcessing = true;

    print('📱 [LOGOUT] Iniciando logout...');
    try {
      await _apiClient.post('app/auth/logout', requiresAuth: false);
    } catch (e) {
      print('📱 [LOGOUT] Erro no request de logout (ignorado): $e');
    } finally {
      await _apiClient.tokenService.clearTokens();
      emit(AuthUnauthenticated());
      _isProcessing = false;
    }
  }

  Future<void> checkAuth() => checkAuthStatus();
}
