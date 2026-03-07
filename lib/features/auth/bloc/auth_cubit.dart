import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/di/dependencies.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  Timer? _expirationTimer;
  final SharedPreferences _prefs;

  AuthCubit(this._prefs) : super(AuthInitial());

  void checkAuth() {
    final token = _prefs.getString('access_token');
    if (token != null) {
      emit(AuthAuthenticated(token));
      _startExpirationTimer();
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      // TODO: Implement real login call via ApiService
      // final response = await getIt<ApiService>().post('/auth-lojista/login', data: {'email': email, 'password': password});
      // final token = response.data['access_token'];
      
      // Simulação para testes
      await Future.delayed(const Duration(seconds: 1));
      const token = 'mock_token_123';
      
      await _prefs.setString('access_token', token);
      emit(AuthAuthenticated(token));
      _startExpirationTimer();
    } catch (e) {
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }

  void _startExpirationTimer() {
    _expirationTimer?.cancel();
    // No roteiro: 1 minuto (60 segundos)
    _expirationTimer = Timer(const Duration(minutes: 1), () {
      logout(message: 'Sua sessão expirou por inatividade.');
    });

    // Notificar 10 segundos antes (opcional, mas bom para UX)
    Timer(const Duration(seconds: 50), () {
      if (state is AuthAuthenticated) {
        emit(AuthTokenExpiringSoon(10));
      }
    });
  }

  Future<void> logout({String? message}) async {
    _expirationTimer?.cancel();
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
    emit(AuthUnauthenticated(message: message));
  }

  @override
  Future<void> close() {
    _expirationTimer?.cancel();
    return super.close();
  }
}
