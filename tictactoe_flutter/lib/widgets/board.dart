// Board widget — mirrors React Board.jsx
import 'package:flutter/material.dart';
import '../theme.dart';
import '../game_logic.dart';

class Board extends StatelessWidget {
  final List<String?> board;
  final void Function(int) onCellClick;
  final String playerEmoji;
  final String aiEmoji;
  final bool disabled;

  const Board({
    super.key,
    required this.board,
    required this.onCellClick,
    required this.playerEmoji,
    required this.aiEmoji,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final winLine = getWinLine(board);

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (ctx, i) {
          final val = board[i];
          final isWinner = winLine.contains(i);
          final isPlayer = val == 'X';
          final taken = val != null;

          return GestureDetector(
            onTap: disabled || taken ? null : () => onCellClick(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color:
                    isWinner
                        ? (isPlayer
                            ? AppColors.primary.withAlpha(60)
                            : AppColors.pink.withAlpha(60))
                        : AppColors.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isWinner
                          ? (isPlayer ? AppColors.primary : AppColors.pink)
                          : taken
                          ? (isPlayer ? AppColors.primaryLight : AppColors.pink)
                          : AppColors.border,
                  width: isWinner ? 2.5 : 1.5,
                ),
                boxShadow:
                    isWinner
                        ? [
                          BoxShadow(
                            color: (isPlayer
                                    ? AppColors.primary
                                    : AppColors.pink)
                                .withAlpha(100),
                            blurRadius: 20,
                          ),
                        ]
                        : null,
              ),
              child: Center(
                child: AnimatedScale(
                  scale: taken ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.elasticOut,
                  child:
                      taken
                          ? Text(
                            isPlayer ? playerEmoji : aiEmoji,
                            style: const TextStyle(fontSize: 36),
                          )
                          : const SizedBox(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
