
import '../../../../shared/api/api_client.dart';
import '../models/loja_detalhe_model.dart';
import '../models/secao_produto_model.dart';

class LojaHomeRepository {
  final ApiClient _apiClient;

  LojaHomeRepository(this._apiClient);

  Future<LojaDetalheModel> getLojaDetalhe(int id, {String? orderBy, int? categoriaId}) async {
    try {
      final response = await _apiClient.get('/app/loja-home', queryParameters: {
        'id': id,
        'order_by': orderBy,
        'categoria_id': categoriaId,
      });
      return LojaDetalheModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SecaoProdutoModel>> searchProdutos(int lojaId, String query, {String? orderBy, int? categoriaId}) async {
    try {
      final response = await _apiClient.get('/app/loja-home/search', queryParameters: {
        'id': lojaId,
        'q': query,
        'order_by': orderBy,
        'categoria_id': categoriaId,
      });
      return (response.data['data']['secoes'] as List)
          .map((e) => SecaoProdutoModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
