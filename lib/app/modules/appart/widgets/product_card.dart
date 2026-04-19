import 'package:flutter/material.dart';
import '../../../models/produto_model.dart';
import '../../../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final ProdutoModel produto;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool showImage;
  final EdgeInsetsGeometry padding;
  final double? imageSize;

  const ProductCard({
    super.key,
    required this.produto,
    this.onTap,
    this.onAddToCart,
    this.showImage = true,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.imageSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInfo(context)),
            if (showImage) _buildImage(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(produto.nome, style: Theme.of(context).textTheme.titleMedium),
        if (produto.descricao!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(produto.descricao ?? "",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600], fontSize: 13,
            ), maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Row(children: _buildPrice()),
      ],
    );
  }

  List<Widget> _buildPrice() {
    return [
      Text(produto.precoFormatado,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
          color: AppTheme.primaryColor,
        ),
      ),
      if (onAddToCart != null) ...[
        const Spacer(),
        IconButton(icon: const Icon(Icons.add), onPressed: onAddToCart),
      ]
    ];
  }

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(produto.imagem ?? "",
          width: imageSize, height: imageSize, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: imageSize, height: imageSize, color: Colors.grey[200],
            child: Icon(Icons.fastfood, color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }
}