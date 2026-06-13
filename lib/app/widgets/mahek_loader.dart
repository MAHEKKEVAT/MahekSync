import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import '../utils/app_colors.dart';
import '../utils/font_family.dart';

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
    this.size = 80.0,
    this.textSize = 15,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 3.0,
    this.showBackgroundOverlay = false,
    this.overlayColor,
    this.style = MahekLoaderStyle.aurora,
    this.customWidget,
  });

  @override
  State<MahekLoader> createState() => _MahekLoaderState();
}

enum MahekLoaderStyle {
  aurora,
  orbit,
  wave,
  pulse,
  ring,
  shimmer,
}

class _MahekLoaderState extends State<MahekLoader>
    with TickerProviderStateMixin {
  late final AnimationController _main;
  late final AnimationController _fade;
  late final Animation<double> _fadeAnim;
  AnimationController? _secondary;

  @override
  void initState() {
    super.initState();
    _main = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fade, curve: Curves.easeOut);
    if (widget.style == MahekLoaderStyle.orbit) {
      _secondary = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3000),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _main.dispose();
    _secondary?.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = FadeTransition(
      opacity: _fadeAnim,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.customWidget != null)
              widget.customWidget!
            else
              SizedBox(
                height: widget.size,
                width: widget.size,
                child: _buildStyle(isDark),
              ),
            spaceH(height: 20),
            TextCustom(
              title: widget.message.tr,
              fontSize: widget.textSize,
              fontFamily: FontFamily.medium,
              color: isDark
                  ? AppThemeData.textNeonPurple.withValues(alpha: 0.9)
                  : AppThemeData.grey7,
            ),
          ],
        ),
      ),
    );

    if (widget.showBackgroundOverlay) {
      return isDark
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  color: widget.overlayColor ??
                      AppThemeData.primaryBlack.withValues(alpha: 0.6),
                  child: content,
                ),
              ),
            )
          : Container(
              color: widget.overlayColor ?? Colors.black54,
              child: content,
            );
    }
    return content;
  }

  Widget _buildStyle(bool isDark) {
    switch (widget.style) {
      case MahekLoaderStyle.aurora:
        return _AuroraLoader(animation: _main, size: widget.size, isDark: isDark);
      case MahekLoaderStyle.orbit:
        return _OrbitLoader(
          primary: _main,
          secondary: _secondary,
          size: widget.size,
          isDark: isDark,
        );
      case MahekLoaderStyle.wave:
        return _WaveLoader(animation: _main, size: widget.size, isDark: isDark);
      case MahekLoaderStyle.pulse:
        return _PulseLoader(animation: _main, size: widget.size, isDark: isDark);
      case MahekLoaderStyle.ring:
        return _RingLoader(animation: _main, size: widget.size, isDark: isDark);
      case MahekLoaderStyle.shimmer:
        return _ShimmerLoader(animation: _main, size: widget.size, isDark: isDark);
    }
  }
}

// ═══════════════════════════════════════════════
// 1. AURORA — Multi-color gradient ring + glow
// ═══════════════════════════════════════════════
class _AuroraLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;
  const _AuroraLoader({required this.animation, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) => CustomPaint(
        size: Size(size, size),
        painter: _AuroraPainter(progress: animation.value, isDark: isDark),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _AuroraPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;

    // Outer glow
    canvas.drawCircle(c, r + 4, Paint()
      ..shader = RadialGradient(colors: [
        const Color(0xFF8B5CF6).withValues(alpha: 0.12),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(center: c, radius: r + 4)));

    // Track
    canvas.drawCircle(c, r, Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);

    // Main aurora arc
    final rect = Rect.fromCircle(center: c, radius: r);
    final start = progress * 2 * math.pi;
    final sweep = math.pi * 1.3;

    final gradient = SweepGradient(
      startAngle: start,
      colors: const [
        Color(0xFF06B6D4),
        Color(0xFF8B5CF6),
        Color(0xFFEC4899),
        Color(0xFFF59E0B),
        Color(0xFF06B6D4),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    canvas.drawArc(rect, start, sweep, false, Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = isDark ? const MaskFilter.blur(BlurStyle.normal, 4) : null);

    // Leading dot
    final dotAngle = start + sweep;
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final dotColors = [
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
    ];
    final colorIdx = (progress * 4).floor() % 4;
    dotPaint.color = dotColors[colorIdx];
    if (isDark) dotPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(
      Offset(c.dx + r * math.cos(dotAngle), c.dy + r * math.sin(dotAngle)),
      5,
      dotPaint,
    );

    // Trailing dot
    final trailAngle = start + sweep * 0.6;
    final trailPaint = Paint()
      ..color = dotColors[(colorIdx + 2) % 4].withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(c.dx + r * math.cos(trailAngle), c.dy + r * math.sin(trailAngle)),
      3,
      trailPaint,
    );

    // Center orb
    final orbPulse = (math.sin(progress * 4 * math.pi) + 1) / 2;
    canvas.drawCircle(c, 10 + orbPulse * 3, Paint()
      ..shader = RadialGradient(colors: [
        const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        const Color(0xFF8B5CF6).withValues(alpha: 0.0),
      ]).createShader(Rect.fromCircle(center: c, radius: 13)));
    canvas.drawCircle(c, 5, Paint()..color = const Color(0xFF8B5CF6));
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════
// 2. ORBIT — Rings + orbiting dots
// ═══════════════════════════════════════════════
class _OrbitLoader extends StatelessWidget {
  final Animation<double> primary;
  final AnimationController? secondary;
  final double size;
  final bool isDark;
  const _OrbitLoader({required this.primary, required this.secondary, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: primary,
      builder: (_, _) => CustomPaint(
        size: Size(size, size),
        painter: _OrbitPainter(
          p1: primary.value,
          p2: secondary?.value ?? 0,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double p1, p2;
  final bool isDark;
  _OrbitPainter({required this.p1, required this.p2, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // Orbit rings
    for (final (i, radius) in [size.width * 0.42, size.width * 0.30].indexed) {
      canvas.drawCircle(c, radius, Paint()
        ..color = (isDark ? Colors.white : Colors.grey).withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
    }

    // Orbiting dots
    final colors = [
      [const Color(0xFF06B6D4), const Color(0xFF8B5CF6)],
      [const Color(0xFFEC4899), const Color(0xFFF59E0B)],
    ];
    final radii = [size.width * 0.42, size.width * 0.30];
    final speeds = [1.0, -1.2];
    final dotSizes = [5.0, 4.0];

    for (var i = 0; i < 2; i++) {
      final angle = p1 * 2 * math.pi * speeds[i];
      final pos = Offset(
        c.dx + radii[i] * math.cos(angle),
        c.dy + radii[i] * math.sin(angle),
      );
      final dotPaint = Paint()..color = colors[i][0];
      if (isDark) dotPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(pos, dotSizes[i], dotPaint);

      // Trail
      for (var t = 1; t <= 3; t++) {
        final trailAngle = angle - t * 0.15 * speeds[i];
        canvas.drawCircle(
          Offset(c.dx + radii[i] * math.cos(trailAngle), c.dy + radii[i] * math.sin(trailAngle)),
          dotSizes[i] * (1 - t * 0.25),
          Paint()..color = colors[i][1].withValues(alpha: 0.3 - t * 0.08),
        );
      }
    }

    // Center pulsing core
    final pulse = (math.sin(p1 * 4 * math.pi) + 1) / 2;
    canvas.drawCircle(c, 8 + pulse * 2, Paint()
      ..shader = RadialGradient(colors: [
        const Color(0xFF8B5CF6).withValues(alpha: 0.35),
        const Color(0xFF8B5CF6).withValues(alpha: 0.0),
      ]).createShader(Rect.fromCircle(center: c, radius: 10)));
    canvas.drawCircle(c, 4, Paint()..color = const Color(0xFF8B5CF6));
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) => old.p1 != p1 || old.p2 != p2;
}

// ═══════════════════════════════════════════════
// 3. WAVE — Bouncing gradient bars
// ═══════════════════════════════════════════════
class _WaveLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;
  const _WaveLoader({required this.animation, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        final colors = [
          const Color(0xFF06B6D4),
          const Color(0xFF8B5CF6),
          const Color(0xFFEC4899),
          const Color(0xFFF59E0B),
          const Color(0xFF10B981),
        ];
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(5, (i) {
            final delay = i * 0.18;
            final bounce = (math.sin(animation.value * 2 * math.pi - delay * 2 * math.pi) + 1) / 2;
            return Container(
              width: size * 0.1,
              height: size * 0.2 + bounce * size * 0.55,
              margin: EdgeInsets.symmetric(horizontal: size * 0.03),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors[i].withValues(alpha: 0.9),
                    colors[i].withValues(alpha: 0.4),
                  ],
                ),
                boxShadow: [
                  if (isDark)
                    BoxShadow(
                      color: colors[i].withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: Offset(0, bounce * 4),
                    ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
// 4. PULSE — Breathing rings
// ═══════════════════════════════════════════════
class _PulseLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;
  const _PulseLoader({required this.animation, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        final p = animation.value;
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (i) {
            final phase = (p + i * 0.33) % 1.0;
            final scale = 0.3 + phase * 0.7;
            final alpha = (1.0 - phase) * 0.4;
            return Container(
              width: size * scale,
              height: size * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  [const Color(0xFF06B6D4), const Color(0xFF8B5CF6), const Color(0xFFEC4899)][i].withValues(alpha: alpha),
                  Colors.transparent,
                ]),
                border: Border.all(
                  color: [const Color(0xFF06B6D4), const Color(0xFF8B5CF6), const Color(0xFFEC4899)][i].withValues(alpha: alpha * 0.8),
                  width: 1.5,
                ),
              ),
            );
          })..addAll([
            Container(
              width: size * 0.22,
              height: size * 0.22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.4 : 0.15),
                    blurRadius: isDark ? 20 : 12,
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
// 5. RING — Speed ring
// ═══════════════════════════════════════════════
class _RingLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;
  const _RingLoader({required this.animation, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) => CustomPaint(
        size: Size(size, size),
        painter: _RingPainter(progress: animation.value, isDark: isDark),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _RingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;

    canvas.drawCircle(c, r, Paint()
      ..color = (isDark ? Colors.white : Colors.grey).withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    final rect = Rect.fromCircle(center: c, radius: r);
    final start = progress * 2 * math.pi;
    final sweep = 0.3 * math.pi + math.sin(progress * math.pi) * math.pi * 1.2;

    final arcPaint = Paint()
      ..shader = SweepGradient(colors: [
        const Color(0xFF06B6D4).withValues(alpha: 0.2),
        const Color(0xFF8B5CF6),
        const Color(0xFFEC4899),
      ]).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    if (isDark) arcPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawArc(rect, start, sweep, false, arcPaint);

    // Leading dot
    final dotAngle = start + sweep;
    final dotPaint = Paint()
      ..color = const Color(0xFFEC4899)
      ..style = PaintingStyle.fill;
    if (isDark) dotPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(
      Offset(c.dx + r * math.cos(dotAngle), c.dy + r * math.sin(dotAngle)),
      4,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════
// 6. SHIMMER — Gradient bar
// ═══════════════════════════════════════════════
class _ShimmerLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;
  const _ShimmerLoader({required this.animation, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) => Center(
        child: Container(
          height: 8,
          width: size * 1.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: const [
                Color(0xFF06B6D4),
                Color(0xFF8B5CF6),
                Color(0xFFEC4899),
                Color(0xFFF59E0B),
                Color(0xFF06B6D4),
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              transform: _SlidingGradient(animation.value),
            ),
            boxShadow: [
              if (isDark)
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlidingGradient extends GradientTransform {
  final double value;
  const _SlidingGradient(this.value);
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (value - 0.5) * 2, 0, 0);
  }
}

// ═══════════════════════════════════════════════
// SHARED
// ═══════════════════════════════════════════════
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
