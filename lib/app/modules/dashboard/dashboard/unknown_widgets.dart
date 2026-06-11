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
    for (double x = 0; x < size.width; x += spacing) { canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint); }
    for (double y = 0; y < size.height; y += spacing) { canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint); }
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
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Transform.scale(
            scale: _ctrl.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: (isDark ? AppThemeData.surfaceDeep : Colors.white).withValues(alpha: isDark ? 0.65 : 0.85),
                    borderRadius: BorderRadius.circular(widget.radius),
                    border: Border.all(color: widget.borderColor ?? (isDark ? AppThemeData.primary50 : AppThemeData.grey3).withValues(alpha: 0.25), width: 1),
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
        onTap: onTap,child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutQuart,
            builder: (_, v, _) => TextCustom(
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

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.icon, this.iconColor, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: (iconColor ?? AppThemeData.primary50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: iconColor ?? AppThemeData.primary50),
          ),
          spaceW(width: 10),
        ],
        TextCustom(title: title, fontSize: 17, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHART LEGEND
// ─────────────────────────────────────────────────────────────────────────────
class ChartLegend extends StatelessWidget {
  final List<LegendEntry> entries;
  const ChartLegend({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: entries.map((e) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: e.color, shape: BoxShape.circle)),
          spaceW(width: 5),
          TextCustom(title: e.label, fontSize: 11, fontFamily: FontFamily.medium, color: e.color.withValues(alpha: 0.85)),
        ],
      )).toList(),
    );
  }
}

class LegendEntry {
  final String label;
  final Color color;
  const LegendEntry(this.label, this.color);
}

// ─────────────────────────────────────────────────────────────────────────────
// INSIGHT CARD
// ─────────────────────────────────────────────────────────────────────────────
class InsightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String actionLabel;
  final VoidCallback? onTap;
  final Widget? trailing;
  const InsightCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    this.actionLabel = 'View',
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          spaceW(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(title: title, fontSize: 13, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                spaceH(height: 2),
                TextCustom(title: description, fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6, maxLine: 1),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: TextCustom(title: actionLabel, fontSize: 11, fontFamily: FontFamily.semiBold, color: accentColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionChipState extends State<QuickActionChip> {
  bool _isHovered = false;

  void _onHover(bool v) {
    if (_isHovered == v) return;
    _isHovered = v;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
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