import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/loja_repository.dart';
import 'loja_detalhe_state.dart';

class LojaDetalheCubit extends Cubit<LojaDetalheState> {
  final LojaHomeRepository _repository;

  LojaDetalheCubit(this._repository) : super(LojaDetalheInitial());

  Future<void> loadLoja(int id) async {
    emit(LojaDetalheLoading());
    try {
      final loja = await _repository.getLojaDetalhe(id);
      emit(LojaDetalheLoaded(
        loja: loja,
        secoes: loja.secoes,
      ));
    } catch (e) {
      emit(LojaDetalheError('Erro ao carregar dados da loja: ${e.toString()}'));
    }
  }

  Future<void> searchProdutos(String query) async {
    final currentState = state;
    if (currentState is LojaDetalheLoaded) {
      emit(LojaDetalheSearchLoading(
        loja: currentState.loja,
        secoes: currentState.secoes,
        searchQuery: query,
        selectedCategoriaId: currentState.selectedCategoriaId,
        orderBy: currentState.orderBy,
      ));

      try {
        final secoes = await _repository.searchProdutos(
          currentState.loja.id,
          query,
          orderBy: currentState.orderBy,
          categoriaId: currentState.selectedCategoriaId,
        );
        emit(currentState.copyWith(
          secoes: secoes,
          searchQuery: query,
        ));
      } catch (e) {
        emit(LojaDetalheError('Erro ao buscar produtos: ${e.toString()}'));
      }
    }
  }

  Future<void> applyFilters({int? categoriaId, String? orderBy}) async {
    final currentState = state;
    if (currentState is LojaDetalheLoaded) {
      emit(LojaDetalheLoading());
      try {
        final loja = await _repository.getLojaDetalhe(
          currentState.loja.id,
          orderBy: orderBy,
          categoriaId: categoriaId,
        );
        emit(LojaDetalheLoaded(
          loja: loja,
          secoes: loja.secoes,
          selectedCategoriaId: categoriaId,
          orderBy: orderBy,
          searchQuery: currentState.searchQuery,
        ));
      } catch (e) {
        emit(LojaDetalheError('Erro ao aplicar filtros: ${e.toString()}'));
      }
    }
  }

  void clearSearch() {
    final currentState = state;
    if (currentState is LojaDetalheLoaded) {
      loadLoja(currentState.loja.id);
    }
  }
}
