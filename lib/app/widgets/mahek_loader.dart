import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';

import '../utils/app_colors.dart';
import '../utils/font_family.dart';
import '../utils/dark_theme_provider.dart';
import 'app_logo_widget.dart';
import 'global_widgets.dart';

class MahekLoader extends StatefulWidget {
  final String message;
  final double size;
  final double textSize;
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;
  final bool showBackgroundOverlay;
  final Color? overlayColor;

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
  });

  @override
  State<MahekLoader> createState() => _MahekLoaderState();
}

class _MahekLoaderState extends State<MahekLoader> with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Spin animation for the arc
    _spinController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

    // Pulse animation for the logo
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Fade-in animation for the whole widget
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final isDark = theme.isDarkTheme();
    final loaderColor = widget.color ?? AppThemeData.primary50;

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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Spinning arc
                  AnimatedBuilder(
                    animation: _spinController,
                    builder: (_, child) {
                      return CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: _ArcPainter(
                          progress: _spinController.value,
                          color: loaderColor,
                          trackColor: widget.backgroundColor ?? (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
                          strokeWidth: widget.strokeWidth,
                        ),
                      );
                    },
                  ),
                  // Pulsing logo
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: AppLogoWidget(height: widget.size * 0.42, width: widget.size * 0.42),
                  ),
                ],
              ),
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
      return Container(color: widget.overlayColor ?? Colors.black54, child: loaderContent);
    }

    return loaderContent;
  }
}

// Custom painter for the spinning arc with smooth gradient trail
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _ArcPainter({required this.progress, required this.color, required this.trackColor, required this.strokeWidth});

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
    final sweepAngle = math.pi * 0.8; // 144 degrees
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

    // Bright dot at the leading edge
    final dotAngle = startAngle + sweepAngle;
    final dotCenter = Offset(center.dx + radius * math.cos(dotAngle), center.dy + radius * math.sin(dotAngle));

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(dotCenter, strokeWidth * 0.7, dotPaint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => oldDelegate.progress != progress;
}
