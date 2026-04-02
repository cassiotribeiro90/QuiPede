import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../app/core/theme/app_theme_extension.dart';
import '../models/loja_detalhe_model.dart';

class LojaHeaderWidget extends StatelessWidget {
  final LojaDetalheModel loja;

  const LojaHeaderWidget({super.key, required this.loja});

  @override
  Widget build(BuildContext context) {
    final colors = context;
    final textStyles = context;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Banner
            CachedNetworkImage(
              imageUrl: loja.capa,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: colors.surfaceColor),
            ),
            // Logo
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
                      style: textStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (loja.verificado)
                    Icon(Icons.verified, color: colors.primaryColor, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: colors.ratingColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${loja.notaMedia} (${loja.totalAvaliacoes}+ avaliações)',
                    style: textStyles.bodySmall.copyWith(color: colors.ratingColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text('•', style: textStyles.bodySmall),
                  const SizedBox(width: 8),
                  Text(loja.categoria, style: textStyles.bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _infoItem(
                    context,
                    Icons.timer_outlined,
                    '${loja.tempoEntregaMin}-${loja.tempoEntregaMax} min',
                  ),
                  const SizedBox(width: 16),
                  _infoItem(
                    context,
                    Icons.delivery_dining_outlined,
                    loja.taxaEntrega == 0 ? 'Entrega grátis' : 'R\$ ${loja.taxaEntrega.toStringAsFixed(2)}',
                  ),
                  const SizedBox(width: 16),
                  _infoItem(
                    context,
                    Icons.shopping_bag_outlined,
                    'Mín. R\$ ${loja.pedidoMinimo.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoItem(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: context.bodySmall.copyWith(color: context.textSecondary)),
      ],
    );
  }
}
