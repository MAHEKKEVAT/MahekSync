// lib/app/modules/dashboard/widgets/dashboard_top_bar.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:provider/provider.dart';

class DashboardTopBar extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const DashboardTopBar({
    super.key,
    this.onMenuTap,
  });

  @override
  State<DashboardTopBar> createState() => _DashboardTopBarState();
}

class _DashboardTopBarState extends State<DashboardTopBar> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _dayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[_now.weekday - 1];
  }

  String get _monthName {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return months[_now.month - 1];
  }

  String get _formattedDate => '$_dayName, ${_now.day} $_monthName ${_now.year}';

  String get _formattedTime {
    final h = _now.hour > 12 ? _now.hour - 12 : (_now.hour == 0 ? 12 : _now.hour);
    final m = _now.minute.toString().padLeft(2, '0');
    final period = _now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkThemeProvider>(context).isDarkTheme();
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceVoid : AppThemeData.grey1,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppThemeData.surfaceBorder.withValues(alpha: 0.4)
                : AppThemeData.grey3.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
      ),
      child: Row(
        children: [
          // ── Menu Toggle (mobile/tablet) ───────────────
          if (!isDesktop)
            GestureDetector(
              onTap: widget.onMenuTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.surfaceElevated.withValues(alpha: 0.5)
                      : AppThemeData.grey2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                        : AppThemeData.grey4.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  size: 18,
                  color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
                ),
              ),
            ),
          if (!isDesktop) const SizedBox(width: 14),

          // ── Logo / Brand ─────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppThemeData.neonPurpleBlueGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: AppThemeData.neonGlow(
                    AppThemeData.neonPurple,
                    blur: 14,
                    opacity: 0.2,
                  ),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'MaheKSync',
                style: TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 17,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 10),

              // ── Premium Badge (Subscription Style) ─────
              _PremiumBadge(isDark: isDark),
            ],
          ),

          const Spacer(),

          // ── Date & Time ──────────────────────────────
          if (isDesktop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeData.surfaceElevated.withValues(alpha: 0.4)
                    : AppThemeData.grey2.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppThemeData.surfaceBorder.withValues(alpha: 0.2)
                      : AppThemeData.grey3.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date
                  Icon(Icons.calendar_today_rounded,
                      size: 13,
                      color: isDark ? AppThemeData.neonPurple : AppThemeData.neonPurple),
                  const SizedBox(width: 8),
                  Text(
                    _formattedDate,
                    style: TextStyle(
                      fontFamily: FontFamily.medium,
                      fontSize: 12,
                      color: isDark ? AppThemeData.grey2 : AppThemeData.grey9,
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: isDark
                        ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                        : AppThemeData.grey4.withValues(alpha: 0.5),
                  ),
                  // Time
                  Icon(Icons.schedule_rounded,
                      size: 13,
                      color: isDark ? AppThemeData.neonOrange : AppThemeData.neonOrange),
                  const SizedBox(width: 8),
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      fontFamily: FontFamily.bold,
                      fontSize: 12,
                      color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                    ),
                  ),
                ],
              ),
            ),

          if (isDesktop) const SizedBox(width: 14),

          // ── Mobile Date/Time (compact) ───────────────
          if (!isDesktop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeData.surfaceElevated.withValues(alpha: 0.4)
                    : AppThemeData.grey2.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? AppThemeData.surfaceBorder.withValues(alpha: 0.2)
                      : AppThemeData.grey3.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 12,
                      color: isDark ? AppThemeData.neonOrange : AppThemeData.neonOrange),
                  const SizedBox(width: 6),
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      fontFamily: FontFamily.bold,
                      fontSize: 11,
                      color: isDark ? AppThemeData.grey2 : AppThemeData.grey9,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 12),

          // ── Theme Toggle ──────────────────────────────
          GestureDetector(
            onTap: () {
              final provider = Provider.of<DarkThemeProvider>(context, listen: false);
              provider.darkTheme = provider.isDarkTheme() ? 1 : 0;
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeData.surfaceElevated.withValues(alpha: 0.5)
                    : AppThemeData.grey2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                      : AppThemeData.grey4.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 17,
                color: isDark ? AppThemeData.neonPurple : AppThemeData.grey7,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Profile Avatar ───────────────────────────
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppThemeData.neonPurpleBlueGradient,
              boxShadow: AppThemeData.neonGlow(
                AppThemeData.neonPurple,
                blur: 12,
                opacity: 0.15,
              ),
            ),
            child: Center(
              child: Text(
                _userInitials(),
                style: const TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _userInitials() {
    final name = MahekConstant.ownerModel?.fullName ?? 'M';
    if (name.isEmpty) return 'M';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

// ══════════════════════════════════════════════════════════════
//  Premium Badge – Subscription Website Style
// ══════════════════════════════════════════════════════════════
class _PremiumBadge extends StatelessWidget {
  final bool isDark;

  const _PremiumBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeData.neonPurple.withValues(alpha: 0.15),
            AppThemeData.neonBlue.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppThemeData.neonPurple.withValues(alpha: 0.25),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.neonPurple.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown icon
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppThemeData.neonPurple, AppThemeData.neonBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'PRO',
            style: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 10,
              color: isDark ? AppThemeData.neonPurple : AppThemeData.neonPurple,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
