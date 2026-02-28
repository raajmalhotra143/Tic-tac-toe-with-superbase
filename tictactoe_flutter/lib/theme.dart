import 'package:flutter/material.dart';

// ── Design tokens (mirrors React index.css CSS variables) ──────────────────
class AppColors {
  static const bg = Color(0xFF0B0B0F);
  static const surface = Color(0xFF141420);
  static const surface2 = Color(0xFF1C1C2E);
  static const border = Color(0xFF2A2A40);

  static const primary = Color(0xFF7C3AED);
  static const primaryGlow = Color(0x557C3AED);
  static const primaryLight = Color(0xFF9B59F6);

  static const cyan = Color(0xFF06B6D4);
  static const cyanGlow = Color(0x4406B6D4);

  static const pink = Color(0xFFEC4899);
  static const pinkGlow = Color(0x44EC4899);

  static const gold = Color(0xFFF59E0B);
  static const goldGlow = Color(0x44F59E0B);

  static const green = Color(0xFF10B981);
  static const greenDark = Color(0xFF113020);

  static const red = Color(0xFFEF4444);
  static const redDark = Color(0xFF2A1010);

  static const muted = Color(0xFF6B7280);
  static const text = Color(0xFFE2E8F0);
  static const textDim = Color(0xFFCBD5E1);
}

class AppTextStyles {
  static TextStyle logo(BuildContext context) => const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    letterSpacing: 4,
    color: Colors.white,
  );

  static const title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const subtitle = TextStyle(
    fontSize: 14,
    color: AppColors.muted,
    fontWeight: FontWeight.w500,
  );

  static const label = TextStyle(
    fontSize: 12,
    color: AppColors.muted,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}

// ── Reusable styled widgets ────────────────────────────────────────────────

class AppPage extends StatelessWidget {
  final Widget child;
  const AppPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlowButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Color color;
  final bool large;
  final bool block;
  final bool ghost;

  const GlowButton({
    super.key,
    required this.text,
    this.onTap,
    this.color = AppColors.primary,
    this.large = false,
    this.block = false,
    this.ghost = false,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
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
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double h = widget.large ? 56 : 48;
    final double fs = widget.large ? 16 : 14;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: widget.block ? double.infinity : null,
          height: h,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: widget.ghost ? Colors.transparent : widget.color,
            borderRadius: BorderRadius.circular(50),
            border:
                widget.ghost
                    ? Border.all(color: AppColors.border, width: 1.5)
                    : null,
            boxShadow:
                widget.ghost
                    ? null
                    : [
                      BoxShadow(
                        color: widget.color.withAlpha(80),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: fs,
              fontWeight: FontWeight.w700,
              color: widget.ghost ? AppColors.textDim : Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class GlowCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final EdgeInsetsGeometry? padding;

  const GlowCard({
    super.key,
    required this.child,
    this.glowColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow:
            glowColor != null
                ? [
                  BoxShadow(
                    color: glowColor!.withAlpha(60),
                    blurRadius: 32,
                    spreadRadius: 0,
                  ),
                ]
                : null,
      ),
      child: child,
    );
  }
}

class BackButton2 extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const BackButton2({super.key, required this.onTap, this.label = '← Back'});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 14,
          color: AppColors.muted,
        ),
        label: Text(
          label.replaceFirst('← ', ''),
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }
}
