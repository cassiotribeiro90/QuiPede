import 'package:flutter/material.dart';
import 'package:quipede/app/models/avaliacao_model.dart';
import 'package:quipede/app/shared/widgets/star_rating.dart';

class AvaliacaoCard extends StatelessWidget {
  final AvaliacaoModel avaliacao;
  final VoidCallback? onResponder;
  final VoidCallback? onAprovar;
  final VoidCallback? onRejeitar;
  final VoidCallback? onCurtir;
  final bool showActions;

  const AvaliacaoCard({
    Key? key,
    required this.avaliacao,
    this.onResponder,
    this.onAprovar,
    this.onRejeitar,
    this.onCurtir,
    this.showActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            _buildHeader(context),
            const SizedBox(height: 12),
            
            // Estrelas
            StarRating(rating: avaliacao.nota.toDouble(), size: 24),
            const SizedBox(height: 8),
            
            // Comentário
            if (avaliacao.comentario != null && avaliacao.comentario!.isNotEmpty)
              Text(
                avaliacao.comentario!,
                style: const TextStyle(fontSize: 14),
              ),
            
            // Resposta da loja
            if (avaliacao.hasResposta) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resposta da loja:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(avaliacao.resposta!),
                    if (avaliacao.respostaEm != null)
                      Text(
                        'Respondido em: ${avaliacao.dataFormatada}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
            
            // Ações
            if (showActions) ...[
              const SizedBox(height: 12),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          child: Text(
            (avaliacao.usuarioNome ?? 'U')[0].toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                avaliacao.usuarioNome ?? 'Usuário',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                avaliacao.tipoLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                avaliacao.statusLabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              avaliacao.dataFormatada,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Botão Curtir
        if (onCurtir != null)
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: Colors.red.shade300,
              size: 20,
            ),
            onPressed: onCurtir,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        
        if (onCurtir != null) ...[
          const SizedBox(width: 4),
          Text(
            '${avaliacao.curtidas}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(width: 16),
        ],
        
        // Botão Responder (lojista)
        if (onResponder != null && !avaliacao.hasResposta)
          TextButton(
            onPressed: onResponder,
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 30),
            ),
            child: const Text('Responder'),
          ),
        
        // Botões Aprovar/Rejeitar (lojista)
        if (onAprovar != null && avaliacao.isPendente)
          TextButton(
            onPressed: onAprovar,
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 30),
            ),
            child: const Text('Aprovar'),
          ),
        
        if (onRejeitar != null && avaliacao.isPendente)
          TextButton(
            onPressed: onRejeitar,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 30),
            ),
            child: const Text('Rejeitar'),
          ),
      ],
    );
  }

  Color _getStatusColor() {
    if (avaliacao.isAprovado) return Colors.green;
    if (avaliacao.isPendente) return Colors.orange;
    return Colors.red;
  }
}
