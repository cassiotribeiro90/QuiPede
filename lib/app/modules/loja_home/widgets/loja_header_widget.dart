import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../models/loja_detalhe_model.dart';
import '../../../core/theme/app_theme_extension.dart';

class LojaHeaderWidget extends StatelessWidget {
  final LojaDetalheModel loja;

  const LojaHeaderWidget({super.key, required this.loja});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CachedNetworkImage(
                imageUrl: loja.capa,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[300]),
                errorWidget: (context, url, error) => Container(color: Colors.grey[300]),
              ),
              Positioned(
                bottom: -40,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: CachedNetworkImageProvider(loja.logo),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        loja.nome,
                        style: context.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (loja.verificado)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.verified, color: Colors.blue, size: 20),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: loja.status == 'ativo' ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        loja.status.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: context.ratingColor, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      loja.notaMedia.toString(),
                      style: context.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: context.ratingColor),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${loja.totalAvaliacoes} avaliações)',
                      style: context.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Text('•', style: context.bodySmall),
                    const SizedBox(width: 8),
                    Text(loja.categoria, style: context.bodySmall),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoItem(
                      icon: Icons.timer_outlined,
                      label: '${loja.tempoEntregaMin}-${loja.tempoEntregaMax} min',
                    ),
                    const SizedBox(width: 16),
                    _InfoItem(
                      icon: Icons.delivery_dining_outlined,
                      label: loja.taxaEntrega == 0 ? 'Grátis' : 'R\$ ${loja.taxaEntrega.toStringAsFixed(2)}',
                    ),
                    const SizedBox(width: 16),
                    _InfoItem(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Min. R\$ ${loja.pedidoMinimo.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  loja.enderecoResumido,
                  style: context.bodySmall,
                ),
                if (loja.descricao != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    loja.descricao!,
                    style: context.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: context.bodySmall.copyWith(color: context.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
