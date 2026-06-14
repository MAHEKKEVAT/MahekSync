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
  final bool showBranding;

  const MahekLoader({
    super.key,
    this.message = 'Please Wait...',
    this.size = 200.0,
    this.textSize = 18,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 3.0,
    this.showBackgroundOverlay = false,
    this.overlayColor,
    this.style = MahekLoaderStyle.siri,
    this.customWidget,
    this.showBranding = true,
  });

  @override
  State<MahekLoader> createState() => _MahekLoaderState();
}

enum MahekLoaderStyle {
  siri,
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
  late final AnimationController _brandingScale;
  AnimationController? _secondary;

  @override
  void initState() {
    super.initState();
    _main = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fade, curve: Curves.easeOut);
    _brandingScale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
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
    _brandingScale.dispose();
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
            if (widget.showBranding) ...[
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _brandingScale,
                  curve: Curves.elasticOut,
                ),
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF06B6D4),
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                  ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: const Text(
                    'MahekSync',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              spaceH(height: 28),
            ],
            if (widget.customWidget != null)
              widget.customWidget!
            else
              SizedBox(
                height: widget.size,
                width: widget.size,
                child: _buildStyle(isDark),
              ),
            spaceH(height: 28),
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
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: widget.overlayColor ??
                      AppThemeData.primaryBlack.withValues(alpha: 0.7),
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
      case MahekLoaderStyle.siri:
        return _SiriLoader(
            animation: _main, size: widget.size, isDark: isDark);
      case MahekLoaderStyle.aurora:
        return _AuroraLoader(
            animation: _main, size: widget.size, isDark: isDark);
      case MahekLoaderStyle.orbit:
        return _OrbitLoader(
          primary: _main,
          secondary: _secondary,
          size: widget.size,
          isDark: isDark,
        );
      case MahekLoaderStyle.wave:
        return _WaveLoader(
            animation: _main, size: widget.size, isDark: isDark);
      case MahekLoaderStyle.pulse:
        return _PulseLoader(
            animation: _main, size: widget.size, isDark: isDark);
      case MahekLoaderStyle.ring:
        return _RingLoader(
            animation: _main, size: widget.size, isDark: isDark);
      case MahekLoaderStyle.shimmer:
        return _ShimmerLoader(
            animation: _main, size: widget.size, isDark: isDark);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// SIRI-STYLE LOADER — Colorful morphing orb with flowing ribbons
// ═══════════════════════════════════════════════════════════════
class _SiriLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;
  const _SiriLoader(
      {required this.animation, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) => CustomPaint(
        size: Size(size, size),
        painter: _SiriPainter(progress: animation.value, isDark: isDark),
      ),
    );
  }
}

class _SiriPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _SiriPainter({required this.progress, required this.isDark});

  static const _colors = [
    Color(0xFFBF5AF2), // Purple
    Color(0xFF5E5CE6), // Blue
    Color(0xFFFF375F), // Pink
    Color(0xFFFF9F0A), // Orange
    Color(0xFFFFD60A), // Yellow
    Color(0xFF30D158), // Green
    Color(0xFF64D2FF), // Teal
    Color(0xFFBF5AF2), // loop back to Purple
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width / 2 - 8;

    // ── Ambient glow (pulsing) ──
    final pulseA = (math.sin(progress * 4 * math.pi) + 1) / 2;
    canvas.drawCircle(
      Offset(cx, cy),
      maxR * 0.85 + pulseA * 8,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFBF5AF2).withValues(alpha: 0.12 + pulseA * 0.08),
            const Color(0xFF5E5CE6).withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ).createShader(
            Rect.fromCircle(center: Offset(cx, cy), radius: maxR * 0.9)),
    );

    // ── Central orb (breathing + color shift) ──
    final orbScale = 0.55 + pulseA * 0.12;
    final orbR = maxR * orbScale;

    // Orb gradient rotates with progress
    final orbAngle = progress * 2 * math.pi;
    final orbRect = Rect.fromCircle(center: Offset(cx, cy), radius: orbR);

    canvas.drawCircle(
      Offset(cx, cy),
      orbR,
      Paint()
        ..shader = SweepGradient(
          startAngle: orbAngle,
          colors: const [
            Color(0xFFBF5AF2),
            Color(0xFF5E5CE6),
            Color(0xFF64D2FF),
            Color(0xFF30D158),
            Color(0xFFFFD60A),
            Color(0xFFFF9F0A),
            Color(0xFFFF375F),
            Color(0xFFBF5AF2),
          ],
          stops: const [0.0, 0.14, 0.28, 0.42, 0.57, 0.71, 0.85, 1.0],
        ).createShader(orbRect)
        ..maskFilter = isDark
            ? const MaskFilter.blur(BlurStyle.normal, 18)
            : const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Inner bright core
    canvas.drawCircle(
      Offset(cx, cy),
      orbR * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
            Rect.fromCircle(center: Offset(cx, cy), radius: orbR * 0.55)),
    );

    // ── Flowing ribbons (3 ribbons orbiting the orb) ──
    for (var ribbon = 0; ribbon < 3; ribbon++) {
      final ribbonPhase = progress * 2 * math.pi + ribbon * (2 * math.pi / 3);
      final ribbonLen = math.pi * 1.1;
      final ribbonR = orbR + 12 + ribbon * 6;

      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: ribbonR);

      // Each ribbon has different color gradient
      final ribbonStart = ribbonPhase % (2 * math.pi);
      final ribbonSweep = math.max(0.01, ribbonLen);

      final c1 = _colors[ribbon * 2];
      final c2 = _colors[ribbon * 2 + 1];

      canvas.drawArc(
        rect,
        ribbonStart,
        ribbonSweep,
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: ribbonStart,
            colors: [
              c1.withValues(alpha: 0.0),
              c1.withValues(alpha: 0.9),
              c2.withValues(alpha: 0.9),
              c2.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0 - ribbon * 0.8
          ..strokeCap = StrokeCap.round
          ..maskFilter = isDark
              ? MaskFilter.blur(BlurStyle.normal, 4.0 + ribbon.toDouble())
              : null,
      );

      // Leading dot on each ribbon
      final dotAngle = ribbonStart + ribbonSweep;
      final dotPaint = Paint()
        ..color = c2
        ..style = PaintingStyle.fill;
      if (isDark) {
        dotPaint.maskFilter =
            const MaskFilter.blur(BlurStyle.normal, 8);
      }
      canvas.drawCircle(
        Offset(cx + ribbonR * math.cos(dotAngle),
            cy + ribbonR * math.sin(dotAngle)),
        4.5 - ribbon * 0.5,
        dotPaint,
      );
    }

    // ── Orbiting sparkle particles ──
    for (var p = 0; p < 6; p++) {
      final orbitAngle =
          progress * 2 * math.pi * (0.6 + p * 0.25) + p * math.pi / 3;
      final orbitR = orbR + 28 + p * 4.0;
      final twinkle =
          (math.sin(progress * 6 * math.pi + p * 1.3) + 1) / 2;
      final px = cx + orbitR * math.cos(orbitAngle);
      final py = cy + orbitR * math.sin(orbitAngle);

      final sparklePaint = Paint()
        ..color = _colors[p % _colors.length]
            .withValues(alpha: 0.3 + twinkle * 0.6)
        ..style = PaintingStyle.fill;
      if (isDark) {
        sparklePaint.maskFilter =
            MaskFilter.blur(BlurStyle.normal, 3 + twinkle * 4);
      }
      canvas.drawCircle(
        Offset(px, py),
        2.0 + twinkle * 2.5,
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SiriPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════
// AURORA LOADER
// ═══════════════════════════════════════════════════════════════
class _AuroraLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;
  const _AuroraLoader(
      {required this.animation, required this.size, required this.isDark});

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
    final r = size.width / 2 - 14;

    canvas.drawCircle(
        c,
        r + 10,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.15),
            Colors.transparent,
          ]).createShader(
              Rect.fromCircle(center: c, radius: r + 10)));

    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);

    final rect = Rect.fromCircle(center: c, radius: r);
    final start = (progress * 2 * math.pi) % (2 * math.pi);
    final sweep = math.pi * 1.4;

    canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: start,
            colors: const [
              Color(0xFF06B6D4),
              Color(0xFF8B5CF6),
              Color(0xFFEC4899),
              Color(0xFFF59E0B),
              Color(0xFF10B981),
              Color(0xFF06B6D4),
            ],
            stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..maskFilter = isDark ? const MaskFilter.blur(BlurStyle.normal, 6) : null);

    final start2 = progress * 2 * math.pi + math.pi;
    final sweep2 = math.pi * 0.6;
    canvas.drawArc(
        rect,
        start2,
        sweep2,
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: start2,
            colors: [
              const Color(0xFFEC4899).withValues(alpha: 0.3),
              const Color(0xFF8B5CF6).withValues(alpha: 0.8),
              const Color(0xFFEC4899).withValues(alpha: 0.3),
            ],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);

    final dotAngle = start + sweep;
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final dotColors = [
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
    ];
    final colorIdx = (progress * 5).floor() % 5;
    dotPaint.color = dotColors[colorIdx];
    if (isDark) {
      dotPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    }

    canvas.drawCircle(
      Offset(c.dx + r * math.cos(dotAngle), c.dy + r * math.sin(dotAngle)),
      7,
      dotPaint,
    );

    for (var t = 1; t <= 4; t++) {
      final trailAngle = start + sweep - t * 0.12;
      canvas.drawCircle(
        Offset(c.dx + r * math.cos(trailAngle),
            c.dy + r * math.sin(trailAngle)),
        7 - t * 1.2,
        Paint()
          ..color = dotColors[(colorIdx + t) % 5]
              .withValues(alpha: 0.5 - t * 0.1),
      );
    }

    final orbPulse = (math.sin(progress * 4 * math.pi) + 1) / 2;
    canvas.drawCircle(
        c,
        16 + orbPulse * 6,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.25),
            const Color(0xFF8B5CF6).withValues(alpha: 0.0),
          ]).createShader(
              Rect.fromCircle(center: c, radius: 22)));
    canvas.drawCircle(
        c,
        8,
        Paint()
          ..shader = const RadialGradient(colors: [
            Color(0xFFEC4899),
            Color(0xFF8B5CF6),
          ]).createShader(Rect.fromCircle(center: c, radius: 8)));
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════
// ORBIT LOADER
// ═══════════════════════════════════════════════════════════════
class _OrbitLoader extends StatelessWidget {
  final Animation<double> primary;
  final AnimationController? secondary;
  final double size;
  final bool isDark;
  const _OrbitLoader(
      {required this.primary,
      required this.secondary,
      required this.size,
      required this.isDark});

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

    for (final (i, radius) in [
      size.width * 0.44,
      size.width * 0.32,
      size.width * 0.20
    ].indexed) {
      canvas.drawCircle(
          c,
          radius,
          Paint()
            ..color = (isDark ? Colors.white : Colors.grey)
                .withValues(alpha: 0.04 + i * 0.01)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
    }

    final colors = [
      [const Color(0xFF06B6D4), const Color(0xFF8B5CF6)],
      [const Color(0xFFEC4899), const Color(0xFFF59E0B)],
      [const Color(0xFF10B981), const Color(0xFF8B5CF6)],
    ];
    final radii = [size.width * 0.44, size.width * 0.32, size.width * 0.20];
    final speeds = [1.0, -1.4, 2.0];
    final dotSizes = [6.0, 5.0, 4.0];

    for (var i = 0; i < 3; i++) {
      final angle = p1 * 2 * math.pi * speeds[i];
      final pos = Offset(
        c.dx + radii[i] * math.cos(angle),
        c.dy + radii[i] * math.sin(angle),
      );
      final dotPaint = Paint()..color = colors[i][0];
      if (isDark) {
        dotPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      }
      canvas.drawCircle(pos, dotSizes[i], dotPaint);

      for (var t = 1; t <= 4; t++) {
        final trailAngle = angle - t * 0.12 * speeds[i];
        canvas.drawCircle(
          Offset(c.dx + radii[i] * math.cos(trailAngle),
              c.dy + radii[i] * math.sin(trailAngle)),
          dotSizes[i] * (1 - t * 0.2),
          Paint()
            ..color = colors[i][1].withValues(alpha: 0.35 - t * 0.08),
        );
      }
    }

    final pulse = (math.sin(p1 * 4 * math.pi) + 1) / 2;
    canvas.drawCircle(
        c,
        10 + pulse * 4,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            const Color(0xFF8B5CF6).withValues(alpha: 0.0),
          ]).createShader(
              Rect.fromCircle(center: c, radius: 14)));
    canvas.drawCircle(
        c,
        5,
        Paint()
          ..shader = const RadialGradient(colors: [
            Color(0xFFEC4899),
            Color(0xFF8B5CF6),
          ]).createShader(Rect.fromCircle(center: c, radius: 5)));
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) =>
      old.p1 != p1 || old.p2 != p2;
}

// ═══════════════════════════════════════════════════════════════
// WAVE LOADER
// ═══════════════════════════════════════════════════════════════
class _WaveLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;
  const _WaveLoader(
      {required this.animation, required this.size, required this.isDark});

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
          const Color(0xFF8B5CF6),
          const Color(0xFF06B6D4),
        ];
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(7, (i) {
            final delay = i * 0.14;
            final bounce = (math.sin(animation.value * 2 * math.pi -
                    delay * 2 * math.pi) +
                1) /
                2;
            return Container(
              width: size * 0.07,
              height: size * 0.15 + bounce * size * 0.6,
              margin: EdgeInsets.symmetric(horizontal: size * 0.015),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors[i].withValues(alpha: 0.9),
                    colors[i].withValues(alpha: 0.35),
                  ],
                ),
                boxShadow: [
                  if (isDark)
                    BoxShadow(
                      color: colors[i].withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: Offset(0, bounce * 6),
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

// ═══════════════════════════════════════════════════════════════
// PULSE LOADER
// ═══════════════════════════════════════════════════════════════
class _PulseLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;
  const _PulseLoader(
      {required this.animation, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        final p = animation.value;
        return Stack(
          alignment: Alignment.center,
          children: List.generate(4, (i) {
            final phase = (p + i * 0.25) % 1.0;
            final scale = 0.25 + phase * 0.75;
            final alpha = (1.0 - phase) * 0.5;
            return Container(
              width: size * scale,
              height: size * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  [
                    const Color(0xFF06B6D4),
                    const Color(0xFF8B5CF6),
                    const Color(0xFFEC4899),
                    const Color(0xFFF59E0B)
                  ][i].withValues(alpha: alpha),
                  Colors.transparent,
                ]),
                border: Border.all(
                  color: [
                    const Color(0xFF06B6D4),
                    const Color(0xFF8B5CF6),
                    const Color(0xFFEC4899),
                    const Color(0xFFF59E0B)
                  ][i].withValues(alpha: alpha * 0.8),
                  width: 2,
                ),
              ),
            );
          })
            ..addAll([
              Container(
                width: size * 0.2,
                height: size * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6)
                          .withValues(alpha: isDark ? 0.5 : 0.2),
                      blurRadius: isDark ? 28 : 16,
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

// ═══════════════════════════════════════════════════════════════
// RING LOADER
// ═══════════════════════════════════════════════════════════════
class _RingLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;
  const _RingLoader(
      {required this.animation, required this.size, required this.isDark});

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
    final r = size.width / 2 - 10;

    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = (isDark ? Colors.white : Colors.grey)
              .withValues(alpha: 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);

    final rect = Rect.fromCircle(center: c, radius: r);
    final start = progress * 2 * math.pi;
    final sweep = math.max(
        0.01,
        0.4 * math.pi +
            math.sin(progress * math.pi) * math.pi * 1.4);

    final arcPaint = Paint()
      ..shader = SweepGradient(colors: [
        const Color(0xFF06B6D4).withValues(alpha: 0.2),
        const Color(0xFF8B5CF6),
        const Color(0xFFEC4899),
        const Color(0xFFF59E0B),
      ]).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    if (isDark) {
      arcPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    }

    canvas.drawArc(rect, start, sweep, false, arcPaint);

    final dotAngle = start + sweep;
    final dotPaint = Paint()
      ..color = const Color(0xFFEC4899)
      ..style = PaintingStyle.fill;
    if (isDark) {
      dotPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    }
    canvas.drawCircle(
      Offset(c.dx + r * math.cos(dotAngle), c.dy + r * math.sin(dotAngle)),
      5.5,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════
// SHIMMER LOADER
// ═══════════════════════════════════════════════════════════════
class _ShimmerLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;
  const _ShimmerLoader(
      {required this.animation, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) => Center(
        child: Container(
          height: 10,
          width: size * 1.2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: const [
                Color(0xFF06B6D4),
                Color(0xFF8B5CF6),
                Color(0xFFEC4899),
                Color(0xFFF59E0B),
                Color(0xFF10B981),
                Color(0xFF06B6D4),
              ],
              stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
              transform: _SlidingGradient(animation.value),
            ),
            boxShadow: [
              if (isDark)
                BoxShadow(
                  color:
                      const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 18,
                  spreadRadius: 2,
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
    return Matrix4.translationValues(
        bounds.width * (value - 0.5) * 2, 0, 0);
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
  Widget build(BuildContext context) => builder(context, child);
}
