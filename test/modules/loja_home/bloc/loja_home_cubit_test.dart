import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quipede/app/modules/loja_home/bloc/loja_home_cubit.dart';
import 'package:quipede/app/modules/loja_home/bloc/loja_home_state.dart';
import 'package:quipede/app/modules/loja_home/repository/loja_repository.dart';
import 'package:quipede/app/models/loja_detalhe_model.dart';
import 'package:quipede/app/models/secao_model.dart';
import 'package:quipede/app/models/produto_model.dart';
import 'package:quipede/app/models/pagination_model.dart';
import 'package:quipede/app/models/filter_options_model.dart';
import 'package:quipede/app/models/categoria_filter_model.dart';

// ===== FAKE REPOSITORY =====
class FakeLojaHomeRepository implements LojaHomeRepository {
  bool shouldThrowError = false;

  @override
  Future<LojaDetalheModel> getLojaDetalhe({
    required int id,
    int page = 1,
    int perPage = 20,
    int? categoriaId,
    String? search,
    String? orderBy,
  }) async {
    if (shouldThrowError) {
      throw Exception('Erro ao carregar loja');
    }
    
    // Criar seções de exemplo
    final secoes = [
      SecaoModel(
        id: 1,
        nome: 'Pizzas Salgadas',
        icone: '🍕',
        ordem: 1,
        totalProdutos: 2,
        produtos: [
          ProdutoModel(
            id: 1,
            nome: 'Pizza Margherita',
            preco: 45.90,
            disponivel: true,
            destaque: true,
            vendasHoje: 10,
            notaMedia: 4.5,
            totalAvaliacoes: 50,
            subcategoriaId: 1,
            subcategoriaNome: 'Pizzas Salgadas',
          ),
        ],
      ),
    ];
    
    final pagination = PaginationModel(
      total: 1,
      page: page,
      perPage: perPage,
      totalPages: 1,
    );
    
    final filterOptions = LojaFilterOptions(
      categorias: [
        CategoriaFilterModel(id: 1, nome: 'Pizzas Salgadas', icone: '🍕', totalProdutos: 1),
      ],
      ordenacao: [],
    );
    
    return LojaDetalheModel(
      id: id,
      nome: 'Pizzaria Teste',
      slug: 'pizzaria-teste',
      categoria: 'Pizzarias',
      logo: 'https://test.br/logo.png',
      capa: 'https://test.br/capa.png',
      enderecoCompleto: 'Rua Teste, 123',
      enderecoResumido: 'Rua Teste',
      notaMedia: 4.5,
      totalAvaliacoes: 100,
      tempoEntregaMin: 30,
      tempoEntregaMax: 60,
      taxaEntrega: 5.0,
      pedidoMinimo: 20.0,
      destaque: true,
      verificado: true,
      status: 'ativo',
      fluxoStatus: 'normal',
      corTema: '#FF0000',
      secoes: secoes,
      pagination: pagination,
      filterOptions: filterOptions,
    );
  }
}

void main() {
  late LojaHomeCubit cubit;
  late FakeLojaHomeRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeLojaHomeRepository();
    cubit = LojaHomeCubit(fakeRepository, 1);
  });

  tearDown(() {
    cubit.close();
  });

  group('LojaHomeCubit Tests', () {
    test('initial state should be LojaHomeInitial', () {
      expect(cubit.state, isA<LojaHomeInitial>());
    });

    blocTest<LojaHomeCubit, LojaHomeState>(
      'emits [LojaHomeLoading, LojaHomeLoaded] when loadLoja succeeds',
      build: () => cubit,
      act: (cubit) => cubit.loadLoja(),
      expect: () => [
        isA<LojaHomeLoading>(),
        isA<LojaHomeLoaded>(),
      ],
    );

    blocTest<LojaHomeCubit, LojaHomeState>(
      'emits [LojaHomeLoading, LojaHomeError] when loadLoja fails',
      build: () {
        fakeRepository.shouldThrowError = true;
        return cubit;
      },
      act: (cubit) => cubit.loadLoja(),
      expect: () => [
        isA<LojaHomeLoading>(),
        isA<LojaHomeError>(),
      ],
    );

    blocTest<LojaHomeCubit, LojaHomeState>(
      'applies search filter correctly',
      build: () => cubit,
      act: (cubit) => cubit.applyFilters(search: 'pizza'),
      expect: () => [
        isA<LojaHomeLoading>(),
        isA<LojaHomeLoaded>().having((s) => (s).searchQuery, 'searchQuery', 'pizza'),
      ],
    );
  });
}
