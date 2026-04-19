import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quipede/app/modules/home/bloc/localizacao_cubit.dart';
import 'package:quipede/app/modules/home/bloc/localizacao_state.dart';
import 'package:quipede/app/modules/lojas_list/bloc/lojas_cubit.dart';
import 'package:quipede/app/modules/lojas_list/bloc/lojas_state.dart';
import 'package:quipede/app/modules/lojas_list/repository/loja_repository.dart';
import 'package:quipede/app/models/loja_resumo_model.dart';
import 'package:quipede/app/models/loja_resumo_response_model.dart';
import 'package:quipede/app/models/enums.dart';

import '../../../helpers/test_models.dart';

// Mock manual para evitar dependência do build_runner
class MockLocalizacaoCubit extends Mock implements LocalizacaoCubit {}

// Implementação Fake manual para evitar dependência do build_runner em alguns cenários
class FakeLojaRepository implements LojaRepository {
  @override
  Future<LojaResumoResponseModel> getLojas({
    String? categoria,
    String? busca,
    String? ordenarPor,
    bool? apenasAbertas,
    double? latitude,
    double? longitude,
    int page = 1,
    int perPage = 10,
  }) async {
    return TestModels.createLojaResumoResponse();
  }

  @override
  Future<LojaResumo> getLojaById(int id) async {
    return TestModels.createLojaResumo(id: id);
  }

  @override
  Future<List<LojaResumo>> getLojasDestaque() async {
    return TestModels.createLojaResumoList();
  }

  @override
  Future<List<CategoriaTipo>> getCategorias() async {
    return [];
  }
}

void main() {
  late LojasCubit cubit;
  late FakeLojaRepository fakeRepository;
  late MockLocalizacaoCubit mockLocalizacaoCubit;

  setUp(() {
    fakeRepository = FakeLojaRepository();
    mockLocalizacaoCubit = MockLocalizacaoCubit();
    
    // Configura o estado inicial do mock
    when(mockLocalizacaoCubit.state).thenReturn(LocalizacaoInitial());
    when(mockLocalizacaoCubit.stream).thenAnswer((_) => Stream.fromIterable([]));

    cubit = LojasCubit(fakeRepository, mockLocalizacaoCubit);
  });

  tearDown(() {
    cubit.close();
  });

  group('LojasCubit Tests (Com FakeRepository)', () {
    test('estado inicial deve ser LojasInitial', () {
      expect(cubit.state, isA<LojasInitial>());
    });

    blocTest<LojasCubit, LojasState>(
      'deve emitir [LojasLoading, LojasLoaded] ao buscar lojas br sucesso',
      build: () => cubit,
      act: (cubit) => cubit.fetchLojas(),
      expect: () => [
        isA<LojasLoading>(),
        isA<LojasLoaded>(),
      ],
    );

    blocTest<LojasCubit, LojasState>(
      'deve manter o termo de busca no estado após pesquisar',
      build: () => cubit,
      act: (cubit) => cubit.searchLojas('pizza'),
      expect: () => [
        isA<LojasLoading>(),
        isA<LojasLoaded>().having((s) => s.searchQuery, 'termo de busca', 'pizza'),
      ],
    );
  });
}
