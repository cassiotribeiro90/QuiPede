import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qui/app/modules/lojas/bloc/lojas_cubit.dart';
import 'package:qui/app/modules/lojas/bloc/lojas_state.dart';
import 'package:qui/app/modules/lojas/widgets/filter_search_bottom_sheet.dart';
import 'package:qui/app/modules/lojas/views/loja_item_widget.dart';
import 'package:qui/app/core/utils/text_utils.dart';

class LojasView extends StatefulWidget {
  const LojasView({super.key});

  @override
  State<LojasView> createState() => _LojasViewState();
}

class _LojasViewState extends State<LojasView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LojasCubit>().fetchLojas();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final cubit = context.read<LojasCubit>();
      final state = cubit.state;
      if (cubit.hasMorePages && state is LojasLoaded && !state.isLoadingMore) {
        cubit.fetchLojas(page: cubit.currentPage + 1, isLoadMore: true);
      }
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<LojasCubit>(),
        child: FilterSearchBottomSheet(
          onApplyFilters: (search, categoria, ordenacao) {
            context.read<LojasCubit>().applyFilters(
              search: search,
              categoria: categoria,
              ordenacao: ordenacao,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LojasCubit, LojasState>(
      builder: (context, state) {
        if (state is LojasLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LojasError) {
          return Center(child: Text(state.message));
        }

        if (state is LojasLoaded) {
          return Column(
            children: [
              _buildFilterSummary(state),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<LojasCubit>().refreshList(),
                  child: state.lojasFiltradas.isEmpty
                      ? _buildEmptyState(state)
                      : ListView.separated(
                          controller: _scrollController,
                          itemCount: state.lojasFiltradas.length + (state.isLoadingMore ? 1 : 0),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == state.lojasFiltradas.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return LojaItemWidget(loja: state.lojasFiltradas[index]);
                          },
                        ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilterSummary(LojasLoaded state) {
    final filterSummary = _getFilterSummary(state);
    final hasActiveFilters = filterSummary.isNotEmpty;

    return GestureDetector(
      onTap: _showFilterBottomSheet,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 20,
              color: hasActiveFilters ? Colors.orange[700] : Colors.grey[500],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasActiveFilters ? filterSummary : 'O que você quer comer?',
                style: TextStyle(
                  color: hasActiveFilters ? Colors.orange[700] : Colors.grey[500],
                  fontSize: 14,
                  fontWeight: hasActiveFilters ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasActiveFilters)
              GestureDetector(
                onTap: () => context.read<LojasCubit>().clearAllFilters(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                ),
              )
            else
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  String _getFilterSummary(LojasLoaded state) {
    final List<String> parts = [];

    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      parts.add(state.searchQuery!);
    }

    if (state.categoriaSelecionada != null) {
      final cat = state.categorias.firstWhere((c) => c.value == state.categoriaSelecionada, 
          orElse: () => state.categorias.isNotEmpty ? state.categorias.first : state.categorias.first);
      
      final categoriaClean = TextUtils.getDisplayCategory(cat.label);
      if (categoriaClean.isNotEmpty) {
        parts.add(categoriaClean);
      }
    }

    if (state.ordenacaoAtual != null) {
      parts.add(_getOrdenacaoLabel(state.ordenacaoAtual!));
    }

    if (parts.isEmpty) return '';

    return parts.join(' • ');
  }

  String _getOrdenacaoLabel(String ordenacao) {
    switch (ordenacao) {
      case 'nota':
        return 'Melhor nota';
      case 'tempo_entrega':
        return 'Mais rápido';
      case 'distancia':
        return 'Mais próximo';
      default:
        return ordenacao;
    }
  }

  Widget _buildEmptyState(LojasLoaded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma loja encontrada',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.read<LojasCubit>().clearAllFilters(),
            child: const Text('Limpar filtros'),
          ),
        ],
      ),
    );
  }
}
