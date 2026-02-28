import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/emoji_picker.dart';

class EmojiSelectPage extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String playerEmoji, String aiEmoji) onConfirm;

  const EmojiSelectPage({
    super.key,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  State<EmojiSelectPage> createState() => _EmojiSelectPageState();
}

class _EmojiSelectPageState extends State<EmojiSelectPage> {
  String _selected = '🦊';
  static const _aiEmoji = '🤖';

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButton2(onTap: widget.onBack),
            const SizedBox(height: 16),
            const Text('Choose Your Emoji', style: AppTextStyles.title),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('Your emoji vs AI: ', style: AppTextStyles.subtitle),
                Text(_aiEmoji, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    EmojiPicker(
                      selected: _selected,
                      onSelect: (e) => setState(() => _selected = e),
                    ),
                    const SizedBox(height: 32),
                    GlowButton(
                      text: 'Confirm & Play',
                      large: true,
                      block: true,
                      onTap: () => widget.onConfirm(_selected, _aiEmoji),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
