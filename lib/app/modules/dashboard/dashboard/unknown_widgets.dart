import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED BACKGROUND PAINTER (Floating Orbs + Subtle Grid)
// ─────────────────────────────────────────────────────────────────────────────
class DashboardFloatingPainter extends CustomPainter {
  final Animation<double> animation;
  DashboardFloatingPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final paint = Paint()..style = PaintingStyle.fill;
    final positions = [
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.85, size.height * 0.75),
      Offset(size.width * 0.65, size.height * 0.15),
    ];
    final colors = [AppThemeData.neonPurple, AppThemeData.neonTeal, AppThemeData.neonBlue];

    for (int i = 0; i < 3; i++) {
      final alpha = 0.04 + (sin(t * pi + i) * 0.015).abs();
      paint.color = colors[i].withValues(alpha: alpha);
      canvas.drawCircle(
        positions[i] + Offset(sin(t * pi * 0.4 + i) * 25, cos(t * pi * 0.6 + i) * 15),
        size.width * 0.35,
        paint,
      );
    }

    final gridPaint = Paint()..color = AppThemeData.neonBlue.withValues(alpha: 0.015) ..strokeWidth = 0.5;
    const spacing = 60.0;
    for (double x = 0; x < size.width; x += spacing) canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    for (double y = 0; y < size.height; y += spacing) canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// STAGGERED FADE/SLIDE WRAPPER
// ─────────────────────────────────────────────────────────────────────────────
class StaggeredFadeSlide extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  const StaggeredFadeSlide({super.key, required this.child, required this.index, this.baseDelay = const Duration(milliseconds: 70)});

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide> {
  bool _isVisible = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.baseDelay * widget.index, () { if(mounted) setState(() => _isVisible = true); });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _isVisible ? Offset.zero : const Offset(0, 0.06),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLASSMORPHIC CARD WITH HOVER/TAP SCALE
// ─────────────────────────────────────────────────────────────────────────────
class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;
  const AnimatedGlassCard({
    super.key, required this.child, this.padding, this.borderColor, this.radius = 20, this.onTap
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150), lowerBound: 0.97, upperBound: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTapDown: (_) { _isPressed = true; _ctrl.reverse(); },
        onTapUp: (_) { _isPressed = false; _ctrl.forward(); },
        onTapCancel: () { _isPressed = false; _ctrl.forward(); },
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.scale(
            scale: _ctrl.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: (isDark ? AppThemeData.surfaceDeep : Colors.white).withOpacity(isDark ? 0.65 : 0.85),
                    borderRadius: BorderRadius.circular(widget.radius),
                    border: Border.all(color: widget.borderColor ?? (isDark ? AppThemeData.primary50 : AppThemeData.grey3).withOpacity(0.25), width: 1),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED METRIC CARD
// ─────────────────────────────────────────────────────────────────────────────
class AnimatedMetricCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;
  final VoidCallback? onTap;
  const AnimatedMetricCard({super.key, required this.label, required this.value, required this.icon, required this.accentColor, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StaggeredFadeSlide(
      index: 2,
      child: AnimatedGlassCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                  ),
                  child: Icon(icon, size: 22, color: accentColor),
                ),
                const Spacer(),
                if (subtitle != null)
                  TextCustom(title: subtitle!, fontSize: 11, fontFamily: FontFamily.medium, color: accentColor.withValues(alpha: 0.8)),
              ],
            ),
            const Spacer(),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.toDouble()),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutQuart,
              builder: (_, v, __) => TextCustom(
                title: v >= 1000 ? '${(v/1000).toStringAsFixed(1)}K' : v.toInt().toString(),
                fontSize: 26,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ),
            const SizedBox(height: 6),
            TextCustom(title: label, fontSize: 13, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey4 : AppThemeData.grey6),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTION CHIP
// ─────────────────────────────────────────────────────────────────────────────
class QuickActionChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const QuickActionChip({super.key, required this.label, required this.icon, required this.color, required this.onTap});

  @override
  State<QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<QuickActionChip> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: _isHovered ? LinearGradient(colors: [widget.color.withValues(alpha: 0.15), widget.color.withValues(alpha: 0.05)]) : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.color.withValues(alpha: _isHovered ? 0.5 : 0.15)),
          boxShadow: _isHovered ? [BoxShadow(color: widget.color.withValues(alpha: 0.2), blurRadius: 10)] : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 18, color: widget.color),
                spaceW(width: 8),
                TextCustom(title: widget.label, fontSize: 13, fontFamily: FontFamily.semiBold, color: widget.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}