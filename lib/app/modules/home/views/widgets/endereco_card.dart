import 'package:flutter/material.dart';

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
    final displayCep = isListMode ? endereco!.cep : (cep ?? '');
    final displayLabel = isListMode ? (endereco!.label ?? 'Endereço') : 'Endereço';
    final displayPrincipal = isListMode ? isPrincipal : false;

    // 🔥 FALLBACK SEGURO PARA enderecoCompleto
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: displayPrincipal
            ? Theme.of(context).primaryColor.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: displayPrincipal
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: displayPrincipal ? 2 : 1,
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
                      displayPrincipal ? Icons.check_circle : Icons.location_on,
                      color: displayPrincipal ? Theme.of(context).primaryColor : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (displayPrincipal) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
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
              if (isListMode && onEdit != null && onDelete != null) ...[
                if (!displayPrincipal && onSetPrincipal != null)
                  TextButton(
                    onPressed: onSetPrincipal,
                    child: Text(
                      'Selecionar',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
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
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            displayCompleto,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}