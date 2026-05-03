import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/loja_item.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_drawer.dart';
import '../../../models/lojas_list_filter_option_model.dart';
import '../../carrinho/widgets/carrinho_bottom_bar.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../di/dependencies.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';

class LojasListScreen extends StatefulWidget {
  const LojasListScreen({super.key});

  @override
  State<LojasListScreen> createState() => _LojasListScreenState();
}

class _LojasListScreenState extends State<LojasListScreen> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LojasCubit>().fetchLojas(perPage: 10);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final cubit = context.read<LojasCubit>();
      final state = cubit.state;
      if (cubit.hasMorePages && state is LojasLoaded && !state.isLoadingMore) {
        cubit.fetchLojas(
          page: cubit.currentPage + 1,
          perPage: 10,
          isLoadMore: true,
        );
      }
    }
  }

  void _showFilter(LojasLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        categorias: state.categorias,
        selectedCategoria: state.categoriaSelecionada,
        selectedOrdenacao: state.ordenacaoAtual,
        initialSearch: _searchController.text,
        onApply: (search, categoria, ordenacao) {
          _searchController.text = search ?? '';
          context.read<LojasCubit>().applyFilters(
            categoria: categoria,
            ordenacao: ordenacao,
            search: search,
          );
        },
        onClear: () {
          _searchController.clear();
          context.read<LojasCubit>().clearAllFilters();
        },
      ),
    );
  }

  void _navegarParaEnderecos(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      Navigator.pushNamed(context, Routes.login);
    } else {
      Navigator.pushNamed(context, Routes.enderecos);
    }
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return BlocBuilder<LocalizacaoCubit, LocalizacaoState>(
      builder: (context, state) {
        String titulo = 'Selecionar endereço';
        
        if (state is LocalizacaoCarregada) {
          titulo = state.enderecoFormatado;
        }

        return GestureDetector(
          onTap: () => _navegarParaEnderecos(context),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_rounded, size: 18, color: context.primaryColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  titulo,
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: context.textSecondary),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<CarrinhoCubit>()),
      ],
      child: BlocListener<LocalizacaoCubit, LocalizacaoState>(
        listener: (context, state) {
          if (state is LocalizacaoNaoEncontrada) {
            _navegarParaEnderecos(context);
          }
        },
        child: BlocBuilder<LojasCubit, LojasState>(
          builder: (context, state) {
            return ResponsivePageScaffold(
              backgroundColor: context.backgroundColor,
              drawer: const AppDrawer(),
              appBar: AppBar(
                title: _buildAppBarTitle(context),
                centerTitle: true,
                elevation: 0,
                backgroundColor: context.backgroundColor,
                foregroundColor: context.textPrimary,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                actions: [
                   IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
              bottomNavigationBar: const CarrinhoBottomBar(),
              body: RefreshIndicator(
                onRefresh: () => context.read<LojasCubit>().refreshList(),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildSearchTrigger(state),
                    ),
                    _buildSliverBody(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchTrigger(LojasState state) {
    String summary = 'Pesquisar lojas...';
    bool hasFilters = false;

    if (state is LojasLoaded) {
      final List<String> parts = [];
      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
        parts.add('"${state.searchQuery}"');
      }
      if (state.categoriaSelecionada != null) {
        parts.add(_getCategoriaLabel(state.categoriaSelecionada!, state.categorias));
      }
      if (state.ordenacaoAtual != null) {
        parts.add(_getOrdenacaoLabel(state.ordenacaoAtual!));
      }

      if (parts.isNotEmpty) {
        summary = parts.join(' • ');
        hasFilters = true;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: GestureDetector(
        onTap: () {
          if (state is LojasLoaded) _showFilter(state);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasFilters ? context.primaryColor : context.borderColor,
              width: hasFilters ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search, 
                color: hasFilters ? context.primaryColor : context.textHint,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  summary,
                  style: context.bodyMedium.copyWith(
                    color: hasFilters ? context.textPrimary : context.textHint,
                    fontWeight: hasFilters ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasFilters)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    context.read<LojasCubit>().clearAllFilters();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.close, size: 20, color: context.primaryColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoriaLabel(String value, List<LojasListFilterOptionModel> categorias) {
    try {
      return categorias.firstWhere((c) => c.value == value).label;
    } catch (_) {
      return value;
    }
  }

  String _getOrdenacaoLabel(String value) {
    switch (value) {
      case 'nota': return 'Melhor avaliados';
      case 'tempo_entrega': return 'Menor tempo';
      case 'taxa_entrega': return 'Menor taxa';
      case 'pedido_minimo': return 'Menor pedido mínimo';
      default: return value;
    }
  }

  Widget _buildSliverBody(LojasState state) {
    if (state is LojasLoading || state is LojasInitial) {
      return SliverToBoxAdapter(child: _buildLoadingState());
    }

    if (state is LojasLoaded) {
      final lojas = state.lojasFiltradas;
      if (lojas.isEmpty) return SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState(state.lojas.isEmpty));

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= lojas.length) {
              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
            }
            final loja = lojas[index];
            return Column(
              children: [
                LojaItem(
                  loja: loja,
                  onTap: () => Navigator.pushNamed(context, Routes.lojaHome, arguments: loja.id),
                ),
                if (index < lojas.length - 1)
                  Divider(
                    height: 1, 
                    thickness: 0.5, 
                    indent: 16, 
                    endIndent: 16,
                    color: context.borderColor.withOpacity(0.5),
                  ),
              ],
            );
          },
          childCount: lojas.length + (state.isLoadingMore ? 1 : 0),
        ),
      );
    }
    
    if (state is LojasError) {
      return SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(state.message)));
    }

    return const SliverToBoxAdapter(child: SizedBox());
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

  Widget _buildEmptyState(bool isOverallEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined, size: 80, color: context.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Nenhuma loja encontrada', style: context.titleMedium),
          const SizedBox(height: 8),
          Text(
            isOverallEmpty ? 'Volte mais tarde!' : 'Tente outros filtros', 
            style: context.bodyMedium.copyWith(color: context.textSecondary),
          ),
          if (!isOverallEmpty)
            TextButton(
              onPressed: () => context.read<LojasCubit>().clearAllFilters(),
              child: const Text('Limpar filtros'),
            ),
        ],
      ),
    );
  }
}
