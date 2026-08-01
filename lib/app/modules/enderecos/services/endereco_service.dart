import 'package:dio/dio.dart';
import 'package:quipede/shared/api/api_client.dart';
import 'package:quipede/shared/services/device_id_service.dart';
import 'package:quipede/shared/services/token_service.dart';
import '../models/endereco_model.dart';

class EnderecoService {
  final ApiClient _apiClient;

  EnderecoService(this._apiClient);

  /// Lista todos os endereços do usuário
  Future<List<EnderecoModel>> getEnderecos() async {
    try {
      print('📡 [EnderecoService] GET /app/enderecos');

      final response = await _apiClient.get('/app/enderecos');

      print('📡 [EnderecoService] Status: ${response.statusCode}');
      print('📡 [EnderecoService] Resposta: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        if (data is List) {
          print('✅ [EnderecoService] Lista de endereços: ${data.length}');
          return data.map((json) => EnderecoModel.fromJson(json as Map<String, dynamic>)).toList();
        }

        if (data is Map) {
          print('✅ [EnderecoService] Objeto único recebido');
          final map = Map<String, dynamic>.from(data);
          return [EnderecoModel.fromJson(map)];
        }

        print('⚠️ [EnderecoService] data é null ou vazio');
        return [];
      }

      print('⚠️ [EnderecoService] Resposta inesperada: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ [EnderecoService] Erro ao carregar endereços: $e');
      return [];
    }
  }

  /// Cria um novo endereço (suporta convidado)
  Future<Map<String, dynamic>> criarEndereco(EnderecoModel endereco) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      print('📡 [EnderecoService] DeviceId: $deviceId');

      final data = endereco.toJson();
      data['device_id'] = deviceId;

      print('📡 [EnderecoService] POST /app/enderecos');
      print('📡 [EnderecoService] Dados: $data');

      final response = await _apiClient.post(
        '/app/enderecos',
        data: data,
        requiresAuth: false,
      );

      print('📡 [EnderecoService] Status: ${response.statusCode}');
      print('📡 [EnderecoService] Resposta: ${response.data}');

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {

        final resultData = response.data['data'];
        print('✅ [EnderecoService] Endereço criado com sucesso');
        print('📦 [EnderecoService] ResultData: $resultData');

        // 🔥 SE resultData FOR UMA LISTA, CONVERTE PARA O PRIMEIRO ITEM
        if (resultData is List) {
          if (resultData.isNotEmpty) {
            return {
              'endereco': resultData.first,
              'usuario': null,
              'token': null,
            };
          }
          return {
            'endereco': null,
            'usuario': null,
            'token': null,
          };
        }

        // 🔥 SALVA O TOKEN SE RETORNAR
        if (resultData != null && resultData['token'] != null && resultData['token'] is String) {
          final token = resultData['token'] as String;
          await _apiClient.tokenService.saveTokens(
            token,
            null,
            expiresIn: 86400,
          );
          print('✅ [EnderecoService] Token do convidado salvo!');
        }

        return resultData ?? {};
      }

      print('❌ [EnderecoService] Falha: ${response.data}');
      throw Exception('Erro ao criar endereço: ${response.data['message'] ?? ''}');
    } on DioException catch (e) {
      print('❌ [EnderecoService] DioException');
      if (e.response != null) {
        print('❌ Status: ${e.response?.statusCode}');
        print('❌ Data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ [EnderecoService] Erro ao criar endereço: $e');
      rethrow;
    }
  }

  /// Atualiza um endereço
  Future<EnderecoModel> atualizarEndereco(EnderecoModel endereco) async {
    try {
      print('📡 [EnderecoService] PUT /app/enderecos/${endereco.id}');

      final response = await _apiClient.put(
        '/app/enderecos/${endereco.id}',
        data: endereco.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ [EnderecoService] Endereço atualizado');
        return EnderecoModel.fromJson(response.data['data']);
      }
      throw Exception('Erro ao atualizar endereço');
    } catch (e) {
      print('❌ [EnderecoService] Erro ao atualizar endereço: $e');
      rethrow;
    }
  }

  /// Remove um endereço
  Future<void> deletarEndereco(int id) async {
    try {
      print('📡 [EnderecoService] DELETE /app/enderecos/$id');

      final response = await _apiClient.delete('/app/enderecos/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao excluir endereço');
      }
      print('✅ [EnderecoService] Endereço removido');
    } catch (e) {
      print('❌ [EnderecoService] Erro ao excluir endereço: $e');
      rethrow;
    }
  }

  /// Define um endereço como principal
  Future<EnderecoModel> definirPrincipal(int id) async {
    try {
      print('📡 [EnderecoService] POST /app/enderecos/$id/padrao');

      final response = await _apiClient.post(
        '/app/enderecos/$id/padrao',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ [EnderecoService] Endereço principal definido');
        return EnderecoModel.fromJson(response.data['data']);
      }
      throw Exception('Erro ao definir endereço principal');
    } catch (e) {
      print('❌ [EnderecoService] Erro ao definir principal: $e');
      rethrow;
    }
  }

  /// Busca CEP via ViaCEP
  Future<Map<String, String>> buscarCep(String cep) async {
    try {
      print('📡 [EnderecoService] POST /app/enderecos/buscar-cep - CEP: $cep');

      final response = await _apiClient.post(
        '/app/enderecos/buscar-cep',
        data: {'cep': cep},
        requiresAuth: false,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ [EnderecoService] CEP encontrado');
        return Map<String, String>.from(response.data['data']);
      }
      throw Exception('CEP não encontrado');
    } catch (e) {
      print('❌ [EnderecoService] Erro ao buscar CEP: $e');
      rethrow;
    }
  }
}