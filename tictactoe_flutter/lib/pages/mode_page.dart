import 'package:flutter/material.dart';
import '../theme.dart';

class ModePage extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(String mode) onSelectMode;

  const ModePage({super.key, required this.onBack, required this.onSelectMode});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButton2(onTap: onBack),
            const SizedBox(height: 16),
            const Text('Choose Mode', style: AppTextStyles.title),
            const SizedBox(height: 6),
            const Text(
              'How do you want to play?',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 32),
            // Mode cards
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ModeCard(
                    icon: '🤖',
                    title: 'Offline',
                    desc: '3 difficulty levels, 15 stages each',
                    gradient: const [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                    onTap: () => onSelectMode('offline'),
                  ),
                  const SizedBox(height: 16),
                  _ModeCard(
                    icon: '🌐',
                    title: 'Online',
                    desc: 'Real-time multiplayer',
                    gradient: const [Color(0xFF0891B2), Color(0xFF06B6D4)],
                    onTap: () => onSelectMode('online'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  final String icon;
  final String title;
  final String desc;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withAlpha(80),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.desc,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
