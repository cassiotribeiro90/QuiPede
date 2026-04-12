import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/loja_item.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../routes/app_routes.dart';
import '../../../models/lojas_list_filter_option_model.dart';
import '../../carrinho/widgets/carrinho_bottom_bar.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';
import '../../../di/dependencies.dart';

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
    context.read<LojasCubit>().fetchLojas(perPage: 10);
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<CarrinhoCubit>()),
      ],
      child: BlocBuilder<LojasCubit, LojasState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.backgroundColor,
            appBar: AppBar(
              title: Text('Lojas', style: context.titleLarge),
              elevation: 0,
              backgroundColor: context.backgroundColor,
              foregroundColor: context.textPrimary,
            ),
            body: Column(
              children: [
                _buildSearchTrigger(state),
                Expanded(child: _buildBody(state)),
              ],
            ),
            bottomNavigationBar: const CarrinhoBottomBar(),
          );
        },
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

  Widget _buildBody(LojasState state) {
    if (state is LojasLoading) {
      return _buildLoadingState();
    }

    if (state is LojasLoaded) {
      final lojas = state.lojasFiltradas;
      if (lojas.isEmpty) return _buildEmptyState(state.lojas.isEmpty);

      return RefreshIndicator(
        onRefresh: () => context.read<LojasCubit>().refreshList(),
        child: ListView.separated(
          controller: _scrollController,
          itemCount: lojas.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) => Divider(
            height: 1, 
            thickness: 0.5, 
            indent: 16, 
            endIndent: 16,
            color: context.borderColor.withOpacity(0.5),
          ),
          itemBuilder: (context, index) {
            if (index == lojas.length) {
              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
            }
            final loja = lojas[index];
            return LojaItem(
              loja: loja,
              onTap: () => Navigator.pushNamed(context, Routes.lojaHome, arguments: loja.id),
            );
          },
        ),
      );
    }
    
    if (state is LojasError) {
      return Center(child: Text(state.message));
    }

    return const SizedBox();
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            LoadingSkeleton(width: 52, height: 52, borderRadius: 8),
            const SizedBox(width: 12),
            const Expanded(
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
