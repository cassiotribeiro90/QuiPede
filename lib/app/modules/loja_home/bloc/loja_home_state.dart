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
  final List<int> selectedCategories;
  final int currentPage;
  final int totalPages;
  final int activeFilterCount;
  final int? loadingSectionId; // 🆕 Controla qual seção está sendo carregada

  const LojaHomeLoaded({
    required LojaDetalheModel loja,
    required super.secoes,
    required this.pagination,
    required this.filterOptions,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isFiltering = false,
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

  LojaHomeLoaded copyWith({
    LojaDetalheModel? loja,
    List<SecaoModel>? secoes,
    PaginationModel? pagination,
    LojaFilterOptions? filterOptions,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isFiltering,
    int? selectedCategoriaId,
    String? searchQuery,
    String? orderBy,
    List<int>? selectedCategories,
    int? currentPage,
    int? totalPages,
    int? activeFilterCount,
    bool? isAddingToCart,
    int? addingProductId,
    int? loadingSectionId,
    bool resetLoadingSectionId = false, // 🆕 Flag para limpar explicitamente
    bool resetAddingProductId = false,   // 🆕 Flag para limpar explicitamente
  }) {
    return LojaHomeLoaded(
      loja: loja ?? this.loja,
      secoes: secoes ?? this.secoes,
      pagination: pagination ?? this.pagination,
      filterOptions: filterOptions ?? this.filterOptions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFiltering: isFiltering ?? this.isFiltering,
      selectedCategoriaId: selectedCategoriaId ?? this.selectedCategoriaId,
      searchQuery: searchQuery ?? this.searchQuery,
      orderBy: orderBy ?? this.orderBy,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      activeFilterCount: activeFilterCount ?? this.activeFilterCount,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      addingProductId: resetAddingProductId ? null : (addingProductId ?? this.addingProductId),
      loadingSectionId: resetLoadingSectionId ? null : (loadingSectionId ?? this.loadingSectionId),
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
    selectedCategoriaId,
    searchQuery,
    orderBy,
    selectedCategories,
    currentPage,
    totalPages,
    activeFilterCount,
    isAddingToCart,
    addingProductId,
    loadingSectionId, // 🆕
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