import '../../../../shared/api/api_client.dart';
import '../../../models/loja_detalhe_model.dart';

class LojaHomeRepository {
  final ApiClient _apiClient;

  LojaHomeRepository(this._apiClient);

  Future<LojaDetalheModel> getLojaDetalhe({
    required int id,
    int page = 1,
    int perPage = 20,
    int? categoriaId,
    String? search,
    String? orderBy,
  }) async {
    try {
      final response = await _apiClient.get('/app/loja-home', queryParameters: {
        'id': id,
        'page': page,
        'per_page': perPage,
        if (categoriaId != null) 'categoria_id': categoriaId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (orderBy != null) 'order_by': orderBy,
      });
      return LojaDetalheModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
