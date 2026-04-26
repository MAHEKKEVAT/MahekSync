// lib/app/widgets/water_bubble_progress.dart
import 'dart:math';
import 'package:flutter/material.dart';

class WaterBubbleProgress extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final Color? color; // Optional - if null, random color assigned
  final Color backgroundColor;
  final String? label;
  final String? subLabel;
  final bool isExpiring;
  final int animationDuration; // Seconds to fill

  const WaterBubbleProgress({
    super.key,
    required this.progress,
    this.size = 120,
    this.color,
    this.backgroundColor = const Color(0xFF1C1F26),
    this.label,
    this.subLabel,
    this.isExpiring = false,
    this.animationDuration = 4, // Default 4 seconds
  });

  @override
  State<WaterBubbleProgress> createState() => _WaterBubbleProgressState();
}

class _WaterBubbleProgressState extends State<WaterBubbleProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;
  late Animation<double> _fillAnimation; // Animated fill from 0 to progress

  // Random color assigned per instance
  late Color _instanceColor;

  // Color palette (cold drink inspired)
  static const List<Color> _colorPalette = [
    Color(0xFF6C63FF), // Purple
    Color(0xFFFF6B6B), // Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFE66D), // Yellow
    Color(0xFFFF8A5C), // Orange
    Color(0xFF45B7D1), // Blue
    Color(0xFF96CEB4), // Green
    Color(0xFFFF9FF3), // Pink
    Color(0xFF54A0FF), // Ocean Blue
    Color(0xFF5F27CD), // Deep Purple
    Color(0xFF01A3A4), // Sea Green
    Color(0xFFF368E0), // Magenta
    Color(0xFF2ED573), // Lime
    Color(0xFFFF6348), // Tomato
    Color(0xFF7BED9F), // Light Green
    Color(0xFF70A1FF), // Sky Blue
    Color(0xFFFF4757), // Watermelon
    Color(0xFFE056A0), // Berry
  ];

  static int _colorIndex = 0;

  @override
  void initState() {
    super.initState();

    // Assign random color (or use provided color)
    _instanceColor = widget.color ?? _getNextColor();

    // Fill animation controller (0 to target progress)
    _controller = AnimationController(
      duration: Duration(seconds: widget.animationDuration),
      vsync: this,
    );

    // Animated fill value from 0 to actual progress
    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic, // Smooth easing like filling a glass
    ));

    // Wave animation (continuous)
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.linear),
    ));

    // Start fill animation
    _controller.forward();

    // After fill completes, continue wave loop
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Keep wave animating after fill completes
        _controller.repeat();
      }
    });
  }

  Color _getNextColor() {
    _colorIndex = (_colorIndex + 1) % _colorPalette.length;
    return _colorPalette[_colorIndex];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _LiquidBubblePainter(
            progress: _fillAnimation.value,
            targetProgress: widget.progress,
            color: _instanceColor,
            backgroundColor: widget.backgroundColor,
            waveOffset: _waveAnimation.value,
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
                  color: _fillAnimation.value > 0.5
                      ? widget.backgroundColor
                      : _instanceColor,
                ),
              ),
            if (widget.subLabel != null)
              Text(
                widget.subLabel!,
                style: TextStyle(
                  fontSize: widget.size * 0.1,
                  fontWeight: FontWeight.w500,
                  color: _fillAnimation.value > 0.5
                      ? widget.backgroundColor.withOpacity(0.7)
                      : _instanceColor.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LiquidBubblePainter extends CustomPainter {
  final double progress;
  final double targetProgress;
  final Color color;
  final Color backgroundColor;
  final double waveOffset;
  final bool isExpiring;

  _LiquidBubblePainter({
    required this.progress,
    required this.targetProgress,
    required this.color,
    required this.backgroundColor,
    required this.waveOffset,
    required this.isExpiring,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final margin = 3.0;
    final innerRadius = radius - margin;

    // ─── Background Circle ───
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, bgPaint);

    // ─── Glass Border Effect ───
    final glassBorder = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.15),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, innerRadius, glassBorder);

    // ─── Liquid / Cold Drink Effect ───
    final waterHeight = size.height - (size.height * progress);

    // Clip to circle shape
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: innerRadius)));

    if (progress > 0) {
      final waterPath = Path();
      waterPath.moveTo(0, size.height);

      // Create wavy top surface (multiple sine waves for realistic liquid)
      for (double x = 0; x <= size.width; x += 1) {
        final normalizedX = x / size.width;
        final wave1 = sin((normalizedX * 4 * pi) + waveOffset) * 6.0;
        final wave2 = sin((normalizedX * 8 * pi) + waveOffset * 1.7) * 3.0;
        final wave3 = sin((normalizedX * 2 * pi) + waveOffset * 0.5) * 8.0;
        final y = waterHeight + wave1 + wave2 + wave3;

        if (x == 0) {
          waterPath.lineTo(x, y);
        } else {
          waterPath.lineTo(x, y);
        }
      }

      waterPath.lineTo(size.width, size.height);
      waterPath.close();

      // ─── Liquid Gradient (Cold Drink Effect) ───
      final liquidShader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.7),       // Top (lighter)
          color.withOpacity(0.85),      // Upper middle
          color,                         // Middle
          color.withOpacity(0.9),        // Lower middle
          color.withOpacity(0.75),       // Bottom
        ],
        stops: const [0.0, 0.15, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, waterHeight - 30, size.width, size.height - waterHeight + 30));

      final waterPaint = Paint()..shader = liquidShader;
      canvas.drawPath(waterPath, waterPaint);

      // ─── Liquid Surface Highlight (Glass effect on top of liquid) ───
      final surfacePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, waterHeight - 30, size.width, 60));

      canvas.drawPath(waterPath, surfacePaint);

      // ─── Bubbles Inside Liquid ───
      final random = Random(42); // Fixed seed for consistent bubbles
      final bubblePaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 8; i++) {
        final bubbleX = (random.nextDouble() * size.width * 0.8) + size.width * 0.1;
        final bubbleY = waterHeight + 10 + (random.nextDouble() * (size.height - waterHeight - 20));
        final bubbleSize = random.nextDouble() * 6 + 2;

        // Bubbles only visible in liquid area
        if (bubbleY > waterHeight && bubbleY < size.height) {
          canvas.drawCircle(
            Offset(bubbleX, bubbleY),
            bubbleSize,
            bubblePaint,
          );

          // Bubble highlight
          canvas.drawCircle(
            Offset(bubbleX - bubbleSize * 0.3, bubbleY - bubbleSize * 0.3),
            bubbleSize * 0.4,
            Paint()..color = Colors.white.withOpacity(0.4),
          );
        }
      }
    }

    // ─── Glass Reflection/Shine ───
    final shinePath = Path()
      ..moveTo(center.dx - innerRadius * 0.5, center.dy - innerRadius * 0.3)
      ..quadraticBezierTo(
        center.dx - innerRadius * 0.1,
        center.dy - innerRadius * 0.6,
        center.dx + innerRadius * 0.3,
        center.dy - innerRadius * 0.25,
      )
      ..lineTo(center.dx + innerRadius * 0.15, center.dy - innerRadius * 0.05)
      ..quadraticBezierTo(
        center.dx - innerRadius * 0.05,
        center.dy - innerRadius * 0.35,
        center.dx - innerRadius * 0.35,
        center.dy - innerRadius * 0.15,
      )
      ..close();

    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shinePath, shinePaint);

    canvas.restore();

    // ─── Expiring Glow Effect ───
    if (isExpiring) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF453A).withOpacity(0.4),
            const Color(0xFFFF453A).withOpacity(0.1),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
      canvas.drawCircle(center, innerRadius, glowPaint);
    }

    // ─── Percentage Text ───
    final displayPercent = (progress * 100).toInt();
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$displayPercent%',
        style: TextStyle(
          fontSize: innerRadius * 0.3,
          fontWeight: FontWeight.w800,
          color: progress > 0.5 ? backgroundColor : color,
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
  bool shouldRepaint(covariant _LiquidBubblePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveOffset != waveOffset ||
        oldDelegate.isExpiring != isExpiring ||
        oldDelegate.targetProgress != targetProgress;
  }
}

// ─── AnimatedBuilder Wrapper ───
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
    final animation = listenable as Animation<double>;
    return builder(context, child);
  }
}