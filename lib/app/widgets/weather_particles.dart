import 'dart:math';
import 'package:flutter/material.dart';

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

    if (widget.isRainy) {
      for (int i = 0; i < 120; i++) {
        _rainDrops.add(_RainDrop(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          speed: 0.03 + _rng.nextDouble() * 0.05,
          length: 12 + _rng.nextDouble() * 18,
          opacity: 0.25 + _rng.nextDouble() * 0.35,
          width: 0.8 + _rng.nextDouble() * 0.8,
        ));
      }
    }
    if (widget.isSnowy) {
      for (int i = 0; i < 80; i++) {
        _snowFlakes.add(_SnowFlake(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          speed: 0.004 + _rng.nextDouble() * 0.008,
          drift: 0.003 + _rng.nextDouble() * 0.006,
          size: 1.5 + _rng.nextDouble() * 3.0,
          opacity: 0.3 + _rng.nextDouble() * 0.4,
        ));
      }
    }
    if (widget.isNight) {
      for (int i = 0; i < 60; i++) {
        _stars.add(_Star(
          x: _rng.nextDouble(),
          y: _rng.nextDouble() * 0.6,
          size: 0.5 + _rng.nextDouble() * 1.5,
          baseOpacity: 0.3 + _rng.nextDouble() * 0.5,
          twinkleSpeed: 0.5 + _rng.nextDouble() * 2.0,
          twinkleOffset: _rng.nextDouble() * 2 * pi,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (final d in _rainDrops) {
          d.y += d.speed;
          d.x -= d.speed * 0.15;
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
        return CustomPaint(
          willChange: true,
          painter: _ParticlePainter(
            rainDrops: _rainDrops,
            snowFlakes: _snowFlakes,
            stars: _stars,
            animValue: _controller.value,
            isNight: widget.isNight,
            isClear: widget.isClear,
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

class _ParticlePainter extends CustomPainter {
  final List<_RainDrop> rainDrops;
  final List<_SnowFlake> snowFlakes;
  final List<_Star> stars;
  final double animValue;
  final bool isNight;
  final bool isClear;

  _ParticlePainter({
    required this.rainDrops,
    required this.snowFlakes,
    required this.stars,
    required this.animValue,
    required this.isNight,
    required this.isClear,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (isNight) _paintStars(canvas, size);
    if (isNight) _paintMoonGlow(canvas, size);
    if (isClear && !isNight) _paintSunRays(canvas, size);

    final rainPaint = Paint()..strokeCap = StrokeCap.round;
    for (final d in rainDrops) {
      final x = d.x * size.width;
      final y = d.y * size.height;
      rainPaint
        ..strokeWidth = d.width
        ..color = Colors.white.withValues(alpha: d.opacity);
      canvas.drawLine(
        Offset(x, y),
        Offset(x - d.length * 0.2, y + d.length),
        rainPaint,
      );
    }

    final snowPaint = Paint()..style = PaintingStyle.fill;
    for (final s in snowFlakes) {
      final x = s.x * size.width;
      final y = s.y * size.height;
      snowPaint.color = Colors.white.withValues(alpha: s.opacity);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: s.size * 0.8, height: s.size),
        snowPaint,
      );
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final twinkle = (sin(animValue * 2 * pi * s.twinkleSpeed + s.twinkleOffset) + 1) / 2;
      final opacity = s.baseOpacity * (0.4 + 0.6 * twinkle);
      final x = s.x * size.width;
      final y = s.y * size.height;
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), s.size, paint);
    }
  }

  void _paintMoonGlow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.82, size.height * 0.08);
    final moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x15FFFFFF),
          const Color(0x08FFFFFF),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 80));
    canvas.drawCircle(center, 80, moonPaint);

    final moonBodyPaint = Paint()..color = const Color(0x30FFFFFF);
    canvas.drawCircle(center, 16, moonBodyPaint);
  }

  void _paintSunRays(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.85, size.height * 0.06);
    final rayPaint = Paint()
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (animValue * 0.3);
      final innerR = 30.0;
      final outerR = 60.0 + sin(animValue * 2 * pi + i) * 10;
      final opacity = 0.06 + sin(animValue * 2 * pi + i * 0.7) * 0.03;
      rayPaint.color = const Color(0xFFFFF3E0).withValues(alpha: opacity);
      canvas.drawLine(
        Offset(center.dx + cos(angle) * innerR, center.dy + sin(angle) * innerR),
        Offset(center.dx + cos(angle) * outerR, center.dy + sin(angle) * outerR),
        rayPaint,
      );
    }

    final sunGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x0AFFF8E1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 50));
    canvas.drawCircle(center, 50, sunGlowPaint);
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
