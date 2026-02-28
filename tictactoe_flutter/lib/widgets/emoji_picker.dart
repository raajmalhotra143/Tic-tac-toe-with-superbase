// Emoji picker widget — mirrors React EmojiPicker.jsx
import 'package:flutter/material.dart';
import '../theme.dart';

const emojis = [
  '🦊',
  '🐼',
  '🦁',
  '🐸',
  '🐯',
  '🐺',
  '🦄',
  '🐲',
  '👾',
  '🤖',
  '🦅',
  '🐙',
  '👻',
  '💀',
  '🎃',
  '⚡',
  '🔥',
  '❄️',
  '🌊',
  '💎',
];

class EmojiPicker extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const EmojiPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: emojis.length,
      itemBuilder: (ctx, i) {
        final e = emojis[i];
        final isSel = e == selected;
        return GestureDetector(
          onTap: () => onSelect(e),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSel ? AppColors.primary : AppColors.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSel ? AppColors.primaryLight : AppColors.border,
                width: isSel ? 2 : 1,
              ),
              boxShadow:
                  isSel
                      ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(100),
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ]
                      : null,
            ),
            child: Center(child: Text(e, style: const TextStyle(fontSize: 26))),
          ),
        );
      },
    );
  }
}
