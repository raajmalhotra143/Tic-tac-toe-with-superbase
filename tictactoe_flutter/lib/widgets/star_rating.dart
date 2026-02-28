// Star rating widget — mirrors React StarRating.jsx
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int stars;
  const StarRating({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.5, end: filled ? 1.0 : 0.5),
          duration: Duration(milliseconds: 300 + i * 100),
          builder:
              (ctx, val, _) => Transform.scale(
                scale: val,
                child: Text(
                  filled ? '⭐' : '☆',
                  style: TextStyle(
                    fontSize: 32,
                    color: filled ? null : Colors.white24,
                  ),
                ),
              ),
        );
      }),
    );
  }
}
