import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../models/produto_model.dart';
import '../../../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final ProdutoModel produto;

  const ProductCard({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () { /* Navegar para o detalhe do produto */ },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(produto.nome, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  if (produto.descricao!.isNotEmpty)
                    Text(
                      produto.descricao ?? "",
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${produto.preco.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (produto.imagem!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: produto.imagem ?? "",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
