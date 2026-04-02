import 'package:flutter/material.dart';
import '../../../../app/core/theme/app_theme_extension.dart';
import '../models/loja_detalhe_model.dart';

class SectionsTabsWidget extends StatelessWidget {
  final List<LojaFilterCategoria> categorias;
  final int? selectedId;
  final Function(int) onCategorySelected;

  const SectionsTabsWidget({
    super.key,
    required this.categorias,
    this.selectedId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context;
    final textStyles = context;

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final isSelected = selectedId == categoria.id;

          return InkWell(
            onTap: () => onCategorySelected(categoria.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? colors.primaryColor : colors.surfaceColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? colors.primaryColor : colors.borderColor,
                ),
              ),
              child: Text(
                '${categoria.icone} ${categoria.nome}',
                style: textStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
