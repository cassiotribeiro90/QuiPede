import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../models/loja_resumo_model.dart';

class LojaItem extends StatelessWidget {
  final LojaResumo loja;
  final VoidCallback onTap;

  const LojaItem({super.key, required this.loja, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo da Loja
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.borderColor.withOpacity(0.5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (loja.logo != null && loja.logo!.isNotEmpty)
                    ? Image.network(
                        loja.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.store, color: context.textHint),
                      )
                    : Icon(Icons.store, color: context.textHint),
              ),
            ),
            const SizedBox(width: 12),
            // Informações principais
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          loja.nome,
                          style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (loja.verificado)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified, size: 14, color: context.primaryColor),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: context.ratingColor),
                      const SizedBox(width: 4),
                      Text(
                        '${loja.notaMedia.toStringAsFixed(1)} · ',
                        style: context.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.ratingColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          loja.categoria,
                          style: context.bodySmall.copyWith(color: context.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 14, color: context.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${loja.tempoEntregaFormatado} · ',
                        style: context.bodySmall.copyWith(color: context.textSecondary),
                      ),
                      Icon(Icons.location_on_outlined, size: 14, color: context.textHint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          loja.cidade,
                          style: context.bodySmall.copyWith(color: context.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Taxa de entrega e Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  loja.taxaEntrega == 0 ? 'Grátis' : 'R\$ ${loja.taxaEntrega.toStringAsFixed(2)}',
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: loja.taxaEntrega == 0 ? context.successColor : context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Aberto',
                    style: context.caption.copyWith(
                      color: context.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
