// lib/app/modules/lojas/widgets/filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/lojas_list_filter_option_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<LojasListFilterOptionModel> categorias;
  final String? selectedCategoria;
  final String? selectedOrdenacao;
  final Function(String? categoria, String? ordenacao) onApply;
  final VoidCallback onClear;

  const FilterBottomSheet({
    super.key,
    required this.categorias,
    this.selectedCategoria,
    this.selectedOrdenacao,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();

  static Future<void> show({
    required BuildContext context,
    required List<LojasListFilterOptionModel> categorias,
    String? selectedCategoria,
    String? selectedOrdenacao,
    required Function(String? categoria, String? ordenacao) onApply,
    required VoidCallback onClear,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        categorias: categorias,
        selectedCategoria: selectedCategoria,
        selectedOrdenacao: selectedOrdenacao,
        onApply: onApply,
        onClear: onClear,
      ),
    );
  }
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _tempCategoria;
  late String? _tempOrdenacao;

  final List<_OrdenacaoOption> _ordenacoes = const [
    _OrdenacaoOption(value: 'nota', label: 'Melhor avaliados', icon: Icons.star),
    _OrdenacaoOption(value: 'tempo_entrega', label: 'Menor tempo', icon: Icons.timer),
    _OrdenacaoOption(value: 'taxa_entrega', label: 'Menor taxa', icon: Icons.money_off),
    _OrdenacaoOption(value: 'pedido_minimo', label: 'Menor pedido mínimo', icon: Icons.shopping_cart),
  ];

  @override
  void initState() {
    super.initState();
    _tempCategoria = widget.selectedCategoria;
    _tempOrdenacao = widget.selectedOrdenacao;
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_tempCategoria != null) count++;
    if (_tempOrdenacao != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSection(),
                  const SizedBox(height: 16),
                  _buildCategoriesSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.hintColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrar lojas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenar por',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // 🔥 LISTA MINIMALISTA SEM BORDAS
        Column(
          children: _ordenacoes.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _tempOrdenacao == option.value;

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _tempOrdenacao = isSelected ? null : option.value;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          option.icon,
                          size: 22,
                          color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            option.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            size: 22,
                            color: theme.primaryColor,
                          ),
                      ],
                    ),
                  ),
                ),
                if (index < _ordenacoes.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    if (widget.categorias.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorias',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // 🔥 LISTA MINIMALISTA SEM BORDAS
        Column(
          children: widget.categorias.asMap().entries.map((entry) {
            final index = entry.key;
            final cat = entry.value;
            final isSelected = _tempCategoria == cat.value;

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _tempCategoria = isSelected ? null : cat.value;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Text(
                          '${cat.label} (${cat.count})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            size: 22,
                            color: theme.primaryColor,
                          ),
                      ],
                    ),
                  ),
                ),
                if (index < widget.categorias.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final theme = Theme.of(context);
    final hasActiveFilters = _activeFiltersCount > 0;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: hasActiveFilters ? _clearFilters : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: hasActiveFilters ? theme.primaryColor : theme.hintColor,
                  side: BorderSide(
                    color: hasActiveFilters ? theme.primaryColor : theme.dividerColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Limpar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: hasActiveFilters ? theme.primaryColor : theme.hintColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Aplicar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    widget.onApply(_tempCategoria, _tempOrdenacao);
    context.pop();
  }

  void _clearFilters() {
    setState(() {
      _tempCategoria = null;
      _tempOrdenacao = null;
    });
    widget.onClear();
    context.pop();
  }
}

class _OrdenacaoOption {
  final String value;
  final String label;
  final IconData icon;

  const _OrdenacaoOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}