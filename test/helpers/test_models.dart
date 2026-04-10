import 'package:quipede/app/models/loja_resumo_model.dart';
import 'package:quipede/app/models/loja_resumo_response_model.dart';
import 'package:quipede/app/models/pagination_model.dart';
import 'package:quipede/app/models/lojas_list_filter_option_model.dart';
import 'package:quipede/app/models/loja_detalhe_model.dart';
import 'package:quipede/app/models/filter_options_model.dart';

class TestModels {
  static LojaResumo createLojaResumo({
    int id = 1,
    String nome = 'Loja Teste',
    double notaMedia = 4.5,
  }) {
    return LojaResumo(
      id: id,
      nome: nome,
      categoria: 'Teste',
      cidade: 'BH',
      uf: 'MG',
      notaMedia: notaMedia,
      tempoEntregaMin: 30,
      tempoEntregaMax: 60,
      taxaEntrega: 5.0,
      pedidoMinimo: 20.0,
    );
  }

  static List<LojaResumo> createLojaResumoList({int count = 3}) {
    return List.generate(count, (i) => createLojaResumo(id: i + 1, nome: 'Loja ${i + 1}'));
  }

  static PaginationModel createPagination({
    int total = 10,
    int page = 1,
    int perPage = 10,
    int totalPages = 1,
  }) {
    return PaginationModel(
      total: total,
      page: page,
      perPage: perPage,
      totalPages: totalPages,
    );
  }

  static LojaResumoResponseModel createLojaResumoResponse({
    List<LojaResumo>? items,
    PaginationModel? pagination,
  }) {
    return LojaResumoResponseModel(
      items: items ?? createLojaResumoList(),
      pagination: pagination ?? createPagination(),
      filterOptions: const LojasListFilterOptionsModel(categorias: []),
    );
  }

  static LojaDetalheModel createLojaDetalhe({
    int id = 1,
    String nome = 'Loja Detalhe Teste',
  }) {
    return LojaDetalheModel(
      id: id,
      nome: nome,
      slug: 'loja-detalhe-teste',
      categoria: 'Teste',
      logo: '',
      capa: '',
      enderecoCompleto: 'Rua Teste, 123',
      enderecoResumido: 'Rua Teste',
      notaMedia: 4.8,
      totalAvaliacoes: 100,
      tempoEntregaMin: 30,
      tempoEntregaMax: 50,
      taxaEntrega: 7.0,
      pedidoMinimo: 30.0,
      destaque: true,
      verificado: true,
      status: 'aberto',
      fluxoStatus: 'normal',
      corTema: '#FFFFFF',
      secoes: const [],
      pagination: createPagination(),
      filterOptions: const LojaFilterOptions(categorias: [], ordenacao: []),
    );
  }
}
