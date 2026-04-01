import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qui/app/modules/lojas/models/loja.dart';
import 'package:qui/app/routes/app_routes.dart';
import 'package:qui/app/core/theme/app_theme_extension.dart';
import 'package:qui/app/core/utils/text_utils.dart';

class LojaItemWidget extends StatelessWidget {
  final Loja loja;

  const LojaItemWidget({super.key, required this.loja});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    
    // ✅ LIMPAR A CATEGORIA PARA EXIBIÇÃO
    final displayCategory = TextUtils.getDisplayCategory(loja.categoria);

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.LOJA_HOME, arguments: loja.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: ClipRRect(
                borderRadius: context.borderRadiusSmall,
                child: CachedNetworkImage(
                  imageUrl: loja.logo ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: theme.disabledColor.withOpacity(0.1)),
                  errorWidget: (context, url, error) => Center(child: Icon(Icons.store, color: theme.disabledColor)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loja.nome, 
                    style: textTheme.titleMedium?.copyWith(
                      color: context.textPrimary, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: context.ratingColor, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        loja.notaMedia.toString(),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold, 
                          color: context.textPrimary
                        ),
                      ),
                      Text(
                        ' • $displayCategory',
                        style: textTheme.bodyMedium?.copyWith(color: context.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loja.tempoEntregaFormatado} • ${loja.taxaEntregaFormatada}',
                    style: textTheme.bodyMedium?.copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
