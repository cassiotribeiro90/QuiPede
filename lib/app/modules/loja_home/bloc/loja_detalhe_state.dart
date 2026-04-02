import 'package:equatable/equatable.dart';
import '../models/loja_detalhe_model.dart';
import '../models/secao_produto_model.dart';

abstract class LojaDetalheState extends Equatable {
  const LojaDetalheState();
  @override
  List<Object?> get props => [];
}

class LojaDetalheInitial extends LojaDetalheState {}

class LojaDetalheLoading extends LojaDetalheState {}

class LojaDetalheLoaded extends LojaDetalheState {
  final LojaDetalheModel loja;
  final List<SecaoProdutoModel> secoes;
  final String? searchQuery;
  final int? selectedCategoriaId;
  final String? orderBy;

  const LojaDetalheLoaded({
    required this.loja,
    required this.secoes,
    this.searchQuery,
    this.selectedCategoriaId,
    this.orderBy,
  });

  @override
  List<Object?> get props => [loja, secoes, searchQuery, selectedCategoriaId, orderBy];

  LojaDetalheLoaded copyWith({
    LojaDetalheModel? loja,
    List<SecaoProdutoModel>? secoes,
    String? searchQuery,
    int? selectedCategoriaId,
    String? orderBy,
  }) {
    return LojaDetalheLoaded(
      loja: loja ?? this.loja,
      secoes: secoes ?? this.secoes,
      searchQuery: searchQuery, // Allow null to clear
      selectedCategoriaId: selectedCategoriaId,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}

class LojaDetalheSearchLoading extends LojaDetalheLoaded {
  const LojaDetalheSearchLoading({
    required super.loja,
    required super.secoes,
    super.searchQuery,
    super.selectedCategoriaId,
    super.orderBy,
  });
}

class LojaDetalheError extends LojaDetalheState {
  final String message;
  const LojaDetalheError(this.message);
  @override
  List<Object?> get props => [message];
}
