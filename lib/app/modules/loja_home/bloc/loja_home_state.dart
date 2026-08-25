// lib/app/modules/loja_home/bloc/loja_home_state.dart

import 'package:equatable/equatable.dart';
import '../../../models/loja_detalhe_model.dart';
import '../../../models/secao_model.dart';
import '../../../models/pagination_model.dart';
import '../../../models/filter_options_model.dart';

abstract class LojaHomeState extends Equatable {
  final List<SecaoModel> secoes;
  final LojaDetalheModel? loja;
  final bool isAddingToCart;
  final int? addingProductId;
  final String? searchQuery;
  final String? orderBy;
  final int? selectedCategoriaId;

  const LojaHomeState({
    this.secoes = const [],
    this.loja,
    this.isAddingToCart = false,
    this.addingProductId,
    this.searchQuery,
    this.orderBy,
    this.selectedCategoriaId,
  });

  @override
  List<Object?> get props => [
    secoes,
    loja,
    isAddingToCart,
    addingProductId,
    searchQuery,
    orderBy,
    selectedCategoriaId,
  ];
}

class LojaHomeInitial extends LojaHomeState {
  const LojaHomeInitial() : super();
}

class LojaHomeLoading extends LojaHomeState {
  const LojaHomeLoading({
    super.secoes,
    super.loja,
    super.isAddingToCart,
    super.addingProductId,
    super.searchQuery,
    super.orderBy,
    super.selectedCategoriaId,
  });
}

class LojaHomeLoaded extends LojaHomeState {
  final PaginationModel pagination;
  final LojaFilterOptions filterOptions;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isFiltering;
  final bool isSearching;
  final List<int> selectedCategories;
  final int currentPage;
  final int totalPages;
  final int activeFilterCount;
  final int? loadingSectionId;

  const LojaHomeLoaded({
    required LojaDetalheModel loja,
    required super.secoes,
    required this.pagination,
    required this.filterOptions,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isFiltering = false,
    this.isSearching = false,
    super.searchQuery,
    super.orderBy,
    super.selectedCategoriaId,
    this.selectedCategories = const [],
    required this.currentPage,
    required this.totalPages,
    required this.activeFilterCount,
    super.isAddingToCart,
    super.addingProductId,
    this.loadingSectionId,
  }) : super(loja: loja);

  @override
  LojaDetalheModel get loja => super.loja!;

  // Sentinela para distinguir "não informado" de "null" nos campos escalares
  static const _unset = Object();

  LojaHomeLoaded copyWith({
    LojaDetalheModel? loja,
    List<SecaoModel>? secoes,
    PaginationModel? pagination,
    LojaFilterOptions? filterOptions,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isFiltering,
    bool? isSearching,
    Object? selectedCategoriaId = _unset,
    Object? searchQuery = _unset,
    Object? orderBy = _unset,
    List<int>? selectedCategories,  // 🔥 Volta a ser List<int>? sem sentinela
    Object? addingProductId = _unset,
    Object? loadingSectionId = _unset,
    int? currentPage,
    int? totalPages,
    int? activeFilterCount,
    bool? isAddingToCart,
  }) {
    return LojaHomeLoaded(
      loja: loja ?? this.loja,
      secoes: secoes ?? this.secoes,
      pagination: pagination ?? this.pagination,
      filterOptions: filterOptions ?? this.filterOptions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFiltering: isFiltering ?? this.isFiltering,
      isSearching: isSearching ?? this.isSearching,
      selectedCategoriaId: identical(selectedCategoriaId, _unset)
          ? this.selectedCategoriaId
          : selectedCategoriaId as int?,
      searchQuery: identical(searchQuery, _unset)
          ? this.searchQuery
          : searchQuery as String?,
      orderBy: identical(orderBy, _unset)
          ? this.orderBy
          : orderBy as String?,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      addingProductId: identical(addingProductId, _unset)
          ? this.addingProductId
          : addingProductId as int?,
      loadingSectionId: identical(loadingSectionId, _unset)
          ? this.loadingSectionId
          : loadingSectionId as int?,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      activeFilterCount: activeFilterCount ?? this.activeFilterCount,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
    );
  }

  @override
  List<Object?> get props => [
    super.loja,
    secoes,
    pagination,
    filterOptions,
    hasMore,
    isLoadingMore,
    isFiltering,
    isSearching,
    selectedCategoriaId,
    searchQuery,
    orderBy,
    selectedCategories,
    currentPage,
    totalPages,
    activeFilterCount,
    isAddingToCart,
    addingProductId,
    loadingSectionId,
  ];
}

class LojaHomeError extends LojaHomeState {
  final String message;
  const LojaHomeError(
      this.message, {
        super.secoes,
        super.loja,
        super.isAddingToCart,
        super.addingProductId,
        super.searchQuery,
        super.orderBy,
        super.selectedCategoriaId,
      });

  @override
  List<Object?> get props => [
    message,
    secoes,
    loja,
    isAddingToCart,
    addingProductId,
    searchQuery,
    orderBy,
    selectedCategoriaId,
  ];
}

class LojaHomeLoadingMore extends LojaHomeState {
  const LojaHomeLoadingMore({
    super.secoes,
    super.loja,
    super.isAddingToCart,
    super.addingProductId,
    super.searchQuery,
    super.orderBy,
    super.selectedCategoriaId,
  });
}