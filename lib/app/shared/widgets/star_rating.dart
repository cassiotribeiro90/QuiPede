import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingUpdate;

  const StarRating({
    Key? key,
    required this.rating,
    this.starCount = 5,
    this.size = 32,
    this.interactive = false,
    this.onRatingUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final starIndex = index + 1;
        final starValue = rating - index;
        final starIcon = _getStarIcon(starValue);

        return GestureDetector(
          onTap: interactive && onRatingUpdate != null
              ? () => onRatingUpdate!(starIndex.toDouble())
              : null,
          child: Icon(
            starIcon,
            color: _getStarColor(starValue),
            size: size,
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(double starValue) {
    if (starValue >= 1) {
      return Icons.star;
    } else if (starValue >= 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(double starValue) {
    if (starValue >= 0.5) {
      return Colors.amber;
    }
    return Colors.grey.shade300;
  }
}
