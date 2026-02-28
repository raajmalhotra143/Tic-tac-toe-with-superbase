// Result overlay — mirrors React ResultOverlay.jsx
import 'package:flutter/material.dart';
import '../theme.dart';
import 'star_rating.dart';

class ResultOverlay extends StatelessWidget {
  final String result; // 'win' | 'draw' | 'loss'
  final int stars;
  final int moves;
  final String playerEmoji;
  final String aiEmoji;
  final bool isLastStage;
  final VoidCallback onNextStage;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const ResultOverlay({
    super.key,
    required this.result,
    required this.stars,
    required this.moves,
    required this.playerEmoji,
    required this.aiEmoji,
    required this.isLastStage,
    required this.onNextStage,
    required this.onReplay,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final isWin = result == 'win';
    final isDraw = result == 'draw';
    final emoji =
        isWin
            ? '🏆'
            : isDraw
            ? '🤝'
            : '💀';
    final title =
        isWin
            ? 'You Won!'
            : isDraw
            ? "It's a Draw!"
            : 'You Lost!';
    final subtitle =
        isWin
            ? 'Finished in $moves move${moves != 1 ? 's' : ''}'
            : isDraw
            ? 'No winner this time'
            : 'Better luck next stage!';
    final titleColor =
        isWin
            ? AppColors.gold
            : isDraw
            ? AppColors.cyan
            : AppColors.pink;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder:
          (ctx, val, child) => Opacity(
            opacity: val,
            child: Transform.scale(scale: 0.85 + 0.15 * val, child: child),
          ),
      child: Container(
        color: Colors.black.withAlpha(160),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: titleColor.withAlpha(120), width: 2),
              boxShadow: [
                BoxShadow(
                  color: titleColor.withAlpha(80),
                  blurRadius: 40,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: AppColors.muted)),
                if (isWin) ...[
                  const SizedBox(height: 16),
                  StarRating(stars: stars),
                ],
                const SizedBox(height: 24),
                // Action buttons
                Column(
                  children: [
                    if (isWin && !isLastStage) ...[
                      GlowButton(
                        text: 'Next Stage →',
                        onTap: onNextStage,
                        block: true,
                      ),
                      const SizedBox(height: 10),
                    ],
                    GlowButton(
                      text: '↩ Replay',
                      onTap: onReplay,
                      ghost: true,
                      block: true,
                    ),
                    const SizedBox(height: 10),
                    GlowButton(
                      text: '🏠 Menu',
                      onTap: onHome,
                      ghost: true,
                      block: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
