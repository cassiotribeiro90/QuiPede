import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../models/categoria_filter_model.dart';

class LojaFilterCategory extends StatelessWidget {
  final List<CategoriaFilterModel> categorias;
  final int? selectedId;
  final Function(int?) onSelected;

  const LojaFilterCategory({
    super.key,
    required this.categorias,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categorias[index];
          final isSelected = selectedId == cat.id;
          
          return GestureDetector(
            onTap: () => onSelected(isSelected ? null : cat.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? context.primarySurface : context.surfaceColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? context.primaryColor : context.borderColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cat.icone != null) ...[
                    Text(cat.icone!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    cat.nome,
                    style: context.bodyMedium.copyWith(
                      color: isSelected ? context.primaryColor : context.textSecondary,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? context.primaryColor : context.textHint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cat.totalProdutos}',
                      style: context.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
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
}
