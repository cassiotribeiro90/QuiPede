// lib/app/modules/lojas/bloc/lojas_state.dart

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
  final bool isSearching;

  const LojasLoaded({
    required this.lojas,
    required this.lojasFiltradas,
    required this.categorias,
    this.categoriaSelecionada,
    this.ordenacaoAtual,
    this.searchQuery,
    required this.pagination,
    this.isLoadingMore = false,
    this.isSearching = false,
  });

  // Sentinela para distinguir "não informado" de "null"
  static const _unset = Object();

  LojasLoaded copyWith({
    List<LojaResumo>? lojas,
    List<LojaResumo>? lojasFiltradas,
    List<LojasListFilterOptionModel>? categorias,
    Object? categoriaSelecionada = _unset,
    Object? ordenacaoAtual = _unset,
    Object? searchQuery = _unset,
    PaginationModel? pagination,
    bool? isLoadingMore,
    bool? isSearching,
  }) {
    return LojasLoaded(
      lojas: lojas ?? this.lojas,
      lojasFiltradas: lojasFiltradas ?? this.lojasFiltradas,
      categorias: categorias ?? this.categorias,
      categoriaSelecionada: identical(categoriaSelecionada, _unset)
          ? this.categoriaSelecionada
          : categoriaSelecionada as String?,
      ordenacaoAtual: identical(ordenacaoAtual, _unset)
          ? this.ordenacaoAtual
          : ordenacaoAtual as String?,
      searchQuery: identical(searchQuery, _unset)
          ? this.searchQuery
          : searchQuery as String?,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearching: isSearching ?? this.isSearching,
    );
  }

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
    isSearching,
  ];
}

class LojasError extends LojasState {
  final String message;

  const LojasError(this.message);

  @override
  List<Object?> get props => [message];
}