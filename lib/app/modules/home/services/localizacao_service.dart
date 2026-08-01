import '../../../../shared/api/api_client.dart';
import '../../../../app_config.dart';
import '../models/endereco_sugestao.dart';

class LocalizacaoService {
  final ApiClient _apiClient;

  LocalizacaoService(this._apiClient);

  /// 🔥 GEOCODIFICAR - CONVERTE COORDENADAS EM ENDEREÇO
  Future<Map<String, dynamic>> geocodificar(double lat, double lng) async {
    try {
      final response = await _apiClient.get(
        AppConfig.GEOCODIFICAR,
        queryParameters: {'latitude': lat, 'longitude': lng},
        requiresAuth: false,
      );
      return response.data;
    } catch (e) {
      print('❌ [LocalizacaoService] Erro ao geocodificar: $e');
      return {'success': false, 'message': 'Erro ao geocodificar'};
    }
  }

  /// 🔥 BUSCAR ENDEREÇO POR TEXTO (sugestões)
  Future<List<EnderecoSugestao>> buscarEndereco({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final Map<String, dynamic> params = {'q': query};
      if (latitude != null) params['latitude'] = latitude;
      if (longitude != null) params['longitude'] = longitude;

      final response = await _apiClient.get(
        AppConfig.BUSCAR_ENDERECO,
        queryParameters: params,
        requiresAuth: false,
      );

      if (response.data != null && response.data['success'] == true) {
        final List items = response.data['data']['items'] ?? [];
        return items.map((e) => EnderecoSugestao.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print('❌ [LocalizacaoService] Erro ao buscar endereço: $e');
      return [];
    }
  }

  /// 🔥 BUSCAR CEP - CORRIGIDO (USANDO POST COM ROTA CORRETA)
  Future<Map<String, dynamic>> buscarCep(String cep) async {
    try {
      final cepLimpo = cep.replaceAll(RegExp(r'\D'), '');
      print('📡 [LocalizacaoService] Buscando CEP: $cepLimpo');

      // 🔥 CORRIGIDO: usa POST em vez de GET, e rota correta
      final response = await _apiClient.post(
        '/app/enderecos/buscar-cep',  // 🔥 ROTA CORRETA
        data: {'cep': cepLimpo},
        requiresAuth: false,
      );

      print('📡 [LocalizacaoService] Status: ${response.statusCode}');
      return response.data;
    } catch (e) {
      print('❌ [LocalizacaoService] Erro ao buscar CEP: $e');
      return {
        'success': false,
        'message': 'Erro ao buscar CEP: $e',
      };
    }
  }

  /// 🔥 CONFIRMAR ENDEREÇO
  Future<Map<String, dynamic>> confirmarEndereco(Map<String, dynamic> dados) async {
    try {
      final response = await _apiClient.post(
        AppConfig.CONFIRMAR_ENDERECO,
        data: dados,
        requiresAuth: false,
      );
      return response.data;
    } catch (e) {
      print('❌ [LocalizacaoService] Erro ao confirmar endereço: $e');
      return {
        'success': false,
        'message': 'Erro ao confirmar endereço',
      };
    }
  }
}