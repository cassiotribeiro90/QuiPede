import 'package:flutter/foundation.dart';
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

  /// Atualizar perfil do usuário (nome obrigatório, email opcional)
  Future<Map<String, dynamic>> atualizarPerfil({
    required String nome,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{
        'nome': nome,
      };
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }

      debugPrint('📡 [AuthService] POST /app/auth/me com dados: $data');

      final response = await _apiClient.post(
        'app/auth/me',
        data: data,
        requiresAuth: true,
      );

      debugPrint('📡 [AuthService] Status: ${response.statusCode}');
      debugPrint('📡 [AuthService] Response: ${response.data}');

      return response.data;
    } catch (e) {
      debugPrint('❌ [AuthService] Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  /// Inicia atualização de telefone (gera OTP)
  Future<Map<String, dynamic>> iniciarAtualizacaoTelefone(String telefone) async {
    final response = await _apiClient.post(
      'app/auth/update-telefone',
      data: {'telefone': telefone},
      requiresAuth: true,
    );
    return response.data;
  }

  /// Confirma atualização de telefone com OTP
  Future<Map<String, dynamic>> confirmarAtualizacaoTelefone({
    required String telefone,
    required String codigo,
  }) async {
    final response = await _apiClient.post(
      'app/auth/confirm-update-telefone',
      data: {
        'telefone': telefone,
        'code': codigo,
      },
      requiresAuth: true,
    );
    return response.data;
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
