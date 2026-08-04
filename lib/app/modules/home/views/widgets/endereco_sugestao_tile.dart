import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/endereco_sugestao.dart';

class EnderecoSugestaoTile extends StatelessWidget {
  final EnderecoSugestao endereco;
  final VoidCallback onTap;

  const EnderecoSugestaoTile({
    super.key,
    required this.endereco,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 22, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      endereco.descricao,
                      style: AppTextStyles.bodyMedium.copyWith( // 18px
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}