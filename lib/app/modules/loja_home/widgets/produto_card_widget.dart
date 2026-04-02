import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../app/core/theme/app_theme_extension.dart';
import '../models/produto_model.dart';

class ProdutoCardWidget extends StatelessWidget {
  final ProdutoModel produto;
  final VoidCallback onTap;

  const ProdutoCardWidget({
    super.key,
    required this.produto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context;
    final textStyles = context;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (produto.destaque)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: colors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'DESTAQUE',
                        style: textStyles.caption.copyWith(
                          color: colors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  Text(
                    produto.nome,
                    style: textStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (produto.descricao != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      produto.descricao!,
                      style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (produto.precoPromocional != null) ...[
                        Text(
                          'R\$ ${produto.precoPromocional!.toStringAsFixed(2)}',
                          style: textStyles.price.copyWith(color: colors.successColor),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                          style: textStyles.bodySmall.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: colors.textHint,
                          ),
                        ),
                      ] else
                        Text(
                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                          style: textStyles.price,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (produto.imagem != null) ...[
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: produto.imagem!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: colors.surfaceColor),
                  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
