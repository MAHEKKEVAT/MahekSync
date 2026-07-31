import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maheksync/app/theme/weather_theme.dart';

class WeatherParticles extends StatefulWidget {
  final bool isRainy;
  final bool isSnowy;
  final bool isNight;
  final bool isClear;

  const WeatherParticles({
    super.key,
    this.isRainy = false,
    this.isSnowy = false,
    this.isNight = false,
    this.isClear = false,
  });

  @override
  State<WeatherParticles> createState() => _WeatherParticlesState();
}

class _WeatherParticlesState extends State<WeatherParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _rainDrops = <_RainDrop>[];
  final _snowFlakes = <_SnowFlake>[];
  final _stars = <_Star>[];
  final _clouds = <_Cloud>[];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    _rainDrops.clear();
    _snowFlakes.clear();
    _stars.clear();
    _clouds.clear();

    if (widget.isRainy) {
      for (int i = 0; i < 60; i++) {
        _rainDrops.add(_RainDrop(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          speed: 0.04 + _rng.nextDouble() * 0.06,
          length: 15 + _rng.nextDouble() * 20,
          opacity: 0.15 + _rng.nextDouble() * 0.25,
          width: 0.6 + _rng.nextDouble() * 0.6,
        ));
      }
    }
    if (widget.isSnowy) {
      for (int i = 0; i < 40; i++) {
        _snowFlakes.add(_SnowFlake(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          speed: 0.003 + _rng.nextDouble() * 0.006,
          drift: 0.002 + _rng.nextDouble() * 0.005,
          size: 1.5 + _rng.nextDouble() * 2.5,
          opacity: 0.2 + _rng.nextDouble() * 0.3,
        ));
      }
    }
    if (widget.isNight) {
      for (int i = 0; i < 50; i++) {
        _stars.add(_Star(
          x: _rng.nextDouble(),
          y: _rng.nextDouble() * 0.5,
          size: 0.4 + _rng.nextDouble() * 1.2,
          baseOpacity: 0.2 + _rng.nextDouble() * 0.4,
          twinkleSpeed: 0.5 + _rng.nextDouble() * 2.0,
          twinkleOffset: _rng.nextDouble() * 2 * pi,
        ));
      }
    }
    if (widget.isRainy || widget.isSnowy) {
      for (int i = 0; i < 3; i++) {
        _clouds.add(_Cloud(
          x: -0.2 + _rng.nextDouble() * 1.4,
          y: 0.05 + _rng.nextDouble() * 0.25,
          width: 0.3 + _rng.nextDouble() * 0.3,
          speed: 0.001 + _rng.nextDouble() * 0.002,
          opacity: 0.04 + _rng.nextDouble() * 0.06,
        ));
      }
    }
  }

  @override
  void didUpdateWidget(WeatherParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRainy != widget.isRainy ||
        oldWidget.isSnowy != widget.isSnowy ||
        oldWidget.isNight != widget.isNight ||
        oldWidget.isClear != widget.isClear) {
      _initParticles();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyParticles = widget.isRainy || widget.isSnowy || widget.isNight;
    if (!hasAnyParticles && !widget.isClear) {
      return const SizedBox.shrink();
    }

    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final particleColor = wt?.particleColor ?? Colors.white;
    final cloudColor = wt?.cloudColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (final d in _rainDrops) {
          d.y += d.speed;
          d.x -= d.speed * 0.12;
          if (d.y > 1.1 || d.x < -0.1) {
            d.y = -0.05 - _rng.nextDouble() * 0.1;
            d.x = _rng.nextDouble();
          }
        }
        for (final s in _snowFlakes) {
          s.y += s.speed;
          s.x += sin(_controller.value * 3 * pi + s.y * 8) * s.drift;
          if (s.y > 1.1) {
            s.y = -0.05;
            s.x = _rng.nextDouble();
          }
        }
        for (final c in _clouds) {
          c.x += c.speed;
          if (c.x > 1.3) c.x = -0.4;
        }
        return CustomPaint(
          willChange: true,
          painter: _ParticlePainter(
            rainDrops: _rainDrops,
            snowFlakes: _snowFlakes,
            stars: _stars,
            clouds: _clouds,
            animValue: _controller.value,
            isNight: widget.isNight,
            isClear: widget.isClear,
            particleColor: particleColor,
            cloudColor: cloudColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RainDrop {
  double x, y, speed, length, opacity, width;
  _RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.opacity,
    required this.width,
  });
}

class _SnowFlake {
  double x, y, speed, drift, size, opacity;
  _SnowFlake({
    required this.x,
    required this.y,
    required this.speed,
    required this.drift,
    required this.size,
    required this.opacity,
  });
}

class _Star {
  double x, y, size, baseOpacity, twinkleSpeed, twinkleOffset;
  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.baseOpacity,
    required this.twinkleSpeed,
    required this.twinkleOffset,
  });
}

class _Cloud {
  double x, y, width, speed, opacity;
  _Cloud({
    required this.x,
    required this.y,
    required this.width,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_RainDrop> rainDrops;
  final List<_SnowFlake> snowFlakes;
  final List<_Star> stars;
  final List<_Cloud> clouds;
  final double animValue;
  final bool isNight;
  final bool isClear;
  final Color particleColor;
  final Color cloudColor;

  _ParticlePainter({
    required this.rainDrops,
    required this.snowFlakes,
    required this.stars,
    required this.clouds,
    required this.animValue,
    required this.isNight,
    required this.isClear,
    required this.particleColor,
    required this.cloudColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    _paintClouds(canvas, size);

    if (isNight) _paintStars(canvas, size);
    if (isNight) _paintMoon(canvas, size);
    if (isClear && !isNight) _paintSunGlow(canvas, size);

    final rainPaint = Paint()..strokeCap = StrokeCap.round;
    for (final d in rainDrops) {
      final x = d.x * size.width;
      final y = d.y * size.height;
      rainPaint
        ..strokeWidth = d.width
        ..color = particleColor.withValues(alpha: d.opacity);
      canvas.drawLine(
        Offset(x, y),
        Offset(x - d.length * 0.15, y + d.length),
        rainPaint,
      );
    }

    final snowPaint = Paint()..style = PaintingStyle.fill;
    for (final s in snowFlakes) {
      final x = s.x * size.width;
      final y = s.y * size.height;
      snowPaint.color = particleColor.withValues(alpha: s.opacity);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: s.size * 0.7, height: s.size),
        snowPaint,
      );
    }
  }

  void _paintClouds(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final c in clouds) {
      final x = c.x * size.width;
      final y = c.y * size.height;
      final w = c.width * size.width;
      paint.color = cloudColor.withValues(alpha: c.opacity);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: w, height: w * 0.35),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + w * 0.25, y - w * 0.08), width: w * 0.6, height: w * 0.3),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x - w * 0.2, y + w * 0.05), width: w * 0.5, height: w * 0.25),
        paint,
      );
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final twinkle = (sin(animValue * 2 * pi * s.twinkleSpeed + s.twinkleOffset) + 1) / 2;
      final opacity = s.baseOpacity * (0.3 + 0.7 * twinkle);
      final x = s.x * size.width;
      final y = s.y * size.height;
      paint.color = particleColor.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), s.size, paint);
    }
  }

  void _paintMoon(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.82, size.height * 0.06);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          particleColor.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 60));
    canvas.drawCircle(center, 60, glowPaint);

    final bodyPaint = Paint()..color = particleColor.withValues(alpha: 0.2);
    canvas.drawCircle(center, 14, bodyPaint);
  }

  void _paintSunGlow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.85, size.height * 0.05);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          particleColor.withValues(alpha: 0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 50));
    canvas.drawCircle(center, 50, glowPaint);
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
