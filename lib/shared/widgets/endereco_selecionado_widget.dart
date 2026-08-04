import 'package:flutter/material.dart';
import '../../app/core/theme/app_text_styles.dart'; // 🔥 IMPORT CORRETO
import '../../app/modules/enderecos/models/endereco_model.dart';

class EnderecoSelecionadoWidget extends StatelessWidget {
  final EnderecoModel? endereco;
  final VoidCallback? onTap;

  const EnderecoSelecionadoWidget({
    super.key,
    this.endereco,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF57C00);
    final isEnderecoDefinido = endereco != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnderecoDefinido ? Colors.orange.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnderecoDefinido ? Colors.orange.shade200 : Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isEnderecoDefinido ? Icons.home_rounded : Icons.location_off_rounded,
              color: isEnderecoDefinido ? primaryColor : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnderecoDefinido
                        ? endereco!.resumido
                        : 'Nenhum endereço definido',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isEnderecoDefinido ? Colors.black87 : Colors.red.shade700,
                    ),
                  ),
                  if (isEnderecoDefinido)
                    Text(
                      'Toque para alterar',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.edit_outlined,
                size: 20, color: isEnderecoDefinido ? primaryColor : Colors.red),
          ],
        ),
      ),
    );
  }
}