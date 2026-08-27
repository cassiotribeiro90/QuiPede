import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../enderecos/models/endereco_model.dart';

class EnderecoCard extends StatelessWidget {
  final EnderecoModel? endereco;
  final String? logradouro;
  final String? bairro;
  final String? cidade;
  final String? uf;
  final String? cep;
  final bool isPrincipal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetPrincipal;

  const EnderecoCard({
    super.key,
    this.endereco,
    this.logradouro,
    this.bairro,
    this.cidade,
    this.uf,
    this.cep,
    this.isPrincipal = false,
    this.onEdit,
    this.onDelete,
    this.onSetPrincipal,
  });

  factory EnderecoCard.fromModel({
    required EnderecoModel endereco,
    required bool isPrincipal,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onSetPrincipal,
  }) {
    return EnderecoCard(
      endereco: endereco,
      isPrincipal: isPrincipal,
      onEdit: onEdit,
      onDelete: onDelete,
      onSetPrincipal: onSetPrincipal,
    );
  }

  factory EnderecoCard.simples({
    required String logradouro,
    required String bairro,
    required String cidade,
    required String uf,
    required String cep,
  }) {
    return EnderecoCard(
      logradouro: logradouro,
      bairro: bairro,
      cidade: cidade,
      uf: uf,
      cep: cep,
      isPrincipal: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isListMode = endereco != null;

    final displayLogradouro = isListMode ? endereco!.logradouro : (logradouro ?? '');
    final displayBairro = isListMode ? endereco!.bairro : (bairro ?? '');
    final displayCidade = isListMode ? endereco!.cidade : (cidade ?? '');
    final displayUf = isListMode ? endereco!.uf : (uf ?? '');
    final displayPrincipal = isListMode ? isPrincipal : false;

    String displayCompleto;
    if (isListMode) {
      try {
        displayCompleto = endereco!.enderecoCompleto;
      } catch (_) {
        displayCompleto = '$displayLogradouro, $displayBairro, $displayCidade - $displayUf';
      }
    } else {
      displayCompleto = '$displayLogradouro, $displayBairro, $displayCidade - $displayUf';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 5),
      decoration: BoxDecoration(
        color: displayPrincipal
            ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: displayPrincipal
              ? Theme.of(context).primaryColor
              : Colors.grey.shade200,
          width: displayPrincipal ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2, right: 4),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayCompleto,
                      style: const TextStyle(
                        fontSize: 17, // ✅ Tamanho bom (era 19, reduzimos 2px)
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: null,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    if (displayPrincipal) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Principal',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (isListMode && onEdit != null && onDelete != null) ...[
                if (!displayPrincipal && onSetPrincipal != null)
                  TextButton(
                    onPressed: onSetPrincipal,
                    child: Text(
                      'Selecionar',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}