// lib/app/modules/pedidos/widgets/avaliacao_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/models/avaliacao_model.dart';
import 'package:quipede/app/core/theme/app_colors.dart';
import 'package:quipede/app/modules/pedido/widgets/star_rating.dart';
import '../bloc/pedido_cubit.dart';

enum TipoAvaliacao { pedido, produto }

class AvaliacaoBottomSheet extends StatefulWidget {
  final int pedidoId;
  final int? produtoId;
  final int? lojaId;
  final TipoAvaliacao tipo;
  final AvaliacaoModel? avaliacaoExistente;
  final VoidCallback? onSuccess;
  final String? lojaNome;
  final String? produtoNome;

  const AvaliacaoBottomSheet({
    super.key,
    required this.pedidoId,
    this.produtoId,
    this.lojaId,
    required this.tipo,
    this.avaliacaoExistente,
    this.onSuccess,
    this.lojaNome,
    this.produtoNome,
  });

  @override
  State<AvaliacaoBottomSheet> createState() => _AvaliacaoBottomSheetState();
}

class _AvaliacaoBottomSheetState extends State<AvaliacaoBottomSheet> {
  int _nota = 0;
  bool _isSaving = false;
  final TextEditingController _comentarioController = TextEditingController();

  bool get _isEdicao =>
      widget.avaliacaoExistente != null &&
          widget.avaliacaoExistente!.status == 'pendente';

  bool get _isAprovada =>
      widget.avaliacaoExistente != null &&
          widget.avaliacaoExistente!.status == 'aprovado';

  @override
  void initState() {
    super.initState();
    if (widget.avaliacaoExistente != null) {
      _nota = widget.avaliacaoExistente!.nota;
      _comentarioController.text = widget.avaliacaoExistente!.comentario ?? '';
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  // Título: apenas o nome (sem prefixo)
  String get _titulo {
    if (widget.tipo == TipoAvaliacao.pedido) {
      return widget.lojaNome ?? 'Loja';
    } else {
      return widget.produtoNome ?? 'Produto';
    }
  }

  Future<void> _enviar() async {
    if (_nota == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma nota de 1 a 5')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final cubit = context.read<PedidoCubit>();

    try {
      if (_isEdicao) {
        await cubit.editarAvaliacao(
          avaliacaoId: widget.avaliacaoExistente!.id,
          nota: _nota,
          comentario: _comentarioController.text.trim().isEmpty
              ? null
              : _comentarioController.text.trim(),
        );
      } else {
        await cubit.enviarAvaliacao(
          pedidoId: widget.pedidoId,
          produtoId: widget.produtoId,
          lojaId: widget.lojaId,
          nota: _nota,
          comentario: _comentarioController.text.trim().isEmpty
              ? null
              : _comentarioController.text.trim(),
        );
      }

      if (mounted) {
        widget.onSuccess?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  Future<void> _excluir() async {
    if (widget.avaliacaoExistente == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir avaliação?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _isSaving = true);
      try {
        await context
            .read<PedidoCubit>()
            .excluirAvaliacao(widget.avaliacaoExistente!.id);
        if (mounted) {
          widget.onSuccess?.call();
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com título (apenas nome) e lixeira
            Row(
              children: [
                Expanded(
                  child: Text(
                    _titulo,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // 🔥 Exibe lixeira para qualquer avaliação existente (inclusive aprovada)
                if (widget.avaliacaoExistente != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Excluir avaliação',
                    onPressed: _isSaving ? null : _excluir,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (widget.avaliacaoExistente != null)
              Text(
                widget.avaliacaoExistente!.status == 'pendente'
                    ? 'Sua avaliação está pendente. Você pode editá-la.'
                    : 'Sua avaliação já foi aprovada.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _isAprovada ? Colors.green : colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),

            Center(
              child: StarRating(
                nota: _nota,
                onChanged: _isAprovada || _isSaving
                    ? null
                    : (value) {
                  setState(() => _nota = value);
                },
                size: 48,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              _nota == 0
                  ? 'Toque nas estrelas para avaliar'
                  : _nota == 1
                  ? 'Muito ruim'
                  : _nota == 2
                  ? 'Ruim'
                  : _nota == 3
                  ? 'Regular'
                  : _nota == 4
                  ? 'Bom'
                  : 'Excelente!',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _comentarioController,
              minLines: 3,
              maxLines: 5,
              enabled: !_isAprovada && !_isSaving,
              decoration: InputDecoration(
                labelText: 'Comentário (opcional)',
                alignLabelWithHint: true,
                hintText: 'Conte-nos sua experiência...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isSaving ? null : _enviar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(_isEdicao ? 'Salvar Alterações' : 'Enviar Avaliação'),
            ),
          ],
        ),
      ),
    );
  }
}