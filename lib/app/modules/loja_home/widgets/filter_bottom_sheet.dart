import 'package:flutter/material.dart';
import '../../../../app/core/theme/app_theme_extension.dart';
import '../models/loja_detalhe_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final LojaFilterOptions options;
  final int? initialCategoriaId;
  final String? initialOrderBy;
  final Function(int? categoriaId, String? orderBy) onApply;

  const FilterBottomSheet({
    super.key,
    required this.options,
    this.initialCategoriaId,
    this.initialOrderBy,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int? _selectedCategoriaId;
  String? _selectedOrderBy;

  @override
  void initState() {
    super.initState();
    _selectedCategoriaId = widget.initialCategoriaId;
    _selectedOrderBy = widget.initialOrderBy;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context;
    final textStyles = context;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filtros', style: textStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          Text('Ordenar por', style: textStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.options.ordenacao.map((opt) {
              final isSelected = _selectedOrderBy == opt.value;
              return ChoiceChip(
                label: Text('${opt.icon} ${opt.label}'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedOrderBy = selected ? opt.value : null);
                },
                selectedColor: colors.primaryColor.withOpacity(0.2),
                backgroundColor: colors.surfaceColor,
                labelStyle: textStyles.bodySmall.copyWith(
                  color: isSelected ? colors.primaryColor : colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Categorias', style: textStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.options.categorias.map((cat) {
              final isSelected = _selectedCategoriaId == cat.id;
              return ChoiceChip(
                label: Text('${cat.icone} ${cat.nome} (${cat.totalProdutos})'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCategoriaId = selected ? cat.id : null);
                },
                selectedColor: colors.primaryColor.withOpacity(0.2),
                backgroundColor: colors.surfaceColor,
                labelStyle: textStyles.bodySmall.copyWith(
                  color: isSelected ? colors.primaryColor : colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategoriaId = null;
                      _selectedOrderBy = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedCategoriaId, _selectedOrderBy);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
