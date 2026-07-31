import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../models/endereco_model.dart';

class EnderecoCard extends StatelessWidget {
  final EnderecoModel endereco;
  final bool isPrincipal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPrincipal;

  const EnderecoCard({
    super.key,
    required this.endereco,
    required this.isPrincipal,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrincipal 
            ? context.primaryColor.withOpacity(0.05) 
            : context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrincipal 
              ? context.primaryColor 
              : context.borderColor,
          width: isPrincipal ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isPrincipal ? Icons.check_circle : Icons.location_on,
                      color: isPrincipal ? context.primaryColor : context.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      endereco.label ?? 'Endereço',
                      style: context.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isPrincipal) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Principal',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  if (!isPrincipal)
                    TextButton(
                      onPressed: onSetPrincipal,
                      child: Text(
                        'Selecionar',
                        style: TextStyle(
                          color: context.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: context.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            endereco.enderecoCompleto,
            style: context.bodyMedium,
          ),
        ],
      ),
    );
  }
}
