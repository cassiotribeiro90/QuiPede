// lib/app/modules/loja_home/widgets/filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/primary_button.dart';

/// Bottom sheet de ORDENAÇÃO para produtos
/// - Apenas ordenação (sem categorias, sem busca)
/// - Design minimalista sem bordas arredondadas
class FilterBottomSheet extends StatefulWidget {
  final String? selectedOrderBy;
  final Function(String? orderBy) onApply;
  final VoidCallback onClear;

  const FilterBottomSheet({
    super.key,
    this.selectedOrderBy,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();

  static Future<void> show({
    required BuildContext context,
    String? selectedOrderBy,
    required Function(String? orderBy) onApply,
    required VoidCallback onClear,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        selectedOrderBy: selectedOrderBy,
        onApply: onApply,
        onClear: onClear,
      ),
    );
  }
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _tempOrderBy;

  final List<_OrderOption> _orderOptions = const [
    _OrderOption(value: 'relevancia', label: 'Relevância', icon: Icons.trending_up),
    _OrderOption(value: 'avaliacao', label: 'Melhor avaliados', icon: Icons.star),
    _OrderOption(value: 'destaque', label: 'Destaques', icon: Icons.whatshot),
    _OrderOption(value: 'preco_asc', label: 'Menor preço', icon: Icons.attach_money),
    _OrderOption(value: 'preco_desc', label: 'Maior preço', icon: Icons.money_off),
  ];

  @override
  void initState() {
    super.initState();
    _tempOrderBy = widget.selectedOrderBy ?? 'relevancia';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
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
              child: _buildOrderList(),
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
          Text(
            'Ordenar por',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    final theme = Theme.of(context);

    return Column(
      children: _orderOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = _tempOrderBy == option.value;

        return Column(
          children: [
            // 🔥 OPÇÃO MINIMALISTA SEM BORDA
            GestureDetector(
              onTap: () {
                setState(() {
                  _tempOrderBy = isSelected ? 'relevancia' : option.value;
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
            // 🔥 SEPARADOR SUAVE (exceto no último)
            if (index < _orderOptions.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    final theme = Theme.of(context);
    final hasActiveFilters = _tempOrderBy != null && _tempOrderBy != 'relevancia';

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
            child: SecondaryOutlineButton(
              onPressed: hasActiveFilters ? _clearFilters : null,
              label: 'Limpar',
              color: hasActiveFilters ? theme.primaryColor : theme.hintColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              onPressed: _applyFilters,
              label: 'Aplicar',
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    widget.onApply(_tempOrderBy == 'relevancia' ? null : _tempOrderBy);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _tempOrderBy = 'relevancia';
    });
    widget.onClear();
    Navigator.pop(context);
  }
}

class _OrderOption {
  final String value;
  final String label;
  final IconData icon;

  const _OrderOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}