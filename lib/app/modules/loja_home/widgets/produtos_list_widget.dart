import 'package:flutter/material.dart';
import '../../../models/produto_model.dart';
import 'produto_card_widget.dart';
import '../../../core/theme/app_theme_extension.dart';

class ProdutosListWidget extends StatelessWidget {
  final List<ProdutoModel> items;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final Function(ProdutoModel) onProdutoTap;

  const ProdutosListWidget({
    super.key,
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onProdutoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoadingMore) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: context.textHint),
              const SizedBox(height: 16),
              Text(
                'Nenhum produto encontrado',
                style: context.bodyLarge.copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < items.length) {
            return ProdutoCardWidget(
              produto: items[index],
              onTap: () => onProdutoTap(items[index]),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: hasMore
                    ? CircularProgressIndicator(color: context.primaryColor)
                    : Text(
                        'Isso é tudo por enquanto! 🍕',
                        style: context.bodySmall.copyWith(color: context.textHint),
                      ),
              ),
            );
          }
        },
        childCount: items.length + 1,
      ),
    );
  }
}
