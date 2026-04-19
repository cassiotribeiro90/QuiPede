// lib/modules/loja_home/views/loja_detalhe_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../di/dependencies.dart';
import '../bloc/loja_home_cubit.dart';
import '../bloc/loja_home_state.dart';
import '../widgets/loja_header_widget.dart';
import '../widgets/search_with_filters.dart';
import '../widgets/secoes_list_widget.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';
import '../../carrinho/widgets/carrinho_bottom_bar.dart';
import '../../produtos/widgets/produto_simples_bottom_sheet.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../routes/app_routes.dart';
import '../../../models/carrinho_item.dart';

class LojaDetalhePage extends StatefulWidget {
  final int lojaId;

  const LojaDetalhePage({super.key, required this.lojaId});

  @override
  State<LojaDetalhePage> createState() => _LojaDetalhePageState();
}

class _LojaDetalhePageState extends State<LojaDetalhePage> {
  late final LojaHomeCubit _cubit;
  final ScrollController _scrollController = ScrollController();

  dynamic _produtoPendente;
  int? _lojaIdPendente;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LojaHomeCubit>(param1: widget.lojaId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cubit.loadLoja();
        getIt<CarrinhoCubit>().carregarCarrinho(forceRefresh: true);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _cubit.state;
      if (state is LojaHomeLoaded && state.hasMore && !state.isLoadingMore) {
        _isLoadingMore = true;
        _cubit.loadMore();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _isLoadingMore = false;
        });
      }
    }
  }

  void _abrirProduto(BuildContext context, dynamic produto) {
    final authCubit = getIt<AuthCubit>();
    final authState = authCubit.state;

    if (authState is! AuthAuthenticated) {
      _produtoPendente = produto;
      _lojaIdPendente = widget.lojaId;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Faça login para ver os detalhes do produto'),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushNamed(context, Routes.login).then((_) {
        if (mounted && _produtoPendente != null) {
          final authCubit = getIt<AuthCubit>();
          if (authCubit.state is AuthAuthenticated) {
            _abrirBottomSheetProduto(_produtoPendente!, _lojaIdPendente!);
            _produtoPendente = null;
            _lojaIdPendente = null;
          }
        }
      });
      return;
    }

    _abrirBottomSheetProduto(produto, widget.lojaId);
  }

  void _abrirBottomSheetProduto(dynamic produto, int lojaId) {
    if (produto == null) return;
    
    final carrinhoCubit = context.read<CarrinhoCubit>();
    final carrinhoState = carrinhoCubit.state;
    
    int? itemId;
    int? initialQuantidade;
    String? initialObservacao;

    if (carrinhoState is CarrinhoLoaded) {
      try {
        final itemExistente = carrinhoState.itens.firstWhere(
          (item) => item.produtoId == produto.id,
        );
        itemId = itemExistente.id;
        initialQuantidade = itemExistente.quantidade;
        initialObservacao = itemExistente.observacao;
      } catch (_) {
        // Produto não está no carrinho
      }
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: carrinhoCubit,
        child: ProdutoSimplesBottomSheet(
          produto: produto,
          lojaId: lojaId,
          itemId: itemId,
          initialQuantidade: initialQuantidade,
          initialObservacao: initialObservacao,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: getIt<CarrinhoCubit>()),
      ],
      child: BlocConsumer<LojaHomeCubit, LojaHomeState>(
        listener: (context, state) {
          if (state is LojaHomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWeb = constraints.maxWidth > 600;

              Widget content = Scaffold(
                backgroundColor: context.backgroundColor,
                appBar: AppBar(
                  leading: BackButton(color: context.textPrimary),
                  title: Text(
                    state.loja?.nome ?? 'Carregando...',
                    style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: context.surfaceColor,
                  elevation: 0,
                ),
                bottomNavigationBar: _buildBottomBar(state),
                body: Stack(
                  children: [
                    _buildBody(context, state),
                    if (state is LojaHomeLoaded && state.isFiltering)
                      Container(
                        color: Colors.white.withOpacity(0.7),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              );

              if (isWeb) {
                return Center(
                  child: SizedBox(
                    width: 820,
                    child: content,
                  ),
                );
              }
              return content;
            },
          );
        },
      ),
    );
  }

  Widget? _buildBottomBar(LojaHomeState state) {
    return BlocBuilder<CarrinhoCubit, CarrinhoState>(
      builder: (context, carrinhoState) {
        final isLoading = carrinhoState is CarrinhoLoaded && (carrinhoState.isRequesting || carrinhoState.isDebouncing);
        final totalItens = carrinhoState is CarrinhoLoaded ? carrinhoState.totalItens : 0;
        final lojaNome = carrinhoState is CarrinhoLoaded ? carrinhoState.lojaNome : null;
        
        if (totalItens > 0 && lojaNome != null) {
          return CarrinhoBottomBar(
            lojaNome: lojaNome,
            isLoading: isLoading,
            onTap: () => Navigator.pushNamed(context, Routes.carrinho),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody(BuildContext context, LojaHomeState state) {
    if (state is LojaHomeLoading && state.secoes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LojaHomeError && state.secoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _cubit.loadLoja(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final loja = state.loja;
    final isLoadingMore = state is LojaHomeLoaded && state.isLoadingMore;

    return RefreshIndicator(
      onRefresh: () async {
        _isLoadingMore = false;
        await Future.wait([
          _cubit.refresh(),
          getIt<CarrinhoCubit>().carregarCarrinho(),
        ]);
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (loja != null) LojaHeaderWidget(loja: loja),

          if (loja != null)
            SliverToBoxAdapter(
              child: SearchWithFilters(
                categorias: loja.filterOptions.categorias,
                selectedCategoriaId: state is LojaHomeLoaded && state.selectedCategories.isNotEmpty
                    ? state.selectedCategories.first
                    : null,
                selectedOrderBy: state is LojaHomeLoaded ? state.orderBy : null,
                searchQuery: state is LojaHomeLoaded ? state.searchQuery : null,
                onApply: (search, catId, orderBy) => _cubit.applyFilters(
                  search: search,
                  categoriaId: catId,
                  orderBy: orderBy,
                ),
                onClearFilters: () => _cubit.clearFilters(),
              ),
            ),

          BlocSelector<CarrinhoCubit, CarrinhoState, Map<String, Map<int, int>>>(
            selector: (carrinhoState) {
              final quantidades = <int, int>{};
              final itemIds = <int, int>{};
              if (carrinhoState is CarrinhoLoaded) {
                for (var item in carrinhoState.itens) {
                  quantidades[item.produtoId] = item.quantidade;
                  itemIds[item.produtoId] = item.id;
                }
              }
              return {
                'quantidades': quantidades,
                'itemIds': itemIds,
              };
            },
            builder: (context, dados) {
              return SecoesListWidget(
                secoes: state.secoes,
                lojaId: widget.lojaId,
                onProdutoTap: (produto) => _abrirProduto(context, produto),
                quantidadesPorProduto: dados['quantidades']!,
                itemIdsPorProduto: dados['itemIds']!,
              );
            },
          ),

          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          if (state is LojaHomeLoaded && !state.hasMore && state.secoes.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Isso é tudo por enquanto! 🍕',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
