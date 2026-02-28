import 'package:flutter/material.dart';
import '../theme.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback onPlay;
  const WelcomePage({super.key, required this.onPlay});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: 0,
      end: -16,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      {'icon': '🤖', 'label': '15-Stage AI'},
      {'icon': '🌐', 'label': 'Realtime Multiplayer'},
      {'icon': '⭐', 'label': 'Star Ratings'},
    ];

    return AppPage(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating emoji
            AnimatedBuilder(
              animation: _float,
              builder:
                  (c, _) => Transform.translate(
                    offset: Offset(0, _float.value),
                    child: const Text('🎮', style: TextStyle(fontSize: 72)),
                  ),
            ),
            const SizedBox(height: 12),
            // Logo
            ShaderMask(
              shaderCallback:
                  (bounds) => const LinearGradient(
                    colors: [AppColors.primary, AppColors.cyan],
                  ).createShader(bounds),
              child: const Text(
                'TIC·TAC·TOE',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Battle smarter. Play bolder. Win legendary.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Play Button
            GlowButton(
              text: '▶  Play Now',
              onTap: widget.onPlay,
              large: true,
              block: true,
            ),
            const SizedBox(height: 48),
            // Features row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  features
                      .map(
                        (f) => Column(
                          children: [
                            Text(
                              f['icon']!,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              f['label']!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
