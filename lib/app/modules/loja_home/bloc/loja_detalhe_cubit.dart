import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/loja_repository.dart';
import 'loja_detalhe_state.dart';
import '../../../models/secao_model.dart';

class LojaDetalheCubit extends Cubit<LojaDetalheState> {
  final LojaHomeRepository _repository;
  final int lojaId;

  LojaDetalheCubit(this._repository, this.lojaId) : super(LojaDetalheInitial());

  Future<void> loadLoja() async {
    emit(LojaDetalheLoading());
    try {
      final loja = await _repository.getLojaDetalhe(id: lojaId);
      emit(LojaDetalheLoaded(
        loja: loja,
        secoes: loja.secoes,
        hasMore: loja.pagination.page < loja.pagination.totalPages,
      ));
    } catch (e) {
      emit(const LojaDetalheError('Erro ao carregar loja'));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is LojaDetalheLoaded && !currentState.isLoadingMore && currentState.hasMore) {
      emit(currentState.copyWith(isLoadingMore: true));
      try {
        final nextPage = currentState.loja.pagination.page + 1;
        final response = await _repository.getLojaDetalhe(
          id: lojaId,
          page: nextPage,
          categoriaId: currentState.categoriaId,
          search: currentState.search,
          orderBy: currentState.orderBy,
        );

        final mergedSecoes = _mergeSecoes(currentState.secoes, response.secoes);

        emit(currentState.copyWith(
          loja: response,
          secoes: mergedSecoes,
          hasMore: response.pagination.page < response.pagination.totalPages,
          isLoadingMore: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  List<SecaoModel> _mergeSecoes(List<SecaoModel> current, List<SecaoModel> next) {
    final Map<int, SecaoModel> map = {for (var s in current) s.id: s};
    for (var n in next) {
      if (map.containsKey(n.id)) {
        final existing = map[n.id]!;
        map[n.id] = SecaoModel(
          id: existing.id,
          nome: existing.nome,
          icone: existing.icone,
          ordem: existing.ordem,
          totalProdutos: n.totalProdutos,
          produtos: [...existing.produtos, ...n.produtos],
        );
      } else {
        map[n.id] = n;
      }
    }
    final merged = map.values.toList();
    merged.sort((a, b) => a.ordem.compareTo(b.ordem));
    return merged;
  }

  Future<void> filterByCategoria(int? categoriaId) async {
    final currentState = state;
    if (currentState is LojaDetalheLoaded) {
      emit(LojaDetalheLoading());
      try {
        final loja = await _repository.getLojaDetalhe(
          id: lojaId,
          categoriaId: categoriaId,
          search: currentState.search,
          orderBy: currentState.orderBy,
        );
        emit(LojaDetalheLoaded(
          loja: loja,
          secoes: loja.secoes,
          hasMore: loja.pagination.page < loja.pagination.totalPages,
          categoriaId: categoriaId,
          search: currentState.search,
          orderBy: currentState.orderBy,
        ));
      } catch (e) {
        emit(const LojaDetalheError('Erro ao filtrar produtos'));
      }
    }
  }

  Future<void> searchProdutos(String query) async {
    final currentState = state;
    if (currentState is LojaDetalheLoaded) {
      emit(LojaDetalheLoading());
      try {
        final loja = await _repository.getLojaDetalhe(
          id: lojaId,
          search: query,
          categoriaId: currentState.categoriaId,
          orderBy: currentState.orderBy,
        );
        emit(LojaDetalheLoaded(
          loja: loja,
          secoes: loja.secoes,
          hasMore: loja.pagination.page < loja.pagination.totalPages,
          search: query,
          categoriaId: currentState.categoriaId,
          orderBy: currentState.orderBy,
        ));
      } catch (e) {
        emit(const LojaDetalheError('Erro ao buscar produtos'));
      }
    }
  }

  Future<void> changeOrderBy(String orderBy) async {
    final currentState = state;
    if (currentState is LojaDetalheLoaded) {
      emit(LojaDetalheLoading());
      try {
        final loja = await _repository.getLojaDetalhe(
          id: lojaId,
          orderBy: orderBy,
          categoriaId: currentState.categoriaId,
          search: currentState.search,
        );
        emit(LojaDetalheLoaded(
          loja: loja,
          secoes: loja.secoes,
          hasMore: loja.pagination.page < loja.pagination.totalPages,
          orderBy: orderBy,
          categoriaId: currentState.categoriaId,
          search: currentState.search,
        ));
      } catch (e) {
        emit(const LojaDetalheError('Erro ao ordenar produtos'));
      }
    }
  }

  Future<void> refresh() async {
    await loadLoja();
  }
}
