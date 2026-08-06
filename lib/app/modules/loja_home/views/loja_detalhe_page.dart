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
import '../../../services/navigation_service.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';

class LojaDetalhePage extends StatefulWidget {
  final int lojaId;

  const LojaDetalhePage({super.key, required this.lojaId});

  @override
  State<LojaDetalhePage> createState() => _LojaDetalhePageState();
}

class _LojaDetalhePageState extends State<LojaDetalhePage> {
  late final LojaHomeCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _carrinhoJaCarregado = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LojaHomeCubit>(param1: widget.lojaId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cubit.loadLoja();
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
    final authState = context.read<AuthCubit>().state;

    // 🔥 Convidado E autenticado podem adicionar ao carrinho normalmente
    if (authState is AuthAuthenticated || authState is AuthGuest) {
      _abrirBottomSheetProduto(produto, widget.lojaId);
      return;
    }

    // 🔥 SÓ redireciona para onboarding se for AuthUnauthenticated (sem token nenhum)
    if (authState is AuthUnauthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre um endereço para começar a pedir'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
      getIt<NavigationService>().goToOnboarding();
    }
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
      } catch (_) {}
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
      child: MultiBlocListener(
        listeners: [
          BlocListener<LojaHomeCubit, LojaHomeState>(
            listener: (context, state) {
              if (state is LojaHomeError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
          // 🔥 Carrega carrinho quando virar convidado ou autenticado
          BlocListener<AuthCubit, AuthState>(
            listener: (context, authState) {
              if (!mounted) return;
              if ((authState is AuthGuest || authState is AuthAuthenticated) &&
                  !_carrinhoJaCarregado) {
                _carrinhoJaCarregado = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    context.read<CarrinhoCubit>().carregarCarrinho();
                  }
                });
              } else if (authState is AuthUnauthenticated) {
                _carrinhoJaCarregado = false;
              }
            },
          ),
        ],
        child: BlocBuilder<LojaHomeCubit, LojaHomeState>(
          buildWhen: (previous, current) {
            if (previous is LojaHomeLoaded && current is LojaHomeLoaded) {
              if (previous.isLoadingMore != current.isLoadingMore) return false;
              if (previous.isFiltering != current.isFiltering) return false;
            }
            return true;
          },
          builder: (context, state) {
            return ResponsivePageScaffold(
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
          },
        ),
      ),
    );
  }

  Widget? _buildBottomBar(LojaHomeState state) {
    return BlocBuilder<CarrinhoCubit, CarrinhoState>(
      builder: (context, carrinhoState) {
        final isLoading = carrinhoState is CarrinhoLoaded &&
            (carrinhoState.isRequesting || carrinhoState.isDebouncing);
        final totalItens = carrinhoState is CarrinhoLoaded ? carrinhoState.totalItens : 0;
        final lojaNome = carrinhoState is CarrinhoLoaded ? carrinhoState.lojaNome : null;

        if (totalItens > 0 && lojaNome != null) {
          return CarrinhoBottomBar(
            lojaNome: lojaNome,
            isLoading: isLoading,
            onTap: () => getIt<NavigationService>().goToCarrinho(),
          );
        }
        return const SizedBox(height: 0, width: 0);
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
          if (_carrinhoJaCarregado)
            context.read<CarrinhoCubit>().carregarCarrinho(forceRefresh: true),
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