import 'package:equatable/equatable.dart';
import '../../../models/loja_detalhe_model.dart';
import '../../../models/produto_model.dart';

abstract class LojaHomeState extends Equatable {
  const LojaHomeState();
  @override
  List<Object?> get props => [];
}

class LojaHomeInitial extends LojaHomeState {}

class LojaHomeLoading extends LojaHomeState {}

class LojaHomeLoaded extends LojaHomeState {
  final LojaDetalheModel loja;
  final List<ProdutoModel> produtos;
  final Map<int, List<ProdutoModel>> produtosPorCategoria;
  final List<int> selectedCategories;
  final String? orderBy;
  final int activeFilterCount;
  final bool hasMore;
  final int currentPage;
  final int totalPages;
  final String? searchQuery;
  final bool isLoadingMore;

  const LojaHomeLoaded({
    required this.loja,
    required this.produtos,
    required this.produtosPorCategoria,
    required this.selectedCategories,
    this.orderBy,
    required this.activeFilterCount,
    required this.hasMore,
    required this.currentPage,
    required this.totalPages,
    this.searchQuery,
    this.isLoadingMore = false,
  });

  LojaHomeLoaded copyWith({
    LojaDetalheModel? loja,
    List<ProdutoModel>? produtos,
    Map<int, List<ProdutoModel>>? produtosPorCategoria,
    List<int>? selectedCategories,
    String? orderBy,
    int? activeFilterCount,
    bool? hasMore,
    int? currentPage,
    int? totalPages,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return LojaHomeLoaded(
      loja: loja ?? this.loja,
      produtos: produtos ?? this.produtos,
      produtosPorCategoria: produtosPorCategoria ?? this.produtosPorCategoria,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      orderBy: orderBy ?? this.orderBy,
      activeFilterCount: activeFilterCount ?? this.activeFilterCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        loja,
        produtos,
        produtosPorCategoria,
        selectedCategories,
        orderBy,
        activeFilterCount,
        hasMore,
        currentPage,
        totalPages,
        searchQuery,
        isLoadingMore,
      ];
}

class LojaHomeError extends LojaHomeState {
  final String message;
  const LojaHomeError(this.message);
  @override
  List<Object> get props => [message];
}

class LojaHomeLoadingMore extends LojaHomeState {}
