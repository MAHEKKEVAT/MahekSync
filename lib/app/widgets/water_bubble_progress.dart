import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class WaterBubbleProgress extends StatefulWidget {
  final double progress;
  final double size;
  final Color? color;
  final Color backgroundColor;
  final String? label;
  final String? subLabel;
  final bool isExpiring;
  final int animationDuration;

  const WaterBubbleProgress({
    super.key,
    required this.progress,
    this.size = 120,
    this.color,
    this.backgroundColor = const Color(0xFF1C1F26),
    this.label,
    this.subLabel,
    this.isExpiring = false,
    this.animationDuration = 4,
  });

  @override
  State<WaterBubbleProgress> createState() => _WaterBubbleProgressState();
}

class _WaterBubbleProgressState extends State<WaterBubbleProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: widget.animationDuration),
      vsync: this,
    );
    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arcColor = widget.color ?? AppThemeData.primary50;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _DonutPainter(
            progress: _fillAnimation.value,
            color: arcColor,
            trackColor: widget.backgroundColor,
            isExpiring: widget.isExpiring,
          ),
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.label != null)
              Text(
                widget.label!,
                style: TextStyle(
                  fontSize: widget.size * 0.18,
                  fontWeight: FontWeight.w800,
                  fontFamily: FontFamily.bold,
                  color: arcColor,
                ),
              ),
            if (widget.subLabel != null)
              Text(
                widget.subLabel!,
                style: TextStyle(
                  fontSize: widget.size * 0.1,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.medium,
                  color: arcColor.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final bool isExpiring;

  _DonutPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.isExpiring,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.14;
    final innerRadius = radius - strokeWidth;

    // ─── Track Ring ───
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, innerRadius, trackPaint);

    // ─── Progress Arc ───
    if (progress > 0) {
      final sweepAngle = 2 * pi * progress;
      const startAngle = -pi / 2; // Start from top

      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );

      // ─── Subtle glow at arc tip ───
      if (progress > 0.05) {
        final tipAngle = startAngle + sweepAngle;
        final tipX = center.dx + innerRadius * cos(tipAngle);
        final tipY = center.dy + innerRadius * sin(tipAngle);

        final glowPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.4),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: Offset(tipX, tipY), radius: strokeWidth * 1.5));
        canvas.drawCircle(Offset(tipX, tipY), strokeWidth * 1.5, glowPaint);
      }
    }

    // ─── Expiring glow ring ───
    if (isExpiring) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppThemeData.danger300.withValues(alpha: 0.2),
            AppThemeData.danger300.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, glowPaint);
    }

    // ─── Percentage text in center ───
    final displayPercent = (progress * 100).toInt();
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$displayPercent%',
        style: TextStyle(
          fontSize: innerRadius * 0.35,
          fontWeight: FontWeight.w800,
          fontFamily: FontFamily.bold,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isExpiring != isExpiring;
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
