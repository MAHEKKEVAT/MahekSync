import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import '../utils/app_colors.dart';
import '../utils/font_family.dart';

/// Premium customizable loader with multiple high-fidelity animation styles
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
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    if (widget.style == MahekLoaderStyle.dualRing) {
      _secondController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      )..repeat();
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
            (isDark ? AppThemeData.grey8.withOpacity(0.2) : AppThemeData.grey3.withOpacity(0.4));

    Widget loaderContent = FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.customWidget != null)
              widget.customWidget!
            else
              SizedBox(
                height: widget.size,
                width: widget.size,
                child: _buildLoaderByStyle(loaderColor, trackColor, isDark),
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

  Widget _buildLoaderByStyle(Color color, Color trackColor, bool isDark) {
    switch (widget.style) {
      case MahekLoaderStyle.arc:
        return _buildArcLoader(color, trackColor);
      case MahekLoaderStyle.pulse:
        return _buildPulseLoader(color, isDark);
      case MahekLoaderStyle.wave:
        return _buildWaveLoader(color);
      case MahekLoaderStyle.ring:
        return _buildRingLoader(color, trackColor);
      case MahekLoaderStyle.dualRing:
        return _buildDualRingLoader(color, trackColor, isDark);
      case MahekLoaderStyle.shimmer:
        return _buildShimmerLoader(color);
    }
  }

  // ═══════════════════════════════════
  // 1. UPGRADED ARC LOADER (Glowing Core + Smooth Trail)
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
  // 2. UPGRADED PULSE LOADER (Double Ambient Neon Wave)
  // ═══════════════════════════════════
  Widget _buildPulseLoader(Color color, bool isDark) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        final progress = _mainController.value;
        final pulse1 = (math.sin(progress * 2 * math.pi) + 1) / 2;
        final pulse2 = (math.cos(progress * 2 * math.pi) + 1) / 2;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size * (0.4 + pulse1 * 0.6),
              height: widget.size * (0.4 + pulse1 * 0.6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12 * (1.0 - progress)),
                border: Border.all(color: color.withOpacity(0.3 * (1.0 - progress)), width: 1.5),
              ),
            ),
            Container(
              width: widget.size * (0.3 + pulse2 * 0.5),
              height: widget.size * (0.3 + pulse2 * 0.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color, color.withOpacity(0.0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isDark ? 0.25 : 0.12),
                    blurRadius: 16,
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════
  // 3. UPGRADED WAVE LOADER (Fluid Capsule Height Bars)
  // ═══════════════════════════════════
  Widget _buildWaveLoader(Color color) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(4, (index) {
            final delay = index * 0.22;
            final bounceValue = (math.sin((_mainController.value * 2 * math.pi) - (delay * 2 * math.pi)) + 1) / 2;
            return Container(
              width: widget.size * 0.14,
              height: widget.size * 0.2 + (bounceValue * widget.size * 0.55),
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color,
                    color.withOpacity(0.4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, bounceValue * 3),
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
  // 4. UPGRADED RING LOADER (Progressive Velocity Ring)
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
  // 5. UPGRADED DUAL RING LOADER (Counter-Rotational Loops)
  // ═══════════════════════════════════
  Widget _buildDualRingLoader(Color color, Color trackColor, bool isDark) {
    final secondaryColor = isDark ? AppThemeData.neonPurpleDim : AppThemeData.primary2;
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _DualRingPainter(
            progress1: _mainController.value,
            progress2: _secondController?.value ?? 0,
            color: color,
            secondaryColor: secondaryColor,
            trackColor: trackColor,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════
  // 6. UPGRADED SHIMMER LOADER (Gemini Inspired Pill)
  // ═══════════════════════════════════
  Widget _buildShimmerLoader(Color color) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        return Center(
          child: Container(
            height: 8,
            width: widget.size * 1.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  color.withOpacity(0.05),
                  color.withOpacity(0.3),
                  AppThemeData.neonPurple.withOpacity(0.8),
                  color.withOpacity(0.3),
                  color.withOpacity(0.05),
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                transform: _SlidingGradient(_mainController.value),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
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
// REDESIGNED PAINTER ARCHITECTURES
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

    canvas.drawCircle(center, radius, Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.5);

    final sweepAngle = math.pi * 0.85;
    final startAngle = (progress * 2 * math.pi) - (math.pi / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: [color.withOpacity(0.0), color.withOpacity(0.4), color],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(startAngle),
    );

    canvas.drawArc(rect, startAngle, sweepAngle, false, Paint()..shader = gradient.createShader(rect)..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round);

    final dotAngle = startAngle + sweepAngle;
    canvas.drawCircle(Offset(center.dx + radius * math.cos(dotAngle), center.dy + radius * math.sin(dotAngle)), strokeWidth * 0.75, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => oldDelegate.progress != progress;
}

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

    canvas.drawCircle(center, radius, Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.4);

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Smooth nonlinear speed breathing arc curve
    final double offsetProgress = math.sin(progress * math.pi);
    final double startAngle = (progress * 2 * math.pi) - (math.pi / 2);
    final double sweepAngle = 0.3 * math.pi + (offsetProgress * math.pi * 1.2);

    canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..shader = SweepGradient(colors: [color.withOpacity(0.2), color]).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}

class _DualRingPainter extends CustomPainter {
  final double progress1;
  final double progress2;
  final Color color;
  final Color secondaryColor;
  final Color trackColor;
  final double strokeWidth;

  _DualRingPainter({
    required this.progress1,
    required this.progress2,
    required this.color,
    required this.secondaryColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width - strokeWidth) / 2;
    final innerRadius = outerRadius * 0.65;

    // Outer Loop
    canvas.drawCircle(center, outerRadius, Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.4);
    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final outerProgress = math.sin(progress1 * math.pi);
    canvas.drawArc(
      outerRect,
      (progress1 * 2 * math.pi) - (math.pi / 2),
      0.4 * math.pi + (outerProgress * math.pi * 1.1),
      false,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round,
    );

    // Inner Counter Loop
    canvas.drawCircle(center, innerRadius, Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.3);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    final innerProgress = math.cos(progress2 * math.pi).abs();
    canvas.drawArc(
      innerRect,
      (-progress2 * 2 * math.pi) + (math.pi / 2),
      -(0.3 * math.pi + (innerProgress * math.pi * 1.0)),
      false,
      Paint()..color = secondaryColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.75..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DualRingPainter oldDelegate) =>
      oldDelegate.progress1 != progress1 || oldDelegate.progress2 != progress2;
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
  Widget build(BuildContext context) => builder(context, child);
}