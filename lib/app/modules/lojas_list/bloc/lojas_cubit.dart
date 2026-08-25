// lib/app/modules/lojas_list/bloc/lojas_cubit.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/loja_resumo_model.dart';
import 'lojas_state.dart';
import '../repository/loja_repository.dart';
import '../../../models/pagination_model.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';

class LojasCubit extends Cubit<LojasState> {
  final LojaRepository _repository;
  final LocalizacaoCubit _localizacaoCubit;
  String? _categoriaAtual;
  String? _ordenacaoAtual;
  String? _searchQuery;
  List<LojaResumo> _todasLojas = [];
  List<LojaResumo> _lojasFiltradas = [];
  PaginationModel? _lastPagination;

  bool _isFetching = false;

  LojasCubit(this._repository, this._localizacaoCubit) : super(LojasInitial());

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
      // Atualiza os filtros internos se fornecidos
      if (categoria != null) _categoriaAtual = categoria;
      if (ordenacao != null) _ordenacaoAtual = ordenacao;
      if (search != null) _searchQuery = search;

      debugPrint('📡 [LojasCubit] fetchLojas: search="$_searchQuery"');

      if (!isLoadMore) {
        emit(LojasLoading());
        _todasLojas = [];
      } else if (state is LojasLoaded) {
        emit((state as LojasLoaded).copyWith(isLoadingMore: true));
      }

      double? lat;
      double? lng;
      final localizacaoState = _localizacaoCubit.state;
      if (localizacaoState is LocalizacaoCarregada) {
        lat = localizacaoState.latitude;
        lng = localizacaoState.longitude;
      }

      final response = await _repository.getLojas(
        page: page,
        perPage: perPage,
        categoria: _categoriaAtual,
        ordenarPor: _ordenacaoAtual,
        busca: _searchQuery,
        latitude: lat,
        longitude: lng,
      );

      debugPrint('📡 [LojasCubit] Lojas carregadas: ${response.items.length} itens');

      _lastPagination = response.pagination;

      if (isLoadMore) {
        _todasLojas.addAll(response.items);
      } else {
        _todasLojas = List.from(response.items);
      }

      _lojasFiltradas = List.from(_todasLojas);

      emit(LojasLoaded(
        lojas: List.from(_todasLojas),
        lojasFiltradas: List.from(_lojasFiltradas),
        categorias: response.filterOptions.categorias,
        categoriaSelecionada: _categoriaAtual,
        ordenacaoAtual: _ordenacaoAtual,
        searchQuery: _searchQuery,
        pagination: response.pagination,
        isLoadingMore: false,
        isSearching: false,
      ));
    } catch (e) {
      debugPrint('❌ [LojasCubit] Erro ao buscar lojas: $e');
      if (isLoadMore && state is LojasLoaded) {
        emit((state as LojasLoaded).copyWith(isLoadingMore: false));
      } else {
        emit(LojasError('Erro ao carregar lojas: $e'));
      }
    } finally {
      _isFetching = false;
    }
  }

  void applyFilters({
    String? search,
    String? categoria,
    String? ordenacao,
  }) {
    _searchQuery = search?.trim().isEmpty == true ? null : search?.trim();
    _categoriaAtual = categoria;
    _ordenacaoAtual = ordenacao;

    debugPrint('🔍 [LojasCubit] applyFilters: _searchQuery = "$_searchQuery"');

    fetchLojas(
      page: 1,
      search: _searchQuery,
      categoria: _categoriaAtual,
      ordenacao: _ordenacaoAtual,
    );
  }

  void clearAllFilters() {
    debugPrint('🧹 [LojasCubit] clearAllFilters: limpando filtros');

    _categoriaAtual = null;
    _ordenacaoAtual = null;
    _searchQuery = null;

    fetchLojas(page: 1);
  }

  // 🔥 Novo metodo: limpa somente a busca textual
  void clearSearchOnly() {
    debugPrint('🧹 [LojasCubit] clearSearchOnly: limpando somente a busca');

    _searchQuery = null;

    // Recarrega mantendo categoria e ordenação atuais
    fetchLojas(page: 1);
  }

  // Métodos auxiliares (mantidos)
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

  Future<void> refreshList() async {
    await fetchLojas(page: 1);
  }

  int get currentPage => _lastPagination?.page ?? 1;

  bool get hasMorePages {
    if (_lastPagination == null) return false;
    return _lastPagination!.page < _lastPagination!.totalPages;
  }
}