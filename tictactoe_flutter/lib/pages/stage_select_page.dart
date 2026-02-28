import 'package:flutter/material.dart';
import '../theme.dart';
import '../progress.dart';

class StageSelectPage extends StatefulWidget {
  final String difficulty;
  final VoidCallback onBack;
  final void Function(int stageIndex) onSelectStage;

  const StageSelectPage({
    super.key,
    required this.difficulty,
    required this.onBack,
    required this.onSelectStage,
  });

  @override
  State<StageSelectPage> createState() => _StageSelectPageState();
}

class _StageSelectPageState extends State<StageSelectPage> {
  Map<String, dynamic>? _progress;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await getProgress();
    if (mounted) setState(() => _progress = p);
  }

  @override
  Widget build(BuildContext context) {
    final stages =
        _progress == null
            ? List.generate(15, (_) => {'done': false, 'stars': 0})
            : List<Map<String, dynamic>>.from(
              (_progress![widget.difficulty]['stages'] as List).map(
                (e) => Map<String, dynamic>.from(e as Map),
              ),
            );

    final firstIncomplete = stages.indexWhere((s) => s['done'] != true);
    final currentIdx = firstIncomplete == -1 ? 14 : firstIncomplete;

    final diffLabel =
        {
          'easy': '🌱 Easy',
          'normal': '⚔️ Normal',
          'impossible': '💀 Impossible',
        }[widget.difficulty]!;

    return AppPage(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButton2(onTap: widget.onBack),
            const SizedBox(height: 16),
            Text(diffLabel, style: AppTextStyles.title),
            const SizedBox(height: 6),
            const Text('Select a stage to play', style: AppTextStyles.subtitle),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: 15,
                itemBuilder: (ctx, i) {
                  final s = stages[i];
                  final done = s['done'] == true;
                  final locked = i > currentIdx && !done;
                  final isCurrent = i == currentIdx && !done;
                  final stars = (s['stars'] as int?) ?? 0;

                  return GestureDetector(
                    onTap: locked ? null : () => widget.onSelectStage(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color:
                            done
                                ? AppColors.greenDark
                                : isCurrent
                                ? AppColors.primaryGlow
                                : AppColors.surface2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              done
                                  ? AppColors.green
                                  : isCurrent
                                  ? AppColors.primary
                                  : AppColors.border,
                          width: isCurrent ? 2 : 1,
                        ),
                        boxShadow:
                            isCurrent
                                ? [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(80),
                                    blurRadius: 12,
                                  ),
                                ]
                                : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (locked)
                            const Text('🔒', style: TextStyle(fontSize: 14))
                          else
                            Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color:
                                    done
                                        ? AppColors.green
                                        : isCurrent
                                        ? AppColors.primary
                                        : Colors.white,
                              ),
                            ),
                          if (done) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${'⭐' * stars}${'☆' * (3 - stars)}',
                              style: const TextStyle(fontSize: 9),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
