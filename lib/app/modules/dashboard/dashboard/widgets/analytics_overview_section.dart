// lib/app/modules/dashboard/widgets/analytics_overview_section.dart
import 'package:flutter/material.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class AnalyticsOverviewSection extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const AnalyticsOverviewSection({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final securityScore = _calculateSecurityScore();
    final totalDuesAmount = _calculateTotalDues();
    final activeSubs = controller.subscriptionCount.value;

    final cards = [
      _AnalyticsCard(
        title: "Today's Tasks",
        value: controller.overdueTaskCount.toString(),
        subtitle: controller.overdueTaskCount > 0 ? 'Overdue' : 'All clear',
        icon: Icons.task_alt_rounded,
        iconGradient: LinearGradient(
          colors: [AppThemeData.neonPurple, AppThemeData.neonBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: AppThemeData.neonPurple,
        progress: controller.taskCount.value > 0
            ? (controller.overdueTaskCount / controller.taskCount.value).clamp(0.0, 1.0)
            : 0.0,
        trend: controller.overdueTaskCount > 0 ? 'up' : 'down',
        trendValue: controller.overdueTaskCount > 0 ? 'Action needed' : 'On track',
        isDark: isDark,
      ),
      _AnalyticsCard(
        title: 'Due Amount',
        value: totalDuesAmount,
        subtitle: '${controller.duesCount.value} pending',
        icon: Icons.account_balance_wallet_rounded,
        iconGradient: LinearGradient(
          colors: [AppThemeData.neonPink, AppThemeData.neonOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: AppThemeData.neonPink,
        progress: controller.duesCount.value > 0 ? 0.65 : 0.0,
        trend: controller.duesCount.value > 5 ? 'up' : 'down',
        trendValue: controller.duesCount.value > 5 ? 'High dues' : 'Managed',
        isDark: isDark,
      ),
      _AnalyticsCard(
        title: 'Subscriptions',
        value: activeSubs.toString(),
        subtitle: 'Active services',
        icon: Icons.subscriptions_rounded,
        iconGradient: LinearGradient(
          colors: [AppThemeData.neonTeal, AppThemeData.neonBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: AppThemeData.neonTeal,
        progress: activeSubs > 0 ? (activeSubs / 10).clamp(0.0, 1.0) : 0.0,
        trend: activeSubs > 3 ? 'up' : 'down',
        trendValue: activeSubs > 3 ? 'Growing' : 'Minimal',
        isDark: isDark,
      ),
      _AnalyticsCard(
        title: 'Security Score',
        value: '$securityScore',
        subtitle: securityScore >= 80 ? 'Protected' : securityScore >= 50 ? 'Attention' : 'At risk',
        icon: Icons.shield_rounded,
        iconGradient: LinearGradient(
          colors: [AppThemeData.neonMint, AppThemeData.neonCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: securityScore >= 80
            ? AppThemeData.neonMint
            : securityScore >= 50
                ? AppThemeData.neonOrange
                : AppThemeData.neonRed,
        progress: securityScore / 100,
        trend: securityScore >= 80 ? 'down' : 'up',
        trendValue: securityScore >= 80 ? 'Excellent' : 'Improve',
        isDark: isDark,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardCount = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 2 : 1;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.map((card) {
            return SizedBox(
              width: (constraints.maxWidth - (16 * (cardCount - 1))) / cardCount,
              child: card,
            );
          }).toList(),
        );
      },
    );
  }

  String _calculateTotalDues() {
    double total = 0;
    for (final d in controller.latestDues) {
      if (d.dueType == 'owe' && d.amount != null) {
        total += d.amount!;
      }
    }
    if (total >= 100000) return '${(total / 100000).toStringAsFixed(1)}L';
    if (total >= 1000) return '${(total / 1000).toStringAsFixed(1)}K';
    return total.toStringAsFixed(0);
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

// ─── Analytics Card ───────────────────────────────────────────
class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Gradient iconGradient;
  final Color accentColor;
  final double progress;
  final String trend;
  final String trendValue;
  final bool isDark;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconGradient,
    required this.accentColor,
    required this.progress,
    required this.trend,
    required this.trendValue,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Watermark ────────────────────────────
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(icon, size: 70, color: accentColor.withOpacity(0.05)),
          ),

          // ── Content ──────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon + Trend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: iconGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 18, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trend == 'up'
                          ? AppThemeData.neonRed.withOpacity(0.08)
                          : AppThemeData.neonMint.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trend == 'up' ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 12,
                          color: trend == 'up' ? AppThemeData.neonRed : AppThemeData.neonMint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trendValue,
                          style: TextStyle(
                            fontFamily: FontFamily.medium,
                            fontSize: 9,
                            color: trend == 'up' ? AppThemeData.neonRed : AppThemeData.neonMint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Large Value
              Text(
                value,
                style: TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 28,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),

              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: FontFamily.regular,
                  fontSize: 11,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ),

              const SizedBox(height: 14),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: FontFamily.medium,
                          fontSize: 10,
                          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: FontFamily.bold,
                          fontSize: 10,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: isDark ? AppThemeData.surfaceMid : AppThemeData.grey3,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
