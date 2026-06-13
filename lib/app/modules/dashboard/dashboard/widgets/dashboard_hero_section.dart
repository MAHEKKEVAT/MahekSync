import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class DashboardHeroSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : hour < 20
                ? 'Good Evening'
                : 'Good Night';
    final emoji = hour < 12
        ? '☀️'
        : hour < 17
            ? '🌤️'
            : hour < 20
                ? '🌅'
                : '🌙';
    final fullName = MahekConstant.ownerModel?.fullName ?? 'Mahek Kevat';
    final firstName = fullName.split(' ').first;

    final LinearGradient heroGradient;
    if (hour < 12) {
      heroGradient = const LinearGradient(
        colors: [Color(0xFF2D1B69), Color(0xFF5B21B6), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 17) {
      heroGradient = const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF1E3A5F), Color(0xFF3B82F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 20) {
      heroGradient = const LinearGradient(
        colors: [Color(0xFF1A0533), Color(0xFF4C1D95), Color(0xFFDB2777)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      heroGradient = const LinearGradient(
        colors: [Color(0xFF0A0A1A), Color(0xFF1E1B4B), Color(0xFF312E81)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    final taskPending = controller.pendingTasks;
    final reminderToday = controller.reminderCount.value;
    final toCollect = controller.totalOwedFormatted;
    final dueCount = controller.duesCount.value;
    final progressPercent = ((taskPending > 0 ? (taskPending * 0.85) : 85)).clamp(0, 100);

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
              child: CustomPaint(painter: _GridPainter(isDark)),
            ),

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
                    color: Colors.white.withValues(alpha: rng.nextDouble() * 0.4 + 0.2),
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
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Name
                  Text(
                    '$firstName $emoji',
                    style: const TextStyle(
                      fontFamily: FontFamily.bold,
                      fontSize: 26,
                      color: Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.6),
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
                    onTap: onViewPlan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
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
                          const Text(
                            "View Today's Plan",
                            style: TextStyle(
                              fontFamily: FontFamily.semiBold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              size: 14, color: Colors.white),
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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                style: const TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontFamily.regular,
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.5),
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

class _MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Full moon
    final moonPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFF5E6C8), Color(0xFFE8D5B7)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, moonPaint);

    // Shadow to create crescent
    final shadowPaint = Paint()
      ..color = const Color(0xFF0A0A1A);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.35, center.dy - radius * 0.1),
      radius * 0.85,
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

    // Second layer (lighter)
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
      ..color = Colors.white.withValues(alpha: 0.015)
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
