import 'package:equatable/equatable.dart';
import '../../../models/loja_detalhe_model.dart';
import '../../../models/produto_model.dart';

abstract class LojaDetalheState extends Equatable {
  const LojaDetalheState();

  @override
  List<Object?> get props => [];
}

class LojaDetalheInitial extends LojaDetalheState {}

class LojaDetalheLoading extends LojaDetalheState {}

class LojaDetalheLoaded extends LojaDetalheState {
  final LojaDetalheModel loja;
  final List<ProdutoModel> items;
  final bool hasMore;
  final bool isLoadingMore;
  final int? categoriaId;
  final String? search;
  final String? orderBy;

  const LojaDetalheLoaded({
    required this.loja,
    required this.items,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.categoriaId,
    this.search,
    this.orderBy,
  });

  LojaDetalheLoaded copyWith({
    LojaDetalheModel? loja,
    List<ProdutoModel>? items,
    bool? hasMore,
    bool? isLoadingMore,
    int? categoriaId,
    String? search,
    String? orderBy,
  }) {
    return LojaDetalheLoaded(
      loja: loja ?? this.loja,
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      categoriaId: categoriaId ?? this.categoriaId,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
    );
  }

  @override
  List<Object?> get props => [loja, items, hasMore, isLoadingMore, categoriaId, search, orderBy];
}

class LojaDetalheError extends LojaDetalheState {
  final String message;
  const LojaDetalheError(this.message);

  @override
  List<Object?> get props => [message];
}
