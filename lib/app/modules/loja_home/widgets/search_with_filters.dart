import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../models/categoria_filter_model.dart';
import 'filter_bottom_sheet.dart';

class SearchWithFilters extends StatelessWidget {
  final List<CategoriaFilterModel> categorias;
  final int? selectedCategoriaId;
  final String? selectedOrderBy;
  final String? searchQuery;
  final Function(String? search, int? categoriaId, String? orderBy) onApply;
  final VoidCallback onClearFilters;

  const SearchWithFilters({
    super.key,
    required this.categorias,
    required this.selectedCategoriaId,
    required this.selectedOrderBy,
    this.searchQuery,
    required this.onApply,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = selectedCategoriaId != null || 
                            selectedOrderBy != null || 
                            (searchQuery != null && searchQuery!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: GestureDetector(
        onTap: () => _showFilterBottomSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasActiveFilters ? context.primaryColor : context.borderColor,
              width: hasActiveFilters ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search, 
                color: hasActiveFilters ? context.primaryColor : context.textHint,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getFilterSummary(),
                  style: context.bodyMedium.copyWith(
                    color: hasActiveFilters ? context.textPrimary : context.textHint,
                    fontWeight: hasActiveFilters ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasActiveFilters)
                GestureDetector(
                  onTap: () {
                    // Limpa os filtros
                    onClearFilters();
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

  String _getFilterSummary() {
    if (selectedCategoriaId == null && selectedOrderBy == null && (searchQuery == null || searchQuery!.isEmpty)) {
      return 'Pesquisar produtos...';
    }

    final List<String> parts = [];

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      parts.add('"${searchQuery!}"');
    }

    if (selectedCategoriaId != null) {
      try {
        final cat = categorias.firstWhere((c) => c.id == selectedCategoriaId);
        parts.add(cat.nome);
      } catch (_) {}
    }

    if (selectedOrderBy != null) {
      parts.add(_getOrderByLabel(selectedOrderBy!));
    }

    return parts.join(' • ');
  }

  String _getOrderByLabel(String orderBy) {
    switch (orderBy) {
      case 'relevancia': return 'Relevância';
      case 'avaliacao': return 'Melhor avaliados';
      case 'destaque': return 'Destaques';
      case 'preco_asc': return 'Menor preço';
      case 'preco_desc': return 'Maior preço';
      default: return 'Ordenar';
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        categorias: categorias,
        selectedCategoriaId: selectedCategoriaId,
        selectedOrderBy: selectedOrderBy,
        initialSearch: searchQuery,
        onApply: onApply,
        onClear: onClearFilters,
      ),
    );
  }
}
