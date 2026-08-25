// lib/app/modules/loja_home/bloc/loja_home_cubit.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/loja_repository.dart';
import 'loja_home_state.dart';
import '../../../models/secao_model.dart';
import '../../../models/produto_model.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';

class LojaHomeCubit extends Cubit<LojaHomeState> {
  final LojaHomeRepository _repository;
  final int lojaId;

  int _currentPage = 1;
  bool _hasMore = true;
  String? _searchQuery;
  int? _categoriaId;
  String? _orderBy;

  bool _isLoading = false;
  bool _isSearching = false;

  List<SecaoModel>? _originalSections;

  LojaHomeCubit(this._repository, this.lojaId) : super(const LojaHomeInitial());

  Future<void> loadLoja() async {
    if (_isLoading) return;

    _isLoading = true;
    _currentPage = 1;

    emit(const LojaHomeLoading());

    try {
      final response = await _repository.getLojaDetalhe(
        id: lojaId,
        page: 1,
        perPage: 20,
        categoriaId: _categoriaId,
        search: _searchQuery,
        orderBy: _orderBy,
      );

      _hasMore = response.pagination.page < response.pagination.totalPages;
      final secoesLimpa = _removerDuplicatas(response.secoes);

      if (_categoriaId == null && (_searchQuery == null || _searchQuery!.isEmpty)) {
        _originalSections = secoesLimpa;
      }

      emit(LojaHomeLoaded(
        loja: response,
        secoes: secoesLimpa,
        selectedCategories: _categoriaId != null ? [_categoriaId!] : [],
        orderBy: _orderBy,
        searchQuery: _searchQuery,
        hasMore: _hasMore,
        currentPage: 1,
        totalPages: response.pagination.totalPages,
        pagination: response.pagination,
        filterOptions: response.filterOptions,
        activeFilterCount: _calcularFiltrosAtivos(),
        isSearching: false,
      ));
    } catch (e) {
      emit(LojaHomeError('Erro ao carregar loja: $e'));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> searchLojas({String? search, int? categoriaId, String? orderBy}) async {
    if (_isSearching) return;
    _isSearching = true;

    final currentState = state;
    if (currentState is! LojaHomeLoaded) {
      _isSearching = false;
      await applyFilters(search: search, categoriaId: categoriaId, orderBy: orderBy);
      return;
    }

    emit(currentState.copyWith(isSearching: true));

    _searchQuery = search?.trim().isEmpty == true ? null : search?.trim();
    _categoriaId = categoriaId;
    _orderBy = orderBy;

    debugPrint('🔍 [LojaHomeCubit] searchLojas: _searchQuery = "$_searchQuery"');

    try {
      final response = await _repository.getLojaDetalhe(
        id: lojaId,
        page: 1,
        perPage: 20,
        categoriaId: _categoriaId,
        search: _searchQuery,
        orderBy: _orderBy,
      );

      _hasMore = response.pagination.page < response.pagination.totalPages;
      final secoesLimpa = _removerDuplicatas(response.secoes);

      if (_categoriaId == null && (_searchQuery == null || _searchQuery!.isEmpty)) {
        _originalSections = secoesLimpa;
      }

      emit(currentState.copyWith(
        loja: response,
        secoes: secoesLimpa,
        selectedCategories: _categoriaId != null ? [_categoriaId!] : [],
        orderBy: _orderBy,
        searchQuery: _searchQuery,
        hasMore: _hasMore,
        currentPage: 1,
        totalPages: response.pagination.totalPages,
        pagination: response.pagination,
        filterOptions: response.filterOptions,
        activeFilterCount: _calcularFiltrosAtivos(),
        isLoadingMore: false,
        isFiltering: false,
        isSearching: false,
      ));
    } catch (e) {
      debugPrint('❌ [LojaHomeCubit] Erro na pesquisa suave: $e');
      if (state is LojaHomeLoaded) {
        emit((state as LojaHomeLoaded).copyWith(isSearching: false));
      }
    } finally {
      _isSearching = false;
    }
  }

  void clearFiltersOnly() {
    final currentState = state;
    if (currentState is! LojaHomeLoaded) return;

    debugPrint('🧹 [LojaHomeCubit] clearFiltersOnly: limpando filtros');

    // Limpa as variáveis internas imediatamente
    _searchQuery = null;
    _categoriaId = null;
    _orderBy = null;

    if (_originalSections != null) {
      // Se temos as seções originais, restaura sem precisar de nova chamada
      emit(currentState.copyWith(
        secoes: _originalSections!,
        searchQuery: null,
        selectedCategoriaId: null,
        orderBy: null,
        selectedCategories: [],
        activeFilterCount: 0,
        isFiltering: false,
        isLoadingMore: false,
        isSearching: false,
      ));
    } else {
      // Caso não tenha as originais, faz uma nova busca sem filtros
      searchLojas(search: null, categoriaId: null, orderBy: null);
    }
  }

  // 🔥 Novo metodo: limpa somente a busca textual
  void clearSearchOnly() {
    debugPrint('🧹 [LojaHomeCubit] clearSearchOnly: limpando somente a busca');

    _searchQuery = null;

    // Recarrega mantendo categoria e ordenação atuais
    loadLoja();
  }

  void searchProducts(String? search) {
    final searchValue = search?.trim().isEmpty == true ? null : search?.trim();
    searchLojas(search: searchValue);
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (_isLoading) return;
    if (currentState is! LojaHomeLoaded) return;
    if (!_hasMore) return;

    _isLoading = true;
    _currentPage++;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final response = await _repository.getLojaDetalhe(
        id: lojaId,
        page: _currentPage,
        perPage: 20,
        categoriaId: _categoriaId,
        search: _searchQuery,
        orderBy: _orderBy,
      );

      _hasMore = response.pagination.page < response.pagination.totalPages;
      final novasSecoes = _mesclarSecoes(currentState.secoes, response.secoes);

      emit(currentState.copyWith(
        secoes: novasSecoes,
        currentPage: _currentPage,
        hasMore: _hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      _currentPage--;
      emit(currentState.copyWith(isLoadingMore: false));
      emit(LojaHomeError('Erro ao carregar mais itens: $e'));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> adicionarAoCarrinho({
    required CarrinhoCubit carrinhoCubit,
    required int produtoId,
    int quantidade = 1,
    List<int> opcoes = const [],
    String? observacao,
  }) async {
    final currentState = state;
    if (state.isAddingToCart) return;

    if (currentState is LojaHomeLoaded) {
      emit(currentState.copyWith(
        isAddingToCart: true,
        addingProductId: produtoId,
      ));
    }

    try {
      await carrinhoCubit.adicionarItem(
        produtoId: produtoId,
        quantidade: quantidade,
        opcoes: opcoes,
        observacao: observacao,
        applyDebounce: false,
      );
    } catch (e) {
      emit(LojaHomeError('Erro ao adicionar ao carrinho: $e', secoes: state.secoes, loja: state.loja));
    } finally {
      final finalState = state;
      if (finalState is LojaHomeLoaded) {
        emit(finalState.copyWith(
          isAddingToCart: false,
          addingProductId: null,
        ));
      }
    }
  }

  Future<void> applyFilters({String? search, int? categoriaId, String? orderBy}) async {
    _searchQuery = search?.trim().isEmpty == true ? null : search?.trim();
    _categoriaId = categoriaId;
    _orderBy = orderBy;
    await loadLoja();
  }

  Future<void> clearFilters() async {
    clearFiltersOnly();
  }

  Future<void> refresh() async {
    _originalSections = null;
    await loadLoja();
  }

  Future<void> loadSectionCompletelyById(int sectionId) async {
    final currentState = state;
    if (currentState is! LojaHomeLoaded) return;

    debugPrint('⏳ [Cubit] Ativando overlay para seção $sectionId');
    emit(currentState.copyWith(loadingSectionId: sectionId));

    try {
      int iterations = 0;
      const int maxIterations = 15;

      while (iterations < maxIterations) {
        final current = state;
        if (current is! LojaHomeLoaded) break;

        final sectionIndex = current.secoes.indexWhere((s) => s.id == sectionId);

        if (sectionIndex == -1) {
          if (!_hasMore) break;
          debugPrint('📥 [Cubit] Buscando seção $sectionId...');
          await loadMore();
        } else {
          final secao = current.secoes[sectionIndex];
          if (!secao.hasMore) break;
          debugPrint('📥 [Cubit] Completando seção $sectionId...');
          await loadMore();
        }

        iterations++;
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } finally {
      final finalState = state;
      if (finalState is LojaHomeLoaded) {
        emit(finalState.copyWith(loadingSectionId: null));
      }
      debugPrint('🏁 [Cubit] Overlay desativado para $sectionId');
    }
  }

  List<SecaoModel> _removerDuplicatas(List<SecaoModel> secoes) {
    final Set<int> idsVistos = {};

    return secoes.map((secao) {
      final produtosUnicos = <ProdutoModel>[];

      for (var produto in secao.produtos) {
        if (idsVistos.add(produto.id)) {
          produtosUnicos.add(produto);
        }
      }

      return SecaoModel(
        id: secao.id,
        nome: secao.nome,
        icone: secao.icone,
        ordem: secao.ordem,
        totalProdutos: secao.totalProdutos,
        produtos: produtosUnicos,
      );
    }).toList();
  }

  List<SecaoModel> _mesclarSecoes(List<SecaoModel> atuais, List<SecaoModel> novas) {
    final Set<int> idsExistentes = {};
    for (var secao in atuais) {
      for (var produto in secao.produtos) {
        idsExistentes.add(produto.id);
      }
    }

    final Map<int, SecaoModel> mapaSecoes = {for (var s in atuais) s.id: s};

    for (var novaSecao in novas) {
      final produtosNovos = <ProdutoModel>[];
      for (var produto in novaSecao.produtos) {
        if (idsExistentes.add(produto.id)) {
          produtosNovos.add(produto);
        }
      }

      if (produtosNovos.isEmpty && !mapaSecoes.containsKey(novaSecao.id)) continue;

      if (mapaSecoes.containsKey(novaSecao.id)) {
        final existente = mapaSecoes[novaSecao.id]!;
        mapaSecoes[novaSecao.id] = SecaoModel(
          id: existente.id,
          nome: existente.nome,
          icone: existente.icone,
          ordem: existente.ordem,
          totalProdutos: novaSecao.totalProdutos,
          produtos: [...existente.produtos, ...produtosNovos],
        );
      } else {
        mapaSecoes[novaSecao.id] = SecaoModel(
          id: novaSecao.id,
          nome: novaSecao.nome,
          icone: novaSecao.icone,
          ordem: novaSecao.ordem,
          totalProdutos: novaSecao.totalProdutos,
          produtos: produtosNovos,
        );
      }
    }

    return mapaSecoes.values.toList()..sort((a, b) => a.ordem.compareTo(b.ordem));
  }

  int _calcularFiltrosAtivos() {
    int count = 0;
    if (_categoriaId != null) count++;
    if (_orderBy != null) count++;
    if (_searchQuery != null && _searchQuery!.isNotEmpty) count++;
    return count;
  }
}