// lib/app/modules/dashboard/widgets/dashboard_hero_card.dart
import 'package:flutter/material.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class DashboardHeroCard extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const DashboardHeroCard({
    super.key,
    required this.controller,
    required this.isDark,
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
    final greetingIcon = hour < 12
        ? Icons.wb_sunny_rounded
        : hour < 17
            ? Icons.wb_cloudy_rounded
            : hour < 20
                ? Icons.nights_stay_rounded
                : Icons.bedtime_rounded;

    final fullName = MahekConstant.ownerModel?.fullName ?? 'Mahek Kevat';

    // Multi-color gradient based on time of day
    final LinearGradient heroGradient;
    if (hour < 12) {
      heroGradient = const LinearGradient(
        colors: [Color(0xFF6C3CE1), Color(0xFFE04EA0), Color(0xFFF47340)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 17) {
      heroGradient = const LinearGradient(
        colors: [Color(0xFF0ACF83), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 20) {
      heroGradient = const LinearGradient(
        colors: [Color(0xFF5B21B6), Color(0xFFDB2777), Color(0xFFF97316)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      heroGradient = const LinearGradient(
        colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95), Color(0xFF3B82F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: heroGradient,
        boxShadow: [
          BoxShadow(
            color: (hour < 12
                ? const Color(0xFFF47340)
                : hour < 17
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF8B5CF6)).withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Glass Overlay ────────────────────────────
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeData.primaryWhite.withValues(alpha: 0.08),
                  AppThemeData.primaryWhite.withValues(alpha: 0.01),
                  AppThemeData.primaryWhite.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),

          // ── Decorative Orbs ──────────────────────────
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppThemeData.primaryWhite.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: 30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppThemeData.primaryWhite.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Subtle grid pattern ──────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),

          // ── Blurry Icon Watermark (bottom-right) ─────
          Positioned(
            right: -10,
            bottom: -15,
            child: Icon(
              greetingIcon,
              size: 140,
              color: AppThemeData.primaryWhite.withValues(alpha: 0.06),
            ),
          ),

          // ── Main Content (only Greeting + Name + Chips) ──
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Greeting row
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppThemeData.primaryWhite.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        greetingIcon,
                        size: 16,
                        color: AppThemeData.primaryWhite.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      greeting,
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 14,
                        color: AppThemeData.primaryWhite.withValues(alpha: 0.75),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Full name
                Text(
                  fullName,
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 28,
                    color: AppThemeData.primaryWhite,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),

                // ── Mini Statistics Row ──────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroStatChip(
                      icon: Icons.task_alt_rounded,
                      value: controller.overdueTaskCount.toString(),
                      label: 'Tasks',
                      color: AppThemeData.primaryWhite.withValues(alpha: 0.85),
                    ),
                    _HeroStatChip(
                      icon: Icons.event_rounded,
                      value: controller.overdueReminderCount.toString(),
                      label: 'Due',
                      color: AppThemeData.primaryWhite.withValues(alpha: 0.85),
                    ),
                    _HeroStatChip(
                      icon: Icons.devices_rounded,
                      value: controller.deviceCount.value.toString(),
                      label: 'Devices',
                      color: AppThemeData.primaryWhite.withValues(alpha: 0.85),
                    ),
                    _HeroStatChip(
                      icon: Icons.shield_rounded,
                      value: controller.sentinelPasswordSet.value
                          ? 'Active'
                          : 'Off',
                      label: 'Sentinel',
                      color: controller.sentinelPasswordSet.value
                          ? AppThemeData.primaryWhite.withValues(alpha: 0.85)
                          : AppThemeData.primaryWhite.withValues(alpha: 0.38),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Stat Chip ───────────────────────────────────────────
class _HeroStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _HeroStatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppThemeData.primaryWhite.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeData.primaryWhite.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppThemeData.primaryWhite.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 13,
                  color: AppThemeData.primaryWhite,
                  height: 1.2,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontFamily.regular,
                  fontSize: 9,
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

// ─── Subtle Grid Painter ──────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppThemeData.primaryWhite.withValues(alpha: 0.02)
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
