import 'package:flutter/material.dart';
import '../theme.dart';
import '../progress.dart';

const _levels = [
  {
    'key': 'easy',
    'label': 'Easy',
    'icon': '🌱',
    'desc': 'Beginner friendly AI',
    'color': Color(0xFF10B981),
  },
  {
    'key': 'normal',
    'label': 'Normal',
    'icon': '⚔️',
    'desc': 'Smart AI, a real challenge',
    'color': Color(0xFFF59E0B),
  },
  {
    'key': 'impossible',
    'label': 'Impossible',
    'icon': '💀',
    'desc': 'Unbeatable at stage 15',
    'color': Color(0xFFEF4444),
  },
];

class LevelSelectPage extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String level) onSelectLevel;

  const LevelSelectPage({
    super.key,
    required this.onBack,
    required this.onSelectLevel,
  });

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends State<LevelSelectPage> {
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
    final levelKeys = ['easy', 'normal', 'impossible'];
    final unlockedIdx =
        _progress == null
            ? 0
            : levelKeys.indexOf(_progress!['unlockedLevel'] as String);

    return AppPage(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButton2(onTap: widget.onBack),
            const SizedBox(height: 16),
            const Text('Select Level', style: AppTextStyles.title),
            const SizedBox(height: 6),
            const Text(
              'Complete all 15 stages to unlock next level',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    _levels.asMap().entries.map((entry) {
                      final lv = entry.value;
                      final lvIdx = levelKeys.indexOf(lv['key'] as String);
                      final locked = lvIdx > unlockedIdx;
                      final stages =
                          _progress == null
                              ? <dynamic>[]
                              : List.from(
                                _progress![lv['key']]['stages'] as List,
                              );
                      final done =
                          stages
                              .where((s) => (s as Map)['done'] == true)
                              .length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _LevelCard(
                          icon: lv['icon'] as String,
                          label: lv['label'] as String,
                          desc: lv['desc'] as String,
                          color: lv['color'] as Color,
                          locked: locked,
                          done: done,
                          onTap:
                              locked
                                  ? null
                                  : () =>
                                      widget.onSelectLevel(lv['key'] as String),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String icon;
  final String label;
  final String desc;
  final Color color;
  final bool locked;
  final int done;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.locked,
    required this.done,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: locked ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: locked ? AppColors.border : color.withAlpha(180),
            ),
            boxShadow:
                locked
                    ? null
                    : [
                      BoxShadow(
                        color: color.withAlpha(40),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            if (locked) ...[
                              const SizedBox(width: 8),
                              const Text('🔒', style: TextStyle(fontSize: 14)),
                            ],
                          ],
                        ),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$done/15',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: done / 15,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
