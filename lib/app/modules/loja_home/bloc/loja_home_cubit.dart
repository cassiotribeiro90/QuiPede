import 'package:flutter_bloc/flutter_bloc.dart';
import 'loja_home_state.dart';
import '../../../models/produto_model.dart';
import '../../lojas/models/loja.dart';
import '../repositories/loja_repository.dart';

class LojaHomeCubit extends Cubit<LojaHomeState> {
  final LojaHomeRepository _repository;
  final int lojaId;
  
  String? _searchQuery;
  List<String> _selectedCategories = [];
  String? _orderBy;

  LojaHomeCubit(this._repository, this.lojaId) : super(LojaHomeInitial());

  Future<void> fetchLojaDetails() async {
    emit(LojaHomeLoading());
    try {
      // Usando o endpoint unificado /api/app/loja-home?id={id}
      final lojaDetalhe = await _repository.getLojaDetalhe(
        lojaId,
        orderBy: _orderBy,
        categoriaId: _selectedCategories.isNotEmpty ? int.tryParse(_selectedCategories.first) : null,
      );

      // Mapear LojaDetalheModel para Loja (modelo esperado pelo estado atual)
      final loja = Loja(
        id: lojaDetalhe.id,
        nome: lojaDetalhe.nome,
        logo: lojaDetalhe.logo,
        capa: lojaDetalhe.capa,
        categoria: lojaDetalhe.categoria,
        cidade: '', // Campos não presentes no detalhe mas exigidos pelo construtor de Loja
        uf: '',
        notaMedia: lojaDetalhe.notaMedia,
        tempoEntregaMin: lojaDetalhe.tempoEntregaMin,
        tempoEntregaMax: lojaDetalhe.tempoEntregaMax,
        taxaEntrega: lojaDetalhe.taxaEntrega,
        pedidoMinimo: lojaDetalhe.pedidoMinimo,
        verificado: lojaDetalhe.verificado,
        destaque: lojaDetalhe.destaque,
      );

      final List<Produto> allProdutos = [];
      final Map<String, List<Produto>> porCategoria = {};

      for (var secao in lojaDetalhe.secoes) {
        final produtosSecao = secao.produtos.map((p) => Produto(
          id: p.id,
          lojaId: lojaId,
          nome: p.nome,
          descricao: p.descricao ?? '',
          preco: p.preco,
          precoPromocional: p.precoPromocional,
          categoria: secao.nome,
          imagem: p.imagem ?? '',
          ingredientes: const [],
          disponivel: p.disponivel,
          destaque: p.destaque,
          avaliacao: p.notaMedia,
        )).toList();

        allProdutos.addAll(produtosSecao);
        porCategoria[secao.nome] = produtosSecao;
      }

      emit(LojaHomeLoaded(
        loja: loja,
        produtos: allProdutos,
        produtosPorCategoria: porCategoria,
        selectedCategories: _selectedCategories,
        activeFilterCount: _selectedCategories.length + (_orderBy != null ? 1 : 0),
        hasMore: false, // Endpoint /loja-home não tem paginação
        currentPage: 1,
      ));
    } catch (e) {
      emit(LojaHomeError('Erro ao carregar dados da loja: $e'));
    }
  }

  Future<void> loadMoreProdutos() async {
    // Sem paginação no endpoint unificado por enquanto
    return;
  }

  Future<void> searchQueryChanged(String query) async {
    _searchQuery = query.trim().isEmpty ? null : query;
    if (_searchQuery == null) {
      await fetchLojaDetails();
      return;
    }

    emit(LojaHomeLoading());
    try {
      final secoes = await _repository.searchProdutos(
        lojaId,
        _searchQuery!,
        orderBy: _orderBy,
      );

      final currentState = state;
      if (currentState is LojaHomeLoaded) {
        final List<Produto> allProdutos = [];
        final Map<String, List<Produto>> porCategoria = {};

        for (var secao in secoes) {
          final produtosSecao = secao.produtos.map((p) => Produto(
            id: p.id,
            lojaId: lojaId,
            nome: p.nome,
            descricao: p.descricao ?? '',
            preco: p.preco,
            precoPromocional: p.precoPromocional,
            categoria: secao.nome,
            imagem: p.imagem ?? '',
            ingredientes: const [],
            disponivel: p.disponivel,
            destaque: p.destaque,
            avaliacao: p.notaMedia,
          )).toList();

          allProdutos.addAll(produtosSecao);
          porCategoria[secao.nome] = produtosSecao;
        }

        emit(currentState.copyWith(
          produtos: allProdutos,
          produtosPorCategoria: porCategoria,
        ));
      }
    } catch (e) {
      emit(LojaHomeError('Erro na busca: $e'));
    }
  }

  Future<void> applyFilters(Set<String> categories) async {
    _selectedCategories = categories.toList();
    await fetchLojaDetails();
  }

  Future<void> setOrderBy(String? orderBy) async {
    _orderBy = orderBy;
    await fetchLojaDetails();
  }

  Future<void> refresh() async {
    _searchQuery = null;
    _selectedCategories = [];
    _orderBy = null;
    await fetchLojaDetails();
  }

  void toggleCategoryFilter(String categoria) {}
}
