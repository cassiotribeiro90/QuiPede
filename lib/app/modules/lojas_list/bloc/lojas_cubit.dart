import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/loja_resumo_model.dart';
import 'lojas_state.dart';
import '../repository/loja_repository.dart';
import '../../../models/pagination_model.dart';

class LojasCubit extends Cubit<LojasState> {
  final LojaRepository _repository;
  String? _categoriaAtual;
  String? _ordenacaoAtual;
  String? _searchQuery;
  List<LojaResumo> _todasLojas = [];
  PaginationModel? _lastPagination;
  
  bool _isFetching = false;

  LojasCubit(this._repository) : super(LojasInitial());

  Future<void> fetchLojas({
    int page = 1,
    int perPage = 10,
    bool isLoadMore = false,
    String? categoria,
    String? ordenacao,
    String? search,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      // Atualiza os filtros internos se forem passados
      if (categoria != null) _categoriaAtual = categoria;
      if (ordenacao != null) _ordenacaoAtual = ordenacao;
      if (search != null) _searchQuery = search;

      if (!isLoadMore) {
        emit(LojasLoading());
        _todasLojas = [];
      } else if (state is LojasLoaded) {
        emit((state as LojasLoaded).copyWith(isLoadingMore: true));
      }

      final response = await _repository.getLojas(
        page: page,
        perPage: perPage,
        categoria: _categoriaAtual,
        ordenarPor: _ordenacaoAtual,
        busca: _searchQuery,
      );

      _lastPagination = response.pagination;
      
      if (isLoadMore) {
        _todasLojas.addAll(response.items);
      } else {
        _todasLojas = List.from(response.items); 
      }

      emit(LojasLoaded(
        lojas: List.from(_todasLojas),
        lojasFiltradas: List.from(_todasLojas),
        categorias: response.filterOptions.categorias,
        categoriaSelecionada: _categoriaAtual,
        ordenacaoAtual: _ordenacaoAtual,
        searchQuery: _searchQuery,
        pagination: response.pagination,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(LojasError('Erro ao carregar lojas: $e'));
    } finally {
      _isFetching = false;
    }
  }

  void filterByCategoria(String? categoria) {
    _categoriaAtual = categoria;
    fetchLojas(page: 1);
  }

  void sortLojasBy(String? ordenacao) {
    _ordenacaoAtual = ordenacao;
    fetchLojas(page: 1);
  }

  void searchLojas(String? query) {
    _searchQuery = query?.trim().isEmpty == true ? null : query?.trim();
    fetchLojas(page: 1);
  }

  void applyFilters({
    String? search,
    String? categoria,
    String? ordenacao,
  }) {
    _searchQuery = search?.trim().isEmpty == true ? null : search?.trim();
    _categoriaAtual = categoria;
    _ordenacaoAtual = ordenacao;
    fetchLojas(page: 1);
  }

  void clearAllFilters() {
    _categoriaAtual = null;
    _ordenacaoAtual = null;
    _searchQuery = null;
    fetchLojas(page: 1);
  }

  Future<void> refreshList() async {
    await fetchLojas(page: 1);
  }

  int get currentPage => _lastPagination?.page ?? 1;
  
  bool get hasMorePages {
    if (_lastPagination == null) return false;
    return _lastPagination!.page < _lastPagination!.totalPages;
  }
}
