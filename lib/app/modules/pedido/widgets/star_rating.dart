// lib/app/modules/avaliacao/widgets/star_rating.dart

import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int nota;
  final ValueChanged<int>? onChanged;
  final double size;
  final bool interactive;

  const StarRating({
    super.key,
    required this.nota,
    this.onChanged,
    this.size = 40,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: interactive
          ? (details) {
        final width = size * 5;
        final dx = details.localPosition.dx;
        if (dx >= 0 && dx <= width) {
          final novaNota = (dx / size).ceil().clamp(1, 5);
          onChanged?.call(novaNota);
        }
      }
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final star = index + 1;
          return GestureDetector(
            onTap: interactive ? () => onChanged?.call(star) : null,
            child: Icon(
              star <= nota ? Icons.star_rounded : Icons.star_border_rounded,
              color: star <= nota ? Colors.amber : Colors.grey[400],
              size: size,
            ),
          );
        }),
      ),
    );
  }
}