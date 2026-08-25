// lib/app/modules/loja_home/views/loja_detalhe_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../di/dependencies.dart';
import '../../../models/secao_model.dart';
import '../bloc/loja_home_cubit.dart';
import '../bloc/loja_home_state.dart';
import '../widgets/loja_header_widget.dart';
import '../widgets/search_with_filters.dart';
import '../widgets/secoes_list_widget.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';
import '../../carrinho/widgets/carrinho_bottom_bar.dart';
import '../../produtos/widgets/produto_simples_bottom_sheet.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../navigation/navigation_cubit.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../../shared/widgets/loading_skeleton.dart';

class LojaDetalhePage extends StatefulWidget {
  final int lojaId;

  const LojaDetalhePage({super.key, required this.lojaId});

  @override
  State<LojaDetalhePage> createState() => _LojaDetalhePageState();
}

class _LojaDetalhePageState extends State<LojaDetalhePage>
    with TickerProviderStateMixin {
  late final LojaHomeCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  late TabController _categoryTabController;
  final Map<int, GlobalKey> _sectionKeys = {};
  bool _isLoadingMore = false;
  bool _carrinhoJaCarregado = false;
  bool _isAutoScrolling = false;
  bool _isScrollingToCategory = false;
  Timer? _scrollSyncTimer;
  Future<void> _actionQueue = Future.value();

  Future<void> _enqueueAction(Future<void> Function() action) {
    final completer = Completer<void>();
    _actionQueue = _actionQueue.then((_) async {
      try {
        await action();
        completer.complete();
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LojaHomeCubit>(param1: widget.lojaId);
    _categoryTabController = TabController(length: 0, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cubit.loadLoja();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollSyncTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _categoryTabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _cubit.state;
      if (state is LojaHomeLoaded &&
          state.hasMore &&
          !state.isLoadingMore &&
          !_isLoadingMore) {
        _isLoadingMore = true;
        _cubit.loadMore().whenComplete(() {
          _isLoadingMore = false;
          if (mounted) setState(() {});
        });
      }
    }

    if (!_isAutoScrolling && !_isScrollingToCategory) {
      _scrollSyncTimer?.cancel();
      _scrollSyncTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          _updateSelectedCategoryFromScroll();
        }
      });
    }
  }

  void _updateSelectedCategoryFromScroll() {
    final state = _cubit.state;
    if (state is! LojaHomeLoaded || state.secoes.isEmpty) return;

    const double topOffset = 110.0;
    int selectedIndex = -1;

    for (var i = 0; i < state.secoes.length; i++) {
      final secao = state.secoes[i];
      final key = _sectionKeys[secao.id];
      if (key == null) continue;
      final context = key.currentContext;
      if (context == null) continue;

      final box = context.findRenderObject() as RenderBox?;
      if (box == null) continue;

      final position = box.localToGlobal(Offset.zero).dy;

      if (position <= topOffset + 30) {
        selectedIndex = i;
      } else {
        break;
      }
    }

    if (selectedIndex != -1 &&
        selectedIndex != _categoryTabController.index &&
        mounted) {
      _categoryTabController.animateTo(selectedIndex);
    }
  }

  Future<void> _scrollToCategory(int index) async {
    if (_isScrollingToCategory) return;
    _isScrollingToCategory = true;

    try {
      final state = _cubit.state;
      if (state is! LojaHomeLoaded) return;

      final secao = state.secoes.elementAtOrNull(index);
      if (secao == null) return;

      if (secao.hasMore) {
        await _cubit.loadSectionCompletelyById(secao.id);
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final key = _sectionKeys[secao.id];
      if (key != null) {
        await _scrollToSection(key);
      }

      if (mounted) {
        _categoryTabController.animateTo(index);
      }
    } catch (e) {
      debugPrint('❌ [LojaDetalhePage] Erro ao rolar: $e');
    } finally {
      _isScrollingToCategory = false;
      _isAutoScrolling = false;
    }
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final targetContext = key.currentContext;
    if (targetContext != null) {
      _isAutoScrolling = true;
      await Scrollable.ensureVisible(
        targetContext,
        alignment: 0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      if (_scrollController.hasClients) {
        const double offsetCompensacao = 112.0;
        final currentOffset = _scrollController.offset;
        final targetOffset = (currentOffset - offsetCompensacao).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        if ((targetOffset - currentOffset).abs() > 1.0) {
          await _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      }
      _isAutoScrolling = false;
    } else {
      debugPrint('⚠️ [Scroll] Seção não encontrada na árvore de widgets');
    }
  }

  void _updateCategoryTabs(List<SecaoModel> secoes) {
    if (!mounted) return;

    for (var secao in secoes) {
      _sectionKeys.putIfAbsent(secao.id, () => GlobalKey());
    }

    if (_categoryTabController.length != secoes.length) {
      _categoryTabController.dispose();
      _categoryTabController = TabController(
        length: secoes.length,
        vsync: this,
      );
      _categoryTabController.addListener(() {
        if (mounted && !_categoryTabController.indexIsChanging) {
          setState(() {});
        }
      });
    }
  }

  Widget _buildCategoryHeader(List<SecaoModel> secoes) {
    final theme = Theme.of(context);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: secoes.length,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => VerticalDivider(
          indent: 16,
          endIndent: 16,
          width: 32,
          thickness: 1,
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
        itemBuilder: (context, index) {
          final secao = secoes[index];
          final isSelected = index == _categoryTabController.index;

          return GestureDetector(
            onTap: () {
              _enqueueAction(() async {
                _categoryTabController.animateTo(index);
                await _scrollToCategory(index);
                if (mounted) setState(() {});
              });
            },
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    secao.nome,
                    style: TextStyle(
                      color: isSelected
                          ? theme.primaryColor
                          : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 3,
                    width: isSelected ? 24 : 0,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _abrirProduto(BuildContext context, dynamic produto) {
    final authState = context.read<AuthCubit>().state;

    if (authState is AuthAuthenticated || authState is AuthGuest) {
      _abrirBottomSheetProduto(produto, widget.lojaId);
      return;
    }

    if (authState is AuthUnauthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre um endereço para começar a pedir'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
      context.read<NavigationCubit>().goToOnboarding();
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

              if (state is LojaHomeLoaded) {
                _updateCategoryTabs(state.secoes);
              }
            },
          ),
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
          buildWhen: (previous, current) => true,
          builder: (context, state) {
            final theme = Theme.of(context);

            if (state is LojaHomeLoaded) {
              debugPrint('🔍 [LojaDetalhePage] searchQuery no estado: "${state.searchQuery}"');
            }

            return ResponsivePageScaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: AppBar(
                leading: BackButton(
                  color: theme.textTheme.bodyMedium?.color,
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  state.loja?.nome ?? 'Carregando...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: theme.cardColor,
                elevation: 0,
              ),
              bottomNavigationBar: _buildBottomBar(context, state),
              body: Column(
                children: [
                  if (state.secoes.isNotEmpty) _buildCategoryHeader(state.secoes),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildBody(context, state),
                        if (state is LojaHomeLoaded && state.loadingSectionId != null)
                          Positioned.fill(
                            child: Container(
                              color: Colors.white.withValues(alpha: 0.7),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget? _buildBottomBar(BuildContext context, LojaHomeState state) {
    final navigationCubit = context.read<NavigationCubit>();

    return BlocBuilder<CarrinhoCubit, CarrinhoState>(
      builder: (context, carrinhoState) {
        final isLoading = carrinhoState is CarrinhoLoaded &&
            (carrinhoState.isRequesting || carrinhoState.isDebouncing);
        final totalItens = carrinhoState is CarrinhoLoaded
            ? carrinhoState.totalItens
            : 0;
        final lojaNome = carrinhoState is CarrinhoLoaded
            ? carrinhoState.lojaNome
            : null;

        if (totalItens > 0 && lojaNome != null) {
          return CarrinhoBottomBar(
            lojaNome: lojaNome,
            isLoading: isLoading,
            onTap: () => navigationCubit.goToCarrinho(),
          );
        }
        return const SizedBox(height: 0, width: 0);
      },
    );
  }

  Widget _buildBody(BuildContext context, LojaHomeState state) {
    if (state is LojaHomeLoading && state.secoes.isEmpty) {
      return _buildLoadingState();
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
      child: BlocSelector<CarrinhoCubit, CarrinhoState, Map<String, Map<int, int>>>(
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
          return SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (loja != null) LojaHeaderWidget(loja: loja),
                if (loja != null)
                  SearchWithFilters(
                    key: ValueKey(state is LojaHomeLoaded ? state.searchQuery : null),
                    searchQuery: state is LojaHomeLoaded ? state.searchQuery : null,
                    selectedOrderBy: state is LojaHomeLoaded ? state.orderBy : null,
                    isSearching: state is LojaHomeLoaded ? state.isSearching : false,
                    onSearch: (search) {
                      if (state is LojaHomeLoaded) {
                        _cubit.searchProducts(search);
                      }
                    },
                    onOrderBy: (orderBy) {
                      if (state is LojaHomeLoaded) {
                        _cubit.applyFilters(
                          search: state.searchQuery,
                          categoriaId: state.selectedCategories.isNotEmpty
                              ? state.selectedCategories.first
                              : null,
                          orderBy: orderBy,
                        );
                      }
                    },
                    onClearFilters: () {
                      if (state is LojaHomeLoaded) {
                        _cubit.clearFilters();
                      }
                    },
                    onClearSearch: () {
                      if (state is LojaHomeLoaded) {
                        _cubit.clearSearchOnly();
                      }
                    },
                  ),
                SecoesListWidget(
                  secoes: state.secoes,
                  lojaId: widget.lojaId,
                  onProdutoTap: (produto) => _abrirProduto(context, produto),
                  quantidadesPorProduto: dados['quantidades']!,
                  itemIdsPorProduto: dados['itemIds']!,
                  sectionKeys: _sectionKeys,
                ),
                if (isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (state is LojaHomeLoaded &&
                    !state.hasMore &&
                    state.secoes.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'Isso é tudo por enquanto! 🍕',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 8,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            LoadingSkeleton(width: 52, height: 52, borderRadius: 8),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingSkeleton(width: 150, height: 16),
                  SizedBox(height: 8),
                  LoadingSkeleton(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}