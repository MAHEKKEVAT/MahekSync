import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/sunrise_sunset_service.dart';

class DashboardHeroSection extends StatefulWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final VoidCallback? onViewPlan;

  const DashboardHeroSection({
    super.key,
    required this.controller,
    required this.isDark,
    this.onViewPlan,
  });

  @override
  State<DashboardHeroSection> createState() => _DashboardHeroSectionState();
}

class _DashboardHeroSectionState extends State<DashboardHeroSection> {
  SunriseSunsetResult? _sunTimes;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSunTimes();
  }

  Future<void> _loadSunTimes() async {
    final result = await SunriseSunsetService.fetch();
    if (mounted) {
      setState(() {
        _sunTimes = result;
        _loaded = true;
      });
    }
  }

  bool get _isNight {
    final now = DateTime.now();
    if (_sunTimes == null) {
      final h = now.hour;
      return h >= 20 || h < 6;
    }
    final sunrise = _sunTimes!.sunrise;
    final sunset = _sunTimes!.sunset;
    final nightStart = sunset.add(const Duration(minutes: 30));
    final nightEnd = sunrise.subtract(const Duration(minutes: 30));
    if (nightStart.isAfter(nightEnd)) {
      return now.isAfter(nightStart) || now.isBefore(nightEnd);
    }
    return now.isAfter(nightStart) || now.isBefore(nightEnd);
  }

  String _getTimePeriod() {
    final now = DateTime.now();
    if (_sunTimes == null) {
      final h = now.hour;
      if (h < 6 || h >= 20) return 'night';
      if (h < 12) return 'morning';
      if (h < 17) return 'afternoon';
      return 'evening';
    }
    final sunrise = _sunTimes!.sunrise;
    final sunset = _sunTimes!.sunset;
    if (now.isBefore(sunrise) || now.isAfter(sunset.add(const Duration(minutes: 30)))) {
      return 'night';
    }
    final sunrisePlus4 = sunrise.add(const Duration(hours: 4));
    final sunsetMinus2 = sunset.subtract(const Duration(hours: 2));
    if (now.isBefore(sunrise.add(const Duration(minutes: 30)))) return 'dawn';
    if (now.isBefore(sunrisePlus4)) return 'morning';
    if (now.isBefore(sunsetMinus2)) return 'afternoon';
    if (now.isBefore(sunset)) return 'evening';
    return 'night';
  }

  String _getSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'summer';
    if (month >= 6 && month <= 9) return 'monsoon';
    return 'winter';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final period = _loaded ? _getTimePeriod() : (hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : hour < 20 ? 'evening' : 'night');
    final isNight = _loaded ? _isNight : (hour >= 20 || hour < 6);
    final season = _getSeason();

    final greeting = isNight
        ? 'Good Night'
        : hour < 12
            ? 'Good Morning'
            : hour < 17
                ? 'Good Afternoon'
                : 'Good Evening';
    final emoji = isNight
        ? '🌙'
        : hour < 12
            ? '☀️'
            : hour < 17
                ? '🌤️'
                : '🌅';
    final fullName = MahekConstant.ownerModel?.fullName ?? 'Mahek Kevat';
    final firstName = fullName.split(' ').first;

    final LinearGradient heroGradient;
    switch (period) {
      case 'dawn':
        heroGradient = const LinearGradient(
          colors: [Color(0xFF1A1040), Color(0xFF4A2080), Color(0xFFFF6B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'morning':
        heroGradient = const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFFFB347), Color(0xFF87CEEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'afternoon':
        heroGradient = const LinearGradient(
          colors: [Color(0xFF4A90D9), Color(0xFF87CEEB), Color(0xFFB8E6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'evening':
        heroGradient = const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFE91E63), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'night':
      default:
        heroGradient = const LinearGradient(
          colors: [Color(0xFF0A0A1A), Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
    }

    final taskPending = widget.controller.pendingTasks;
    final reminderToday = widget.controller.reminderCount.value;
    final toCollect = widget.controller.totalOwedFormatted;
    final dueCount = widget.controller.duesCount.value;
    final progressPercent =
        ((taskPending > 0 ? (taskPending * 0.85) : 85)).clamp(0, 100);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: heroGradient,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D28D9).withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Grid pattern
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter(widget.isDark)),
            ),

            // Season decorations — subtle
            Positioned.fill(
              child: CustomPaint(painter: _SeasonPainter(season: season)),
            ),

            // Night decorations
            if (isNight) ...[
              // Stars
              ...List.generate(20, (i) {
                final rng = math.Random(i);
                return Positioned(
                  left: rng.nextDouble() * 400 + 50,
                  top: rng.nextDouble() * 120 + 10,
                  child: Container(
                    width: rng.nextDouble() * 2 + 1,
                    height: rng.nextDouble() * 2 + 1,
                    decoration: BoxDecoration(
                      color: AppThemeData.primaryWhite
                          .withValues(alpha: rng.nextDouble() * 0.4 + 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),

              // Moon crescent
              Positioned(
                right: 60,
                top: 20,
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: _MoonPainter(),
                ),
              ),

              // Moon glow
              Positioned(
                right: 30,
                top: -10,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFE8D5B7).withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Mountain silhouette
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 80),
                  painter: _MountainPainter(),
                ),
              ),
            ],

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Greeting
                  Text(
                    '$greeting,',
                    style: TextStyle(
                      fontFamily: FontFamily.medium,
                      fontSize: 13,
                      color: AppThemeData.primaryWhite.withValues(alpha: 0.7),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Name
                  Text(
                    '$firstName $emoji',
                    style: TextStyle(
                      fontFamily: FontFamily.bold,
                      fontSize: 26,
                      color: AppThemeData.primaryWhite,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Progress subtitle
                  Text(
                    "You've done $progressPercent% of your daily plan. Rest well and recharge for a better tomorrow.",
                    style: TextStyle(
                      fontFamily: FontFamily.regular,
                      fontSize: 12,
                      color: AppThemeData.primaryWhite.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  // Stats row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        icon: Icons.task_alt_rounded,
                        value: '$taskPending',
                        label: 'Tasks Pending',
                        color: AppThemeData.neonPurple,
                      ),
                      _StatChip(
                        icon: Icons.alarm_rounded,
                        value: '$reminderToday',
                        label: 'Reminders Today',
                        color: AppThemeData.neonOrange,
                      ),
                      _StatChip(
                        icon: Icons.currency_rupee_rounded,
                        value: toCollect,
                        label: 'To Collect',
                        color: AppThemeData.neonMint,
                      ),
                      _StatChip(
                        icon: Icons.receipt_rounded,
                        value: '$dueCount',
                        label: 'Due Payment',
                        color: AppThemeData.danger300,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // CTA Button
                  GestureDetector(
                    onTap: widget.onViewPlan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppThemeData.neonPurple,
                            AppThemeData.neonPurple.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppThemeData.neonPurple.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "View Today's Plan",
                            style: TextStyle(
                              fontFamily: FontFamily.semiBold,
                              fontSize: 12,
                              color: AppThemeData.primaryWhite,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              size: 14, color: AppThemeData.primaryWhite),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppThemeData.primaryWhite.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeData.primaryWhite.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 15,
                  color: AppThemeData.primaryWhite,
                  height: 1.2,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontFamily.regular,
                  fontSize: 10,
                  color: AppThemeData.primaryWhite.withValues(alpha: 0.5),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeasonPainter extends CustomPainter {
  final String season;
  _SeasonPainter({required this.season});

  @override
  void paint(Canvas canvas, Size size) {
    switch (season) {
      case 'summer':
        _paintSummer(canvas, size);
        break;
      case 'monsoon':
        _paintMonsoon(canvas, size);
        break;
      case 'winter':
        _paintWinter(canvas, size);
        break;
    }
  }

  void _paintSummer(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final rng = math.Random(42);
    for (int i = 0; i < 6; i++) {
      final start = Offset(
        size.width * 0.7 + rng.nextDouble() * size.width * 0.3,
        -10,
      );
      final end = Offset(
        start.dx - 40 - rng.nextDouble() * 60,
        size.height * 0.3 + rng.nextDouble() * size.height * 0.4,
      );
      paint.shader = LinearGradient(
        colors: [
          const Color(0xFFFFD700).withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromPoints(start, end));
      canvas.drawLine(start, end, paint);
    }
  }

  void _paintMonsoon(Canvas canvas, Size size) {
    final rng = math.Random(77);
    final rainPaint = Paint()
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final len = 8.0 + rng.nextDouble() * 12.0;
      rainPaint.color = AppThemeData.primaryWhite.withValues(alpha: 0.04 + rng.nextDouble() * 0.03);
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 2, y + len),
        rainPaint,
      );
    }

    final cloudPaint = Paint()
      ..color = AppThemeData.primaryWhite.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.3, 25), width: 80, height: 30),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.3 + 25, 20), width: 60, height: 25),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.75, 18), width: 70, height: 28),
      cloudPaint,
    );
  }

  void _paintWinter(Canvas canvas, Size size) {
    final rng = math.Random(33);
    final snowPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 1.0 + rng.nextDouble() * 1.5;
      snowPaint.color = AppThemeData.primaryWhite.withValues(alpha: 0.06 + rng.nextDouble() * 0.04);
      canvas.drawCircle(Offset(x, y), r, snowPaint);
    }

    final fogPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          AppThemeData.primaryWhite.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height - 40, size.width, 40));
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 40, size.width, 40),
      fogPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SeasonPainter old) => old.season != season;
}

class _MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final moonPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFF5E6C8), Color(0xFFE8D5B7)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, moonPaint);

    final shadowPaint = Paint()..color = const Color(0xFF0A0A1A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.35, center.dy - radius * 0.1),
        width: radius * 1.7,
        height: radius * 1.7,
      ),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0A0A1A).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.15, size.height * 0.2);
    path.lineTo(size.width * 0.25, size.height * 0.35);
    path.lineTo(size.width * 0.4, size.height * 0.1);
    path.lineTo(size.width * 0.55, size.height * 0.3);
    path.lineTo(size.width * 0.65, size.height * 0.15);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width * 0.9, size.height * 0.25);
    path.lineTo(size.width, size.height * 0.45);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = const Color(0xFF1E1B4B).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.65);
    path2.lineTo(size.width * 0.1, size.height * 0.5);
    path2.lineTo(size.width * 0.2, size.height * 0.55);
    path2.lineTo(size.width * 0.35, size.height * 0.35);
    path2.lineTo(size.width * 0.5, size.height * 0.5);
    path2.lineTo(size.width * 0.6, size.height * 0.4);
    path2.lineTo(size.width * 0.75, size.height * 0.55);
    path2.lineTo(size.width * 0.85, size.height * 0.45);
    path2.lineTo(size.width, size.height * 0.55);
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppThemeData.primaryWhite.withValues(alpha: 0.015)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
