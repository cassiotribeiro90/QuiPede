import 'package:flutter/foundation.dart';
import 'package:quipede/shared/api/api_client.dart';
import 'package:quipede/app_config.dart';
import '../models/endereco_sugestao.dart';

class LocalizacaoService {
  final ApiClient _apiClient;

  LocalizacaoService(this._apiClient);

  Future<Map<String, dynamic>> geocodificar(double latitude, double longitude) async {
    try {
      final response = await _apiClient.post(
        AppConfig.geocodificar,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
        requiresAuth: false,
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ [LocalizacaoService] Erro ao geocodificar: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<EnderecoSugestao>> buscarEndereco({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _apiClient.get(
        AppConfig.buscarEndereco,
        queryParameters: {
          'query': query,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
        requiresAuth: false,
      );
      
      if (response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => EnderecoSugestao.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ [LocalizacaoService] Erro ao buscar endereço: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> buscarCep(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    debugPrint('📡 [LocalizacaoService] Buscando CEP: $cepLimpo');
    try {
      final response = await _apiClient.post(
        AppConfig.buscarCep,
        data: {'cep': cepLimpo},
        requiresAuth: false,
      );
      debugPrint('📡 [LocalizacaoService] Status: ${response.statusCode}');
      return response.data;
    } catch (e) {
      debugPrint('❌ [LocalizacaoService] Erro ao buscar CEP: $e');
      return {'success': false, 'message': 'CEP não encontrado ou erro na rede.'};
    }
  }

  Future<Map<String, dynamic>> confirmarEndereco(Map<String, dynamic> dados) async {
    try {
      final response = await _apiClient.post(
        AppConfig.confirmarEndereco,
        data: dados,
        requiresAuth: false,
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ [LocalizacaoService] Erro ao confirmar endereço: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
