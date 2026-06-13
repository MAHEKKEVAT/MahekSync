// lib/app/modules/dashboard/widgets/profile_sidebar_section.dart
import 'package:flutter/material.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileSidebarSection extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const ProfileSidebarSection({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final userName = MahekConstant.ownerModel?.fullName ?? 'Mahek Kevat';
    final securityScore = _calculateSecurityScore();

    return Column(
      children: [
        // ── Profile Card ─────────────────────────────
        _ProfileCard(userName: userName, isDark: isDark),

        const SizedBox(height: 16),

        // ── Security Score Ring ──────────────────────
        _SecurityScoreCard(score: securityScore, isDark: isDark),

        const SizedBox(height: 16),

        // ── Quick Stats ──────────────────────────────
        _QuickStatsCard(controller: controller, isDark: isDark),

        const SizedBox(height: 16),

        // ── Recent Contact ───────────────────────────
        _RecentContactCard(controller: controller, isDark: isDark),
      ],
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
}

// ─── Profile Card ─────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String userName;
  final bool isDark;

  const _ProfileCard({required this.userName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.neonPurple.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppThemeData.neonPurpleBlueGradient,
              boxShadow: AppThemeData.neonGlow(AppThemeData.neonPurple, blur: 16, opacity: 0.15),
            ),
            child: Center(
              child: Text(
                _initials(userName),
                style: const TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 16,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppThemeData.appleIntelligenceGradientCool,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded, size: 11, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Premium',
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 10,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return 'M';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }
}

// ─── Security Score Card ──────────────────────────────────────
class _SecurityScoreCard extends StatelessWidget {
  final int score;
  final bool isDark;

  const _SecurityScoreCard({required this.score, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80 ? AppThemeData.neonMint : score >= 50 ? AppThemeData.neonOrange : AppThemeData.neonRed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 30,
            lineWidth: 4,
            percent: score / 100,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: isDark ? AppThemeData.surfaceMid : AppThemeData.grey3,
            linearGradient: AppThemeData.neonPurpleBlueGradient,
            center: Text(
              '$score',
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 16,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Score',
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 13,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  score >= 80 ? 'Well protected' : score >= 50 ? 'Needs attention' : 'At risk',
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Stats Card ─────────────────────────────────────────
class _QuickStatsCard extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const _QuickStatsCard({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _StatRow(icon: Icons.devices_rounded, label: 'Devices', value: controller.deviceCount.value.toString(), color: AppThemeData.neonTeal, isDark: isDark),
          const SizedBox(height: 10),
          _StatRow(icon: Icons.lock_rounded, label: 'Vault Items', value: controller.vaultCount.value.toString(), color: AppThemeData.neonPurple, isDark: isDark),
          const SizedBox(height: 10),
          _StatRow(icon: Icons.contacts_rounded, label: 'Contacts', value: controller.contactCount.value.toString(), color: AppThemeData.neonOrange, isDark: isDark),
          const SizedBox(height: 10),
          _StatRow(icon: Icons.shield_rounded, label: 'Sentinel', value: controller.sentinelPasswordSet.value ? 'Active' : 'Inactive', color: controller.sentinelPasswordSet.value ? AppThemeData.neonMint : AppThemeData.neonRed, isDark: isDark),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 12,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: FontFamily.bold,
            fontSize: 13,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
        ),
      ],
    );
  }
}

// ─── Recent Contact ───────────────────────────────────────────
class _RecentContactCard extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const _RecentContactCard({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final contacts = controller.latestContacts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Contacts',
            style: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 12,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
            ),
          ),
          const SizedBox(height: 12),
          if (contacts.isEmpty)
            Center(
              child: Text(
                'No contacts',
                style: TextStyle(
                  fontFamily: FontFamily.regular,
                  fontSize: 11,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                ),
              ),
            )
          else
            ...contacts.take(3).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppThemeData.neonOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            c.initials,
                            style: TextStyle(
                              fontFamily: FontFamily.bold,
                              fontSize: 10,
                              color: AppThemeData.neonOrange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          c.formattedName,
                          style: TextStyle(
                            fontFamily: FontFamily.medium,
                            fontSize: 11,
                            color: isDark ? AppThemeData.grey2 : AppThemeData.grey9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
