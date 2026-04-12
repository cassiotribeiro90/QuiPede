import '../../../../shared/api/api_client.dart';
import '../../../models/loja_resumo_model.dart';
import '../../../models/loja_resumo_response_model.dart';
import '../../../models/enums.dart';
import 'loja_repository.dart';

class LojaRepositoryImpl implements LojaRepository {
  final ApiClient _apiClient;

  LojaRepositoryImpl(this._apiClient);

  @override
  Future<LojaResumoResponseModel> getLojas({
    int page = 1,
    int perPage = 10,
    String? categoria,
    String? busca,
    String? ordenarPor,
    bool? apenasAbertas,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiClient.get(
      '/app/lojas', // Corrigido de '/app/loja' para '/app/lojas'
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (categoria != null && categoria.isNotEmpty) 'categoria': categoria,
        if (busca != null && busca.isNotEmpty) 'search': busca,
        if (ordenarPor != null && ordenarPor.isNotEmpty) 'order_by': ordenarPor,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
      requiresAuth: false,
    );

    if (response.data['success'] == true) {
      return LojaResumoResponseModel.fromJson(response.data);
    } else {
      throw Exception(response.data['message'] ?? 'Erro ao buscar lojas');
    }
  }

  @override
  Future<LojaResumo> getLojaById(int id) async {
    final response = await _apiClient.get('/app/lojas/$id', requiresAuth: false);
    return LojaResumo.fromJson(response.data['data']);
  }

  @override
  Future<List<LojaResumo>> getLojasDestaque() async {
    final response = await _apiClient.get('/app/lojas/destaque', requiresAuth: false);
    if (response.data['success'] == true) {
      final List items = response.data['data'];
      return items.map((json) => LojaResumo.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<List<CategoriaTipo>> getCategorias() async {
    return [];
  }
}
