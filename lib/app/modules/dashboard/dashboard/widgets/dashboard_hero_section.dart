// lib/app/modules/dashboard/widgets/dashboard_hero_section.dart
import 'package:flutter/material.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class DashboardHeroSection extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const DashboardHeroSection({
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

    // Time-based multi-color gradient
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
            color: const Color(0xFF8B5CF6).withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 12),
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
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.01),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
          ),

          // ── Decorative Orbs ──────────────────────────
          Positioned(
            top: -40,
            right: 60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.07), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: 40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.05), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Grid Pattern ─────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // ── Blurry Watermark ─────────────────────────
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(greetingIcon, size: 180, color: Colors.white.withOpacity(0.04)),
          ),

          // ── Main Content (Greeting + Name + Chips only) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Greeting
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(greetingIcon, size: 15, color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      greeting,
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Full Name
                Text(
                  fullName,
                  style: const TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 28,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // ── 4 Glass Metric Chips ───────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _GlassChip(
                      icon: Icons.task_alt_rounded,
                      value: controller.taskCount.value.toString(),
                      label: 'Tasks',
                    ),
                    _GlassChip(
                      icon: Icons.alarm_rounded,
                      value: controller.reminderCount.value.toString(),
                      label: 'Reminders',
                    ),
                    _GlassChip(
                      icon: Icons.devices_rounded,
                      value: controller.deviceCount.value.toString(),
                      label: 'Devices',
                    ),
                    _GlassChip(
                      icon: Icons.contacts_rounded,
                      value: controller.contactCount.value.toString(),
                      label: 'Contacts',
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

// ─── Glass Metric Chip ────────────────────────────────────────
class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _GlassChip({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 13, color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontFamily.regular,
                  fontSize: 9,
                  color: Colors.white.withOpacity(0.5),
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

// ─── Grid Painter ─────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.015)
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
