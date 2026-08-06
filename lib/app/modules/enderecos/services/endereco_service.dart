import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:quipede/shared/api/api_client.dart';
import 'package:quipede/shared/services/device_id_service.dart';
import '../models/endereco_model.dart';

class EnderecoService {
  final ApiClient _apiClient;

  EnderecoService(this._apiClient);

  /// Lista todos os endereços do usuário
  Future<List<EnderecoModel>> getEnderecos() async {
    try {
      debugPrint('📡 [EnderecoService] GET /app/enderecos');

      final response = await _apiClient.get('/app/enderecos');

      debugPrint('📡 [EnderecoService] Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        if (data is List) {
          return data.map((json) => EnderecoModel.fromJson(json as Map<String, dynamic>)).toList();
        }

        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          return [EnderecoModel.fromJson(map)];
        }

        return [];
      }

      return [];
    } catch (e) {
      debugPrint('❌ [EnderecoService] Erro ao carregar endereços: $e');
      return [];
    }
  }

  /// Cria um novo endereço (suporta convidado)
  Future<Map<String, dynamic>> criarEndereco(EnderecoModel endereco) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      debugPrint('📡 [EnderecoService] DeviceId: $deviceId');

      final data = endereco.toJson();
      data['device_id'] = deviceId;

      debugPrint('📡 [EnderecoService] POST /app/enderecos');

      final response = await _apiClient.post(
        '/app/enderecos',
        data: data,
        requiresAuth: false,
      );

      debugPrint('📡 [EnderecoService] Status: ${response.statusCode}');

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {

        final resultData = response.data['data'];
        debugPrint('✅ [EnderecoService] Endereço criado com sucesso');

        if (resultData is List) {
          return {
            'endereco': resultData.isNotEmpty ? resultData.first : null,
            'usuario': null,
            'token': null,
          };
        }

        return resultData ?? {};
      }

      throw Exception('Erro ao criar endereço: ${response.data['message'] ?? ''}');
    } on DioException catch (e) {
      debugPrint('❌ [EnderecoService] DioException: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [EnderecoService] Erro ao criar endereço: $e');
      rethrow;
    }
  }

  /// Atualiza um endereço
  Future<EnderecoModel> atualizarEndereco(EnderecoModel endereco) async {
    try {
      final response = await _apiClient.put(
        '/app/enderecos/${endereco.id}',
        data: endereco.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return EnderecoModel.fromJson(response.data['data']);
      }
      throw Exception('Erro ao atualizar endereço');
    } catch (e) {
      rethrow;
    }
  }

  /// Remove um endereço
  Future<void> deletarEndereco(int id) async {
    try {
      final response = await _apiClient.delete('/app/enderecos/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao excluir endereço');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Define um endereço como principal (retorna lista completa)
  Future<List<EnderecoModel>> definirPrincipal(int id) async {
    try {
      debugPrint('📡 [EnderecoService] PUT /app/enderecos/$id/set-padrao');

      final response = await _apiClient.put(
        '/app/enderecos/$id/set-padrao',
        data: {},
      );

      debugPrint('📡 [EnderecoService] Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✅ [EnderecoService] Endereço definido como principal');

        final data = response.data['data'];

        // ✅ Agora retorna lista completa
        if (data is List) {
          return data.map((json) => EnderecoModel.fromJson(json as Map<String, dynamic>)).toList();
        }

        // Fallback: se voltar objeto único
        if (data is Map) {
          return [EnderecoModel.fromJson(Map<String, dynamic>.from(data))];
        }

        return [];
      }

      throw Exception('Erro ao definir endereço principal: ${response.data['message'] ?? 'Resposta inesperada'}');
    } on DioException catch (e) {
      debugPrint('❌ [EnderecoService] DioException: ${e.response?.statusCode}');
      debugPrint('❌ [EnderecoService] URL: ${e.requestOptions.uri}');
      debugPrint('❌ [EnderecoService] Response: ${e.response?.data}');
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ [EnderecoService] Erro ao definir principal: $e');
      debugPrint('❌ [EnderecoService] Stack: $stack');
      rethrow;
    }
  }

  /// Busca CEP via ViaCEP
  Future<Map<String, String>> buscarCep(String cep) async {
    try {
      final response = await _apiClient.post(
        '/app/enderecos/buscar-cep',
        data: {'cep': cep},
        requiresAuth: false,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, String>.from(response.data['data']);
      }
      throw Exception('CEP não encontrado');
    } catch (e) {
      rethrow;
    }
  }
}
