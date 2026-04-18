import '../../../../shared/api/api_client.dart';
import '../../../../app_config.dart';
import '../models/endereco_sugestao.dart';

class LocalizacaoService {
  final ApiClient _apiClient;

  LocalizacaoService(this._apiClient);

  Future<Map<String, dynamic>> geocodificar(double lat, double lng) async {
    final response = await _apiClient.get(
      AppConfig.GEOCODIFICAR,
      queryParameters: {'latitude': lat, 'longitude': lng},
      requiresAuth: false,
    );
    return response.data;
  }

  Future<List<EnderecoSugestao>> buscarEndereco({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    final Map<String, dynamic> params = {'q': query};
    if (latitude != null) params['latitude'] = latitude;
    if (longitude != null) params['longitude'] = longitude;

    final response = await _apiClient.get(
      AppConfig.BUSCAR_ENDERECO,
      queryParameters: params,
      requiresAuth: false,
    );

    if (response.data != null && response.data['success'] == true) {
      // Ajuste: A API retorna data -> items
      final List items = response.data['data']['items'] ?? [];
      return items.map((e) => EnderecoSugestao.fromJson(e)).toList();
    }
    
    return [];
  }

  Future<Map<String, dynamic>> buscarCep(String cep) async {
    final response = await _apiClient.get(
      AppConfig.BUSCAR_CEP,
      queryParameters: {'cep': cep.replaceAll(RegExp(r'\D'), '')},
      requiresAuth: false,
    );
    return response.data;
  }
}
