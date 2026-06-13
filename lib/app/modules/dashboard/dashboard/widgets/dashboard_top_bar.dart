// lib/app/modules/dashboard/widgets/dashboard_top_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:provider/provider.dart';

class DashboardTopBar extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const DashboardTopBar({
    super.key,
    this.onMenuTap,
  });

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
                ? AppThemeData.surfaceBorder.withOpacity(0.4)
                : AppThemeData.grey3.withOpacity(0.5),
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
              onTap: onMenuTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.surfaceElevated.withOpacity(0.5)
                      : AppThemeData.grey2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? AppThemeData.surfaceBorder.withOpacity(0.3)
                        : AppThemeData.grey4.withOpacity(0.3),
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
              const SizedBox(width: 8),
              // ── Version Chip ───────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppThemeData.appleIntelligenceGradientCool,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 9,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // ── Right Side: Theme Toggle + Avatar ─────────
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
                    ? AppThemeData.surfaceElevated.withOpacity(0.5)
                    : AppThemeData.grey2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? AppThemeData.surfaceBorder.withOpacity(0.3)
                      : AppThemeData.grey4.withOpacity(0.3),
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
