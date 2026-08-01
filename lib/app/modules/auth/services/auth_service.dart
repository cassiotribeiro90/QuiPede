import 'package:dio/dio.dart';

import '../../../../shared/api/api_client.dart';
import '../../../../shared/services/token_service.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Login com email e senha
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Criar usuário convidado
  Future<Map<String, dynamic>> criarConvidado(String deviceId) async {
    try {
      final response = await _apiClient.post(
        '/auth/convidado',
        data: {
          'device_id': deviceId,
        },
        requiresAuth: false,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Registro de novo usuário
  Future<Map<String, dynamic>> registrar(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '/auth/registrar',
        data: data,
        requiresAuth: false,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Verificar token atual (endpoint /me)
  Future<Map<String, dynamic>> verificarToken() async {
    try {
      final response = await _apiClient.get('/auth/me');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
      await TokenService().clearTokens();
    } catch (e) {
      // Ignora erros no logout
    }
  }

  /// Converter convidado para cliente completo
  Future<Map<String, dynamic>> atualizarUsuario(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '/usuario/atualizar',
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}