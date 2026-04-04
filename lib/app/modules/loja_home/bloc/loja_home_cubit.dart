import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/produto_model.dart';
import '../repository/loja_repository.dart';
import 'loja_home_state.dart';

class LojaHomeCubit extends Cubit<LojaHomeState> {
  final LojaHomeRepository _repository;
  final int lojaId;
  
  int _currentPage = 1;
  int _totalPages = 1;
  String? _searchQuery;
  int? _selectedCategoriaId;
  String? _orderBy;
  List<ProdutoModel> _allProdutos = [];

  LojaHomeCubit(this._repository, this.lojaId) : super(LojaHomeInitial());

  Future<void> loadLoja({bool reset = true}) async {
    if (reset) {
      _currentPage = 1;
      _allProdutos = [];
      emit(LojaHomeLoading());
    } else {
      final currentState = state;
      if (currentState is LojaHomeLoaded) {
        emit(currentState.copyWith(isLoadingMore: true));
      } else {
        emit(LojaHomeLoadingMore());
      }
    }

    try {
      final response = await _repository.getLojaDetalhe(
        id: lojaId,
        page: _currentPage,
        perPage: 20,
        categoriaId: _selectedCategoriaId,
        search: _searchQuery,
        orderBy: _orderBy,
      );

      _totalPages = response.pagination.totalPages;
      final novosProdutos = response.items;
      _allProdutos = reset ? novosProdutos : [..._allProdutos, ...novosProdutos];

      emit(LojaHomeLoaded(
        loja: response,
        produtos: _allProdutos,
        produtosPorCategoria: _groupByCategoria(_allProdutos),
        selectedCategories: _selectedCategoriaId != null ? [_selectedCategoriaId!] : [],
        orderBy: _orderBy,
        activeFilterCount: (_selectedCategoriaId != null ? 1 : 0) + 
                          (_orderBy != null ? 1 : 0) +
                          (_searchQuery != null && _searchQuery!.isNotEmpty ? 1 : 0),
        hasMore: _currentPage < _totalPages,
        currentPage: _currentPage,
        totalPages: _totalPages,
        searchQuery: _searchQuery,
      ));
    } catch (e) {
      emit(LojaHomeError('Erro ao carregar dados da loja: $e'));
    }
  }

  void loadMore() {
    if (state is LojaHomeLoaded && _currentPage < _totalPages && state is! LojaHomeLoadingMore) {
      _currentPage++;
      loadLoja(reset: false);
    }
  }

  Map<int, List<ProdutoModel>> _groupByCategoria(List<ProdutoModel> items) {
    final Map<int, List<ProdutoModel>> map = {};
    for (var item in items) {
      final catId = item.subcategoriaId ?? 0;
      if (!map.containsKey(catId)) map[catId] = [];
      map[catId]!.add(item);
    }
    return map;
  }

  Future<void> applyFilters({String? search, int? categoriaId, String? orderBy}) async {
    _searchQuery = search;
    _selectedCategoriaId = categoriaId;
    _orderBy = orderBy;
    _currentPage = 1;
    await loadLoja(reset: true);
  }

  Future<void> clearFilters() async {
    _searchQuery = null;
    _selectedCategoriaId = null;
    _orderBy = null;
    _currentPage = 1;
    await loadLoja(reset: true);
  }

  Future<void> refresh() async {
    await loadLoja(reset: true);
  }
}
