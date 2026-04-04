import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../models/produto_model.dart';

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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          border: Border(
            bottom: BorderSide(color: context.dividerColor),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (produto.destaque)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fireplace, size: 12, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            'DESTAQUE',
                            style: context.bodySmall.copyWith(
                              color: Colors.orange[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    produto.nome,
                    style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (produto.descricao != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      produto.descricao!,
                      style: context.bodySmall,
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
                          style: context.bodyMedium.copyWith(
                            color: context.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                          style: context.bodySmall.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ] else
                        Text(
                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                          style: context.bodyMedium.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 14, color: context.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${produto.tempoPreparo} min',
                        style: context.bodySmall,
                      ),
                      if (produto.notaMedia > 0) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 14, color: context.ratingColor),
                        const SizedBox(width: 4),
                        Text(
                          produto.notaMedia.toString(),
                          style: context.bodySmall.copyWith(color: context.ratingColor, fontWeight: FontWeight.bold),
                        ),
                      ],
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
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
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
