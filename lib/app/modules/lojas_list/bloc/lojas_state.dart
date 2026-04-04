import 'package:equatable/equatable.dart';
import '../../../models/loja_resumo_model.dart';
import '../../../models/lojas_list_filter_option_model.dart';
import '../../../models/pagination_model.dart';

abstract class LojasState extends Equatable {
  const LojasState();
  @override
  List<Object?> get props => [];
}

class LojasInitial extends LojasState {}
class LojasLoading extends LojasState {}

class LojasLoaded extends LojasState {
  final List<LojaResumo> lojas;
  final List<LojaResumo> lojasFiltradas;
  final List<LojasListFilterOptionModel> categorias;
  final String? categoriaSelecionada;
  final String? ordenacaoAtual;
  final String? searchQuery;
  final PaginationModel pagination;
  final bool isLoadingMore;

  const LojasLoaded({
    required this.lojas,
    required this.lojasFiltradas,
    required this.categorias,
    this.categoriaSelecionada,
    this.ordenacaoAtual,
    this.searchQuery,
    required this.pagination,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        lojas,
        lojasFiltradas,
        categorias,
        categoriaSelecionada,
        ordenacaoAtual,
        searchQuery,
        pagination,
        isLoadingMore,
      ];

  LojasLoaded copyWith({
    List<LojaResumo>? lojas,
    List<LojaResumo>? lojasFiltradas,
    List<LojasListFilterOptionModel>? categorias,
    String? categoriaSelecionada,
    String? ordenacaoAtual,
    String? searchQuery,
    PaginationModel? pagination,
    bool? isLoadingMore,
  }) {
    return LojasLoaded(
      lojas: lojas ?? this.lojas,
      lojasFiltradas: lojasFiltradas ?? this.lojasFiltradas,
      categorias: categorias ?? this.categorias,
      categoriaSelecionada: categoriaSelecionada ?? this.categoriaSelecionada,
      ordenacaoAtual: ordenacaoAtual ?? this.ordenacaoAtual,
      searchQuery: searchQuery ?? this.searchQuery,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class LojasError extends LojasState {
  final String message;
  const LojasError(this.message);
  @override
  List<Object?> get props => [message];
}
