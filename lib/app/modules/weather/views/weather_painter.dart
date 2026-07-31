import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:maheksync/app/theme/weather_theme.dart';
import 'package:maheksync/app/utils/font_family.dart';

// ══════════════════════════════════════════════════════════════════════
//  PREMIUM GLASS CARD — Noise texture + blur + hover + glow
// ══════════════════════════════════════════════════════════════════════

class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? glowColor;
  final VoidCallback? onTap;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.glowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final glow = glowColor ?? wt?.textPrimary ?? Colors.white;
    final glassBg = wt?.glassBackground ?? Colors.white.withValues(alpha: 0.07);
    final glassBd = wt?.glassBorder ?? Colors.white.withValues(alpha: 0.08);
    final noiseOp = wt?.glassNoiseOverlay ?? Colors.white.withValues(alpha: 0.035);
    final blurSigma = wt?.glassBlurSigma ?? 24;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: glassBg,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: glassBd, width: 1),
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: glassBd,
                  blurRadius: 1,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Image.asset(
                      'assets/images/noise_texture.png',
                      fit: BoxFit.cover,
                      opacity: AlwaysStoppedAnimation(noiseOp.opacity),
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      gradient: LinearGradient(
                        colors: [
                          glassBd,
                          Colors.transparent,
                          glassBd.withValues(alpha: 0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  WEATHER ICON — CustomPainter-based, animated
// ══════════════════════════════════════════════════════════════════════

class WeatherIcon extends StatelessWidget {
  final int code;
  final double size;
  final bool animate;
  final Color? color;

  const WeatherIcon({
    super.key,
    required this.code,
    this.size = 32,
    this.animate = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (animate) {
      return _AnimatedWeatherIcon(
        code: code,
        size: size,
        color: color ?? Colors.white,
      );
    }
    return CustomPaint(
      size: Size(size, size),
      painter: WeatherIconPainter(
        code: code,
        animationValue: 0,
        color: color ?? Colors.white,
      ),
    );
  }
}

class _AnimatedWeatherIcon extends StatefulWidget {
  final int code;
  final double size;
  final Color color;

  const _AnimatedWeatherIcon({
    required this.code,
    required this.size,
    required this.color,
  });

  @override
  State<_AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<_AnimatedWeatherIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
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
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: WeatherIconPainter(
            code: widget.code,
            animationValue: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class WeatherIconPainter extends CustomPainter {
  final int code;
  final double animationValue;
  final Color color;

  WeatherIconPainter({
    required this.code,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.35;

    if (code == 0) {
      _paintSun(canvas, cx, cy, r);
    } else if (code <= 3) {
      _paintPartlyCloudy(canvas, cx, cy, r);
    } else if (code <= 48) {
      _paintFog(canvas, cx, cy, r);
    } else if (code <= 57) {
      _paintDrizzle(canvas, cx, cy, r);
    } else if (code <= 67) {
      _paintRain(canvas, cx, cy, r);
    } else if (code <= 77) {
      _paintSnow(canvas, cx, cy, r);
    } else if (code <= 82) {
      _paintRain(canvas, cx, cy, r);
    } else if (code <= 86) {
      _paintSnow(canvas, cx, cy, r);
    } else if (code <= 99) {
      _paintStorm(canvas, cx, cy, r);
    } else {
      _paintCloud(canvas, cx, cy, r);
    }
  }

  void _paintSun(Canvas canvas, double cx, double cy, double r) {
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: 0.7),
        ],
      ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r * 0.5, bodyPaint);

    final rayPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = max(1.5, r * 0.08)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (animationValue * pi * 2);
      final innerR = r * 0.65;
      final outerR = r * 0.9;
      final wobble = sin(animationValue * pi * 2 + i) * r * 0.04;
      canvas.drawLine(
        Offset(cx + (innerR + wobble) * cos(angle),
            cy + (innerR + wobble) * sin(angle)),
        Offset(cx + outerR * cos(angle), cy + outerR * sin(angle)),
        rayPaint,
      );
    }
  }

  void _paintCloud(Canvas canvas, double cx, double cy, double r) {
    final p = Paint()..style = PaintingStyle.fill;
    final cloudColor = color.withValues(alpha: 0.85);

    p.color = cloudColor;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, cy + r * 0.1),
          width: r * 1.6,
          height: r * 0.7),
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - r * 0.3, cy - r * 0.1),
          width: r * 0.9,
          height: r * 0.65),
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx + r * 0.35, cy - r * 0.05),
          width: r * 0.7,
          height: r * 0.55),
      p,
    );
  }

  void _paintPartlyCloudy(Canvas canvas, double cx, double cy, double r) {
    final sunR = r * 0.35;
    final sunX = cx - r * 0.2;
    final sunY = cy - r * 0.15;

    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0.5)],
      ).createShader(
          Rect.fromCircle(center: Offset(sunX, sunY), radius: sunR));
    canvas.drawCircle(Offset(sunX, sunY), sunR * 0.55, sunPaint);

    final rayPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = max(1, r * 0.06)
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) + (animationValue * pi * 2);
      canvas.drawLine(
        Offset(sunX + sunR * 0.7 * cos(angle),
            sunY + sunR * 0.7 * sin(angle)),
        Offset(sunX + sunR * cos(angle), sunY + sunR * sin(angle)),
        rayPaint,
      );
    }

    final cloudColor = color.withValues(alpha: 0.75);
    final cp = Paint()..style = PaintingStyle.fill;
    cp.color = cloudColor;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx + r * 0.1, cy + r * 0.2),
          width: r * 1.5,
          height: r * 0.6),
      cp,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - r * 0.15, cy + r * 0.05),
          width: r * 0.8,
          height: r * 0.55),
      cp,
    );
  }

  void _paintRain(Canvas canvas, double cx, double cy, double r) {
    _paintCloud(canvas, cx, cy - r * 0.15, r * 0.9);

    final dropPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = max(1, r * 0.07)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final dx = cx - r * 0.4 + i * r * 0.27;
      final phase = animationValue * 2 * pi + i * 1.2;
      final yOffset = (sin(phase) + 1) * r * 0.12;
      final dropLen = r * 0.3;
      canvas.drawLine(
        Offset(dx, cy + r * 0.3 + yOffset),
        Offset(dx - r * 0.06, cy + r * 0.3 + dropLen + yOffset),
        dropPaint,
      );
    }
  }

  void _paintDrizzle(Canvas canvas, double cx, double cy, double r) {
    _paintCloud(canvas, cx, cy - r * 0.15, r * 0.9);

    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final dx = cx - r * 0.35 + i * r * 0.18;
      final phase = animationValue * 2 * pi + i * 0.8;
      final yOff = (sin(phase) + 1) * r * 0.1;
      canvas.drawCircle(
        Offset(dx, cy + r * 0.3 + yOff),
        max(1, r * 0.04),
        dotPaint,
      );
    }
  }

  void _paintSnow(Canvas canvas, double cx, double cy, double r) {
    _paintCloud(canvas, cx, cy - r * 0.15, r * 0.9);

    final snowPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final dx = cx - r * 0.3 + i * r * 0.22;
      final phase = animationValue * 2 * pi + i * 1.5;
      final yOff = (sin(phase) + 1) * r * 0.12;
      final xDrift = sin(phase * 0.7) * r * 0.08;
      canvas.drawCircle(
        Offset(dx + xDrift, cy + r * 0.3 + yOff),
        max(1.5, r * 0.06),
        snowPaint,
      );
    }
  }

  void _paintStorm(Canvas canvas, double cx, double cy, double r) {
    _paintCloud(canvas, cx, cy - r * 0.15, r * 0.9);

    final flashPhase = animationValue * 4 * pi;
    final flashAlpha = (sin(flashPhase) > 0.8) ? 0.9 : 0.0;

    if (flashAlpha > 0) {
      final boltPaint = Paint()
        ..color = color.withValues(alpha: flashAlpha)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(cx + r * 0.05, cy + r * 0.15)
        ..lineTo(cx - r * 0.12, cy + r * 0.45)
        ..lineTo(cx + r * 0.02, cy + r * 0.42)
        ..lineTo(cx - r * 0.08, cy + r * 0.7)
        ..lineTo(cx + r * 0.18, cy + r * 0.35)
        ..lineTo(cx + r * 0.05, cy + r * 0.38)
        ..close();
      canvas.drawPath(path, boltPaint);
    }
  }

  void _paintFog(Canvas canvas, double cx, double cy, double r) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = max(2, r * 0.1)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final y = cy - r * 0.4 + i * r * 0.28;
      final wobble = sin(animationValue * 2 * pi + i * 0.8) * r * 0.06;
      final w = r * (1.0 + i * 0.1);
      canvas.drawLine(
        Offset(cx - w / 2 + wobble, y),
        Offset(cx + w / 2 + wobble, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(WeatherIconPainter old) =>
      old.animationValue != animationValue || old.code != code;
}

// ══════════════════════════════════════════════════════════════════════
//  DYNAMIC GRADIENT BACKGROUNDS — Theme-aware
// ══════════════════════════════════════════════════════════════════════

class WeatherBackground {
  /// Returns gradient colors from the WeatherThemeExtension.
  /// Always prefer this over getGradient() for new code.
  static List<Color> fromContext(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    return wt?.backgroundGradient ?? getGradient(condition: 'clear', isNight: true, timeOfDay: 12);
  }

  static Color glowFromContext(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    return wt?.conditionGlow ?? getConditionGlow('clear', true);
  }

  static List<Color> getGradient({
    required String condition,
    required bool isNight,
    required double timeOfDay,
  }) {
    if (condition == 'rainy' || condition == 'stormy') {
      if (isNight) {
        return const [
          Color(0xFF070D1A),
          Color(0xFF0E1829),
          Color(0xFF14203A),
        ];
      }
      return const [
        Color(0xFF141E35),
        Color(0xFF1A2A48),
        Color(0xFF1E3050),
      ];
    }

    if (condition == 'snowy') {
      return const [
        Color(0xFF2A3A58),
        Color(0xFF3A4E6E),
        Color(0xFF4A5E7E),
      ];
    }

    if (condition == 'foggy') {
      return const [
        Color(0xFF1E2838),
        Color(0xFF283444),
        Color(0xFF323E4E),
      ];
    }

    if (condition == 'cloudy') {
      if (isNight) {
        return const [
          Color(0xFF0A1020),
          Color(0xFF101828),
          Color(0xFF162035),
        ];
      }
      return const [
        Color(0xFF182844),
        Color(0xFF1E3050),
        Color(0xFF243858),
      ];
    }

    if (isNight) {
      return const [
        Color(0xFF060A18),
        Color(0xFF0C1228),
        Color(0xFF121A35),
      ];
    }

    if (timeOfDay >= 5.0 && timeOfDay < 7.5) {
      return const [
        Color(0xFF2A1548),
        Color(0xFF5A2A60),
        Color(0xFFC87040),
      ];
    }
    if (timeOfDay >= 7.5 && timeOfDay < 12.0) {
      return const [
        Color(0xFF1040A0),
        Color(0xFF1A5ADF),
        Color(0xFF4A95FF),
      ];
    }
    if (timeOfDay >= 12.0 && timeOfDay < 17.0) {
      return const [
        Color(0xFF1530A0),
        Color(0xFF1A5ADF),
        Color(0xFF60B5FF),
      ];
    }
    if (timeOfDay >= 17.0 && timeOfDay < 19.5) {
      return const [
        Color(0xFF2E1260),
        Color(0xFF7A2858),
        Color(0xFFD07038),
      ];
    }

    return const [
      Color(0xFF0A1220),
      Color(0xFF101A30),
      Color(0xFF182240),
    ];
  }

  static Color getConditionGlow(String condition, bool isNight) {
    switch (condition) {
      case 'rainy':
        return const Color(0xFF3A6FA0).withValues(alpha: 0.3);
      case 'stormy':
        return const Color(0xFF5A7AC0).withValues(alpha: 0.25);
      case 'snowy':
        return const Color(0xFF8AA0C0).withValues(alpha: 0.2);
      case 'cloudy':
        return const Color(0xFF6080A0).withValues(alpha: 0.15);
      default:
        if (isNight) {
          return const Color(0xFF2A3060).withValues(alpha: 0.2);
        }
        return const Color(0xFFFFB040).withValues(alpha: 0.15);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
//  SUNRISE ARC PAINTER — Enhanced with sky gradient + golden sun
// ══════════════════════════════════════════════════════════════════════

class SunriseArcPainter extends CustomPainter {
  final double progress;
  final double animationValue;

  SunriseArcPainter({
    required this.progress,
    this.animationValue = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 4;
    final radius = size.width * 0.44;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.white.withValues(alpha: 0.1);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      pi,
      pi,
      false,
      trackPaint,
    );

    final skyRect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0x10FFB040),
          const Color(0x20FF8020),
        ],
      ).createShader(skyRect);
    canvas.save();
    canvas.clipPath(Path()..addArc(skyRect, pi, pi * progress));
    canvas.drawRect(
        Rect.fromLTRB(0, cy - radius, size.width, cy + 5), skyPaint);
    canvas.restore();

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFFD60A),
          const Color(0xFFFF9F0A),
          const Color(0xFFFF6B35),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      pi,
      pi * progress,
      false,
      activePaint,
    );

    if (progress > 0.01 && progress < 0.99) {
      final dotAngle = pi + pi * progress;
      final dotX = cx + radius * cos(dotAngle);
      final dotY = cy + radius * sin(dotAngle);

      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x60FFCC00),
            const Color(0x20FFCC00),
            Colors.transparent,
          ],
        ).createShader(
            Rect.fromCircle(center: Offset(dotX, dotY), radius: 14));
      canvas.drawCircle(Offset(dotX, dotY), 14, glowPaint);

      final pulseR = 4 + sin(animationValue * pi * 4) * 0.8;
      final dotPaint = Paint()..color = const Color(0xFFFFD60A);
      canvas.drawCircle(Offset(dotX, dotY), pulseR, dotPaint);

      final corePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(dotX, dotY), pulseR * 0.4, corePaint);
    }
  }

  @override
  bool shouldRepaint(SunriseArcPainter old) =>
      old.progress != progress || old.animationValue != animationValue;
}

// ══════════════════════════════════════════════════════════════════════
//  WIND COMPASS PAINTER
// ══════════════════════════════════════════════════════════════════════

class WindCompassPainter extends CustomPainter {
  final double direction;
  final double animationValue;

  WindCompassPainter({
    required this.direction,
    this.animationValue = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(size.width, size.height) * 0.42;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(Offset(cx, cy), r, ringPaint);

    final innerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(cx, cy), r * 0.7, innerRingPaint);

    final tickPaint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final minorTickPaint = Paint()
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 36; i++) {
      final angle = (i * 10 * pi / 180) - pi / 2;
      final isMajor = i % 9 == 0;
      final innerR = isMajor ? r * 0.88 : r * 0.93;
      final outerR = r;

      tickPaint.color = isMajor
          ? Colors.white.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.15);

      canvas.drawLine(
        Offset(cx + innerR * cos(angle), cy + innerR * sin(angle)),
        Offset(cx + outerR * cos(angle), cy + outerR * sin(angle)),
        isMajor ? tickPaint : minorTickPaint,
      );
    }

    final labelPaint = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    const dirs = ['N', 'E', 'S', 'W'];
    final dirAngles = [-pi / 2, 0, pi / 2, pi];

    for (int i = 0; i < 4; i++) {
      final angle = dirAngles[i];
      final labelR = r * 0.76;
      labelPaint.text = TextSpan(
        text: dirs[i],
        style: TextStyle(
          color: Colors.white.withValues(alpha: i == 0 ? 0.8 : 0.4),
          fontSize: max(8, r * 0.14),
          fontFamily: i == 0 ? FontFamily.semiBold : FontFamily.medium,
        ),
      );
      labelPaint.layout();
      labelPaint.paint(
        canvas,
        Offset(
          cx + labelR * cos(angle) - labelPaint.width / 2,
          cy + labelR * sin(angle) - labelPaint.height / 2,
        ),
      );
    }

    final needleAngle = direction * pi / 180 - pi / 2;
    final wobble = sin(animationValue * pi * 3) * 0.02;
    final finalAngle = needleAngle + wobble;

    final needleLen = r * 0.55;
    final tailLen = r * 0.18;

    final needlePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFF375F),
          const Color(0xFFFF6B6B),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - 2, cy - needleLen, 4, needleLen))
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + needleLen * cos(finalAngle), cy + needleLen * sin(finalAngle)),
      needlePaint,
    );

    final tailPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + tailLen * cos(finalAngle + pi),
          cy + tailLen * sin(finalAngle + pi)),
      tailPaint,
    );

    final centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x40FF375F),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 6));
    canvas.drawCircle(Offset(cx, cy), 6, centerGlow);

    final centerDot = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 3, centerDot);
  }

  @override
  bool shouldRepaint(WindCompassPainter old) =>
      old.direction != direction || old.animationValue != animationValue;
}

// ══════════════════════════════════════════════════════════════════════
//  UV GRADIENT ARC PAINTER
// ══════════════════════════════════════════════════════════════════════

class UvArcPainter extends CustomPainter {
  final double uvValue;
  final double maxUv;

  UvArcPainter({required this.uvValue, this.maxUv = 12});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.85;
    final radius = size.width * 0.4;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      pi * 0.8,
      pi * 1.4,
      false,
      trackPaint,
    );

    final segments = [
      [0.0, 0.17, const Color(0xFF34C759), const Color(0xFF5AC8FA)],
      [0.17, 0.33, const Color(0xFFFFCC00), const Color(0xFFFF9500)],
      [0.33, 0.5, const Color(0xFFFF9500), const Color(0xFFFF6B35)],
      [0.5, 0.67, const Color(0xFFFF3B30), const Color(0xFFFF453A)],
      [0.67, 1.0, const Color(0xFFAF52DE), const Color(0xFFBF5AF2)],
    ];

    final fraction = (uvValue / maxUv).clamp(0.0, 1.0);

    for (final seg in segments) {
      final start = seg[0] as double;
      final end = seg[1] as double;
      final startColor = seg[2] as Color;
      final endColor = seg[3] as Color;

      if (fraction <= start) break;

      final segStart = max(start, 0.0);
      final segEnd = min(end, fraction);

      final segPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [startColor, endColor],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

      final arcStart = pi * 0.8 + pi * 1.4 * segStart;
      final arcSweep = pi * 1.4 * (segEnd - segStart);

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        arcStart,
        arcSweep,
        false,
        segPaint,
      );
    }

    final needleAngle = pi * 0.8 + pi * 1.4 * fraction;
    final needleX = cx + (radius + 12) * cos(needleAngle);
    final needleY = cy + (radius + 12) * sin(needleAngle);

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(needleX, needleY), 4, dotPaint);

    final dotGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromCircle(center: Offset(needleX, needleY), radius: 8));
    canvas.drawCircle(Offset(needleX, needleY), 8, dotGlow);
  }

  @override
  bool shouldRepaint(UvArcPainter old) => old.uvValue != uvValue;
}

// ══════════════════════════════════════════════════════════════════════
//  PRESSURE GAUGE PAINTER
// ══════════════════════════════════════════════════════════════════════

class PressureGaugePainter extends CustomPainter {
  final double pressure;
  final double minPressure;
  final double maxPressure;

  PressureGaugePainter({
    required this.pressure,
    this.minPressure = 960,
    this.maxPressure = 1060,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.5;
    final r = min(size.width, size.height) * 0.38;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.1);
    canvas.drawCircle(Offset(cx, cy), r, ringPaint);

    final fraction =
        ((pressure - minPressure) / (maxPressure - minPressure)).clamp(0.0, 1.0);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF5E5CE6),
          const Color(0xFF64D2FF),
          const Color(0xFF34C759),
          const Color(0xFFFFCC00),
          const Color(0xFFFF453A),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      pi * 2 * fraction,
      false,
      arcPaint,
    );

    for (int i = 0; i < 20; i++) {
      final angle = -pi / 2 + (i / 20) * pi * 2;
      final innerR = r * 0.82;
      final outerR = r * 0.92;
      final isMajor = i % 5 == 0;
      final tickPaint = Paint()
        ..color = Colors.white
            .withValues(alpha: isMajor ? 0.3 : 0.1)
        ..strokeWidth = isMajor ? 1.5 : 0.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx + innerR * cos(angle), cy + innerR * sin(angle)),
        Offset(cx + outerR * cos(angle), cy + outerR * sin(angle)),
        tickPaint,
      );
    }

    final needleAngle = -pi / 2 + pi * 2 * fraction;
    final needleLen = r * 0.7;
    final needlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + needleLen * cos(needleAngle), cy + needleLen * sin(needleAngle)),
      needlePaint,
    );

    final centerDot = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 3, centerDot);
  }

  @override
  bool shouldRepaint(PressureGaugePainter old) =>
      old.pressure != pressure;
}

// ══════════════════════════════════════════════════════════════════════
//  HUMIDITY LIQUID FILL PAINTER
// ══════════════════════════════════════════════════════════════════════

class HumidityWavePainter extends CustomPainter {
  final double humidity;
  final double animationValue;

  HumidityWavePainter({
    required this.humidity,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fraction = (humidity / 100).clamp(0.0, 1.0);
    final waterLevel = size.height * (1 - fraction);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    canvas.save();
    canvas.clipRRect(rrect);

    final bgPaint = Paint()
      ..color = const Color(0xFF0A2E4A).withValues(alpha: 0.4);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF32D74B).withValues(alpha: 0.4),
          const Color(0xFF5E5CE6).withValues(alpha: 0.6),
        ],
      ).createShader(Rect.fromLTWH(
          0, waterLevel, size.width, size.height - waterLevel));

    final wavePath = Path();
    wavePath.moveTo(0, size.height);
    wavePath.lineTo(0, waterLevel);

    for (double x = 0; x <= size.width; x += 2) {
      final y = waterLevel +
          sin((x / size.width * 2 * pi) + animationValue * pi * 4) * 3 +
          sin((x / size.width * 4 * pi) + animationValue * pi * 6) * 1.5;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.close();
    canvas.drawPath(wavePath, wavePaint);

    final wave2Paint = Paint()
      ..color = const Color(0xFF32D74B).withValues(alpha: 0.2);
    final wave2Path = Path();
    wave2Path.moveTo(0, size.height);
    wave2Path.lineTo(0, waterLevel + 4);

    for (double x = 0; x <= size.width; x += 2) {
      final y = waterLevel +
          4 +
          sin((x / size.width * 2 * pi) + animationValue * pi * 4 + 1) * 2;
      wave2Path.lineTo(x, y);
    }

    wave2Path.lineTo(size.width, size.height);
    wave2Path.close();
    canvas.drawPath(wave2Path, wave2Paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(HumidityWavePainter old) =>
      old.humidity != humidity || old.animationValue != animationValue;
}

// ══════════════════════════════════════════════════════════════════════
//  PRECIPITATION FILL GAUGE PAINTER
// ══════════════════════════════════════════════════════════════════════

class PrecipitationFillPainter extends CustomPainter {
  final double percentage;
  final double animationValue;

  PrecipitationFillPainter({
    required this.percentage,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fraction = (percentage / 100).clamp(0.0, 1.0);
    final fillHeight = size.height * fraction;
    final top = size.height - fillHeight;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );

    canvas.save();
    canvas.clipRRect(rrect);

    canvas.drawRRect(
      rrect,
      Paint()..color = const Color(0xFF0A1E3A).withValues(alpha: 0.3),
    );

    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF5AC8FA).withValues(alpha: 0.5),
          const Color(0xFF3A6FA0).withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromLTWH(0, top, size.width, fillHeight));

    final wavePath = Path();
    wavePath.moveTo(0, size.height);
    wavePath.lineTo(0, top);

    for (double x = 0; x <= size.width; x += 2) {
      final y = top +
          sin((x / size.width * 3 * pi) + animationValue * pi * 5) * 2;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.close();
    canvas.drawPath(wavePath, waterPaint);

    final dropPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      final dx = size.width * 0.2 + i * size.width * 0.3;
      final phase = animationValue * 2 * pi + i * 2;
      final dropY = top - 5 + sin(phase) * 4;
      if (dropY > 0 && dropY < top) {
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(dx, dropY),
              width: 2,
              height: 4),
          dropPaint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(PrecipitationFillPainter old) =>
      old.percentage != percentage || old.animationValue != animationValue;
}

// ══════════════════════════════════════════════════════════════════════
//  VISIBILITY MOUNTAIN PAINTER
// ══════════════════════════════════════════════════════════════════════

class VisibilityMountainPainter extends CustomPainter {
  final double visibilityKm;

  VisibilityMountainPainter({required this.visibilityKm});

  @override
  void paint(Canvas canvas, Size size) {
    final fogOpacity = (1 - (visibilityKm / 20).clamp(0.0, 1.0)) * 0.6;

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1A2848).withValues(alpha: 0.3),
          const Color(0xFF2A3A58).withValues(alpha: 0.5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    _drawMountain(canvas, size, [
      const Color(0xFF1A2540),
      const Color(0xFF243050),
    ], 0.7, 0.55, 0.3);

    _drawMountain(canvas, size, [
      const Color(0xFF222E48),
      const Color(0xFF2A3A58),
    ], 0.8, 0.65, 0.5);

    _drawMountain(canvas, size, [
      const Color(0xFF2A3858),
      const Color(0xFF354568),
    ], 0.9, 0.75, 0.7);

    if (fogOpacity > 0) {
      final fogPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: fogOpacity * 0.3),
            Colors.white.withValues(alpha: fogOpacity),
            Colors.white.withValues(alpha: fogOpacity * 0.5),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fogPaint);
    }
  }

  void _drawMountain(
    Canvas canvas,
    Size size,
    List<Color> colors,
    double heightFrac,
    double leftPeak,
    double rightPeak,
  ) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * (1 - heightFrac * 0.3));
    path.lineTo(size.width * leftPeak, size.height * (1 - heightFrac));
    path.lineTo(size.width * 0.5, size.height * (1 - heightFrac * 0.6));
    path.lineTo(size.width * rightPeak, size.height * (1 - heightFrac * 0.85));
    path.lineTo(size.width, size.height * (1 - heightFrac * 0.2));
    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(VisibilityMountainPainter old) =>
      old.visibilityKm != visibilityKm;
}

// ══════════════════════════════════════════════════════════════════════
//  FEELS LIKE THERMOMETER PAINTER
// ══════════════════════════════════════════════════════════════════════

class FeelsLikePainter extends CustomPainter {
  final double actualTemp;
  final double feelsTemp;
  final double minTemp;
  final double maxTemp;

  FeelsLikePainter({
    required this.actualTemp,
    required this.feelsTemp,
    required this.minTemp,
    required this.maxTemp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final range = maxTemp - minTemp;
    if (range <= 0) return;

    final barY = size.height * 0.5;
    final barHeight = 6.0;
    final barLeft = size.width * 0.1;
    final barWidth = size.width * 0.8;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = barHeight
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(barLeft, barY),
      Offset(barLeft + barWidth, barY),
      bgPaint,
    );

    final actualX =
        barLeft + ((actualTemp - minTemp) / range) * barWidth;
    final feelsX =
        barLeft + ((feelsTemp - minTemp) / range) * barWidth;

    final actualPaint = Paint()
      ..color = const Color(0xFF5E5CE6)
      ..strokeWidth = barHeight
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(actualX - 3, barY),
      Offset(actualX + 3, barY),
      actualPaint,
    );

    final feelsPaint = Paint()
      ..color = const Color(0xFFFF9F0A)
      ..strokeWidth = barHeight
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(feelsX - 3, barY),
      Offset(feelsX + 3, barY),
      feelsPaint,
    );

    canvas.drawCircle(Offset(actualX, barY), 5, actualPaint);
    canvas.drawCircle(Offset(feelsX, barY), 5, feelsPaint);
  }

  @override
  bool shouldRepaint(FeelsLikePainter old) =>
      old.actualTemp != actualTemp || old.feelsTemp != feelsTemp;
}

// ══════════════════════════════════════════════════════════════════════
//  AIR QUALITY RING PAINTER
// ══════════════════════════════════════════════════════════════════════

class AirQualityRingPainter extends CustomPainter {
  final double aqi;

  AirQualityRingPainter({required this.aqi});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(size.width, size.height) * 0.38;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(Offset(cx, cy), r, trackPaint);

    final fraction = (aqi / 300).clamp(0.0, 1.0);
    final color = _aqiColor(aqi);

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.6), color],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      pi * 2 * fraction,
      false,
      activePaint,
    );
  }

  Color _aqiColor(double aqi) {
    if (aqi <= 50) return const Color(0xFF34C759);
    if (aqi <= 100) return const Color(0xFFFFCC00);
    if (aqi <= 150) return const Color(0xFFFF9500);
    if (aqi <= 200) return const Color(0xFFFF3B30);
    return const Color(0xFFAF52DE);
  }

  @override
  bool shouldRepaint(AirQualityRingPainter old) => old.aqi != aqi;
}

// ══════════════════════════════════════════════════════════════════════
//  UTILITY: WMO code to icon code mapping (same logic as view)
// ══════════════════════════════════════════════════════════════════════

IconData weatherCodeToIcon(int code) {
  if (code == 0) return Icons.wb_sunny_rounded;
  if (code <= 3) return Icons.cloud_queue_rounded;
  if (code <= 48) return Icons.cloud;
  if (code <= 57) return Icons.grain;
  if (code <= 67) return Icons.umbrella;
  if (code <= 77) return Icons.ac_unit;
  if (code <= 82) return Icons.umbrella;
  if (code <= 86) return Icons.ac_unit;
  if (code <= 99) return Icons.flash_on;
  return Icons.cloud;
}
