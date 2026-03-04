import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final bool showCount;

  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.starSize = 16,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final filled = index < rating.floor();
          final half = !filled && index < rating;
          return Icon(
            half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
            color: AppTheme.starColor,
            size: starSize,
          );
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: starSize * 0.85,
            fontWeight: FontWeight.bold,
            color: AppTheme.starColor,
          ),
        ),
        if (showCount && reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: starSize * 0.75,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}
