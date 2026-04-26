import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import '../utils/app_colors.dart';
import '../utils/font_family.dart';

/// Premium customizable loader with multiple animation styles
class MahekLoader extends StatefulWidget {
  final String message;
  final double size;
  final double textSize;
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;
  final bool showBackgroundOverlay;
  final Color? overlayColor;
  final MahekLoaderStyle style;
  final Widget? customWidget;

  const MahekLoader({
    super.key,
    this.message = 'Please Wait...',
    this.size = 60.0,
    this.textSize = 15,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 3.0,
    this.showBackgroundOverlay = false,
    this.overlayColor,
    this.style = MahekLoaderStyle.arc,
    this.customWidget,
  });

  @override
  State<MahekLoader> createState() => _MahekLoaderState();
}

enum MahekLoaderStyle {
  arc, // Spinning arc with trail
  pulse, // Pulsing circle
  wave, // Bouncing dots wave
  ring, // Rotating ring
  dualRing, // Two rings spinning opposite
  shimmer, // Horizontal shimmer bar
}

class _MahekLoaderState extends State<MahekLoader>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  AnimationController? _secondController;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    if (widget.style == MahekLoaderStyle.dualRing) {
      _secondController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      )..repeat(reverse: true);
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _secondController?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loaderColor = widget.color ?? AppThemeData.primary50;
    final trackColor =
        widget.backgroundColor ??
        (isDark ? AppThemeData.grey8 : AppThemeData.grey3);

    Widget loaderContent = FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: widget.size,
              width: widget.size,
              child: _buildLoaderByStyle(loaderColor, trackColor),
            ),
            spaceH(height: 18),
            TextCustom(
              title: widget.message.tr,
              fontSize: widget.textSize,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    if (widget.showBackgroundOverlay) {
      return Container(
        color: widget.overlayColor ?? Colors.black54,
        child: loaderContent,
      );
    }

    return loaderContent;
  }

  Widget _buildLoaderByStyle(Color color, Color trackColor) {
    switch (widget.style) {
      case MahekLoaderStyle.arc:
        return _buildArcLoader(color, trackColor);
      case MahekLoaderStyle.pulse:
        return _buildPulseLoader(color);
      case MahekLoaderStyle.wave:
        return _buildWaveLoader(color);
      case MahekLoaderStyle.ring:
        return _buildRingLoader(color, trackColor);
      case MahekLoaderStyle.dualRing:
        return _buildDualRingLoader(color, trackColor);
      case MahekLoaderStyle.shimmer:
        return _buildShimmerLoader(color);
    }
  }

  // ═══════════════════════════════════
  // ARC LOADER (Original enhanced)
  // ═══════════════════════════════════
  Widget _buildArcLoader(Color color, Color trackColor) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _ArcPainter(
            progress: _mainController.value,
            color: color,
            trackColor: trackColor,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════
  // PULSE LOADER
  // ═══════════════════════════════════
  Widget _buildPulseLoader(Color color) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        final pulseValue =
            (math.sin(_mainController.value * 2 * math.pi) + 1) / 2;
        return Center(
          child: Container(
            width: widget.size * (0.5 + pulseValue * 0.5),
            height: widget.size * (0.5 + pulseValue * 0.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.8),
                  color.withValues(alpha: 0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════
  // WAVE LOADER (Bouncing dots)
  // ═══════════════════════════════════
  Widget _buildWaveLoader(Color color) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(4, (index) {
            final delay = index * 0.15;
            final bounceValue =
                (math.sin(
                      (_mainController.value * 2 * math.pi) -
                          (delay * 2 * math.pi),
                    ) +
                    1) /
                2;
            return Container(
              width: widget.size * 0.15,
              height: widget.size * 0.15 + (bounceValue * widget.size * 0.45),
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.04),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.1),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color, color.withValues(alpha: 0.5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: Offset(0, bounceValue * 4),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  // ═══════════════════════════════════
  // RING LOADER
  // ═══════════════════════════════════
  Widget _buildRingLoader(Color color, Color trackColor) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RingPainter(
            progress: _mainController.value,
            color: color,
            trackColor: trackColor,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════
  // DUAL RING LOADER
  // ═══════════════════════════════════
  Widget _buildDualRingLoader(Color color, Color trackColor) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _DualRingPainter(
            progress1: _mainController.value,
            progress2: _secondController?.value ?? 0,
            color: color,
            trackColor: trackColor,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════
  // SHIMMER LOADER
  // ═══════════════════════════════════
  Widget _buildShimmerLoader(Color color) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        return Container(
          height: 6,
          width: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                color.withValues(alpha: 0.05),
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.5),
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.05),
              ],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              transform: _SlidingGradient(_mainController.value),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════
// SLIDING GRADIENT FOR SHIMMER
// ═══════════════════════════════════════════
class _SlidingGradient extends GradientTransform {
  final double value;

  const _SlidingGradient(this.value);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (value - 0.5) * 2, 0, 0);
  }
}

// ═══════════════════════════════════════════
// ARC PAINTER (Original - enhanced)
// ═══════════════════════════════════════════
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _ArcPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Spinning arc with sweep gradient
    final sweepAngle = math.pi * 0.8;
    final startAngle = (progress * 2 * math.pi) - (math.pi / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: [color.withOpacity(0.0), color.withOpacity(0.4), color],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(startAngle),
    );

    final arcPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

    // Bright dot at leading edge
    final dotAngle = startAngle + sweepAngle;
    final dotCenter = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotCenter, strokeWidth * 0.7, dotPaint);

    // Small dot at trailing edge
    final trailDot = Offset(
      center.dx + radius * math.cos(startAngle),
      center.dy + radius * math.sin(startAngle),
    );
    canvas.drawCircle(
      trailDot,
      strokeWidth * 0.3,
      Paint()..color = color.withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ═══════════════════════════════════════════
// RING PAINTER
// ═══════════════════════════════════════════
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, progress * 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ═══════════════════════════════════════════
// DUAL RING PAINTER
// ═══════════════════════════════════════════
class _DualRingPainter extends CustomPainter {
  final double progress1;
  final double progress2;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _DualRingPainter({
    required this.progress1,
    required this.progress2,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width - strokeWidth) / 2;
    final innerRadius = outerRadius * 0.65;

    // Outer track + arc
    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    canvas.drawArc(
      outerRect,
      -math.pi / 2 + progress1 * 2 * math.pi,
      math.pi,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Inner track + arc (opposite direction)
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.7,
    );
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    canvas.drawArc(
      innerRect,
      -math.pi / 2 - progress2 * 2 * math.pi,
      math.pi,
      false,
      Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DualRingPainter oldDelegate) =>
      oldDelegate.progress1 != progress1 || oldDelegate.progress2 != progress2;
}

// Simple AnimatedBuilder
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
  Widget build(BuildContext context) => builder(context, child);
}
