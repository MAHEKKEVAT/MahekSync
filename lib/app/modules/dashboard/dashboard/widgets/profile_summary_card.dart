// lib/app/modules/dashboard/widgets/profile_summary_card.dart
import 'package:flutter/material.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileSummaryCard extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const ProfileSummaryCard({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final userName = MahekConstant.ownerModel?.fullName ?? 'Mahek Kevat';
    final securityScore = _calculateSecurityScore();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.neonPurple.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Stack(
        children: [
          // ── Blurry Watermark Icon ────────────────────
          Positioned(
            right: -12,
            bottom: -12,
            child: Icon(
              Icons.person_rounded,
              size: 90,
              color: AppThemeData.neonPurple.withValues(alpha: 0.04),
            ),
          ),

          // ── Actual Content ───────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Avatar + Name Row ────────────────────────
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppThemeData.neonPurpleBlueGradient,
                      boxShadow: AppThemeData.neonGlow(
                        AppThemeData.neonPurple,
                        blur: 14,
                        opacity: 0.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _userInitials(userName),
                        style: const TextStyle(
                          fontFamily: FontFamily.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontFamily: FontFamily.bold,
                            fontSize: 15,
                            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Premium badge inline
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: AppThemeData.appleIntelligenceGradientCool,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium_rounded, size: 10, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  fontFamily: FontFamily.bold,
                                  fontSize: 9,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── Quick Metrics ───────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.surfaceElevated.withValues(alpha: 0.4)
                      : AppThemeData.grey2.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MetricItem(
                      label: 'Devices',
                      value: controller.deviceCount.value.toString(),
                      icon: Icons.devices_rounded,
                      color: AppThemeData.neonTeal,
                      isDark: isDark,
                    ),
                    _MetricDivider(isDark: isDark),
                    _MetricItem(
                      label: 'Contacts',
                      value: controller.contactCount.value.toString(),
                      icon: Icons.contacts_rounded,
                      color: AppThemeData.neonOrange,
                      isDark: isDark,
                    ),
                    _MetricDivider(isDark: isDark),
                    _MetricItem(
                      label: 'Vault',
                      value: controller.vaultCount.value.toString(),
                      icon: Icons.lock_rounded,
                      color: AppThemeData.neonPurple,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Security Score ──────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.surfaceElevated.withValues(alpha: 0.4)
                      : AppThemeData.grey2.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 26,
                      lineWidth: 3.5,
                      percent: securityScore / 100,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: isDark
                          ? AppThemeData.surfaceMid
                          : AppThemeData.grey3,
                      linearGradient: AppThemeData.neonPurpleBlueGradient,
                      center: Text(
                        '$securityScore',
                        style: TextStyle(
                          fontFamily: FontFamily.bold,
                          fontSize: 13,
                          color: isDark
                              ? AppThemeData.grey1
                              : AppThemeData.grey10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Score',
                            style: TextStyle(
                              fontFamily: FontFamily.medium,
                              fontSize: 12,
                              color: isDark
                                  ? AppThemeData.grey3
                                  : AppThemeData.grey8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            securityScore >= 80
                                ? 'Well protected'
                                : securityScore >= 50
                                    ? 'Needs attention'
                                    : 'At risk',
                            style: TextStyle(
                              fontFamily: FontFamily.medium,
                              fontSize: 11,
                              color: securityScore >= 80
                                  ? AppThemeData.neonMint
                                  : securityScore >= 50
                                      ? AppThemeData.neonOrange
                                      : AppThemeData.neonRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateSecurityScore() {
    int score = 0;
    if (controller.sentinelPasswordSet.value) score += 40;
    if (!controller.sentinelLocked.value) score += 20;
    if (controller.deviceCount.value > 0) score += 15;
    if (controller.vaultCount.value > 0) score += 15;
    if (controller.contactCount.value > 0) score += 10;
    return score.clamp(0, 100);
  }

  String _userInitials(String name) {
    if (name.isEmpty) return 'M';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

// ─── Metric Item ──────────────────────────────────────────────
class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontFamily: FontFamily.bold,
            fontSize: 14,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 9,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
      ],
    );
  }
}

// ─── Metric Divider ───────────────────────────────────────────
class _MetricDivider extends StatelessWidget {
  final bool isDark;
  const _MetricDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: isDark
          ? AppThemeData.surfaceBorder.withValues(alpha: 0.2)
          : AppThemeData.grey4.withValues(alpha: 0.3),
    );
  }
}
