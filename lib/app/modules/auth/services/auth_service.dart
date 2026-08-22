import 'package:flutter/foundation.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../shared/services/token_service.dart';
import '../../../core/services/device_service.dart';

class AuthService {
  final ApiClient _apiClient;
  final DeviceService _deviceService = DeviceService();

  AuthService(this._apiClient);

  /// Login com email e senha
  Future<Map<String, dynamic>> login(String email, String password, {String? deviceToken}) async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      final data = {
        'email': email,
        'password': password,
        'device_id': deviceId,
      };
      if (deviceToken != null) {
        data['device_token'] = deviceToken;
      }
      final response = await _apiClient.post(
        '/auth/login',
        data: data,
        requiresAuth: false,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Enviar telefone para OTP
  Future<void> enviarTelefone(String phone) async {
    final deviceId = await _deviceService.getDeviceId();
    await _apiClient.post(
      '/app/auth/phone',
      data: {
        'phone': phone,
        'device_id': deviceId,
      },
      requiresAuth: false,
    );
  }

  /// Verificar OTP
  Future<Map<String, dynamic>> verificarOTP(String phone, String code, {String? deviceToken}) async {
    debugPrint('[AUTH_SERVICE] 🔍 verificarOTP chamado');
    debugPrint('[AUTH_SERVICE] 📞 Phone: $phone');
    debugPrint('[AUTH_SERVICE] 🔢 Code: $code');
    
    final deviceId = await _deviceService.getDeviceId();
    debugPrint('[AUTH_SERVICE] 📱 Device ID: $deviceId');
    
    final data = {
      'phone': phone,
      'code': code,
      'device_id': deviceId,
    };
    if (deviceToken != null) {
      data['device_token'] = deviceToken;
    }
    
    debugPrint('[AUTH_SERVICE] 📤 Enviando POST para /app/auth/verify-otp');
    debugPrint('[AUTH_SERVICE] 📤 Data: $data');
    
    try {
      final response = await _apiClient.post(
        '/app/auth/verify-otp',
        data: data,
        requiresAuth: false,
      );
      debugPrint('[AUTH_SERVICE] ✅ Resposta recebida: ${response.data}');
      return response.data;
    } catch (e) {
      debugPrint('[AUTH_SERVICE] ❌ Erro no verificarOTP: $e');
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
  Future<Map<String, dynamic>> registrar(Map<String, dynamic> data, {String? deviceToken}) async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      data['device_id'] = deviceId;
      if (deviceToken != null) {
        data['device_token'] = deviceToken;
      }
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

  /// Envia device token
  Future<void> sendDeviceToken(String deviceToken) async {
    final deviceId = await _deviceService.getDeviceId();
    await _apiClient.post(
      'app/auth/device-token',
      data: {
        'device_token': deviceToken,
        'device_id': deviceId,
      },
      requiresAuth: true,
    );
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
