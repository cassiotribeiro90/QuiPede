import '../../../models/enums.dart';
import '../../../models/loja_resumo_model.dart';
import '../../../models/loja_resumo_response_model.dart';

/// Abstração do repositório de lojas
abstract class LojaRepository {
  /// Busca lojas br filtros e paginação
  Future<LojaResumoResponseModel> getLojas({
    String? categoria,
    String? busca,
    String? ordenarPor,
    bool? apenasAbertas,
    double? latitude,
    double? longitude,
    int page = 1,
    int perPage = 10,
  });

  /// Busca lojas em destaque
  Future<List<LojaResumo>> getLojasDestaque();

  /// Busca uma loja específica por ID
  Future<LojaResumo> getLojaById(int id);

  /// Busca categorias disponíveis (opcional se usar o filter_options do getLojas)
  Future<List<CategoriaTipo>> getCategorias();
}
