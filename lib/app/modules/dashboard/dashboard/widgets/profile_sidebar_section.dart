import 'package:flutter/material.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';

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
    return Column(
      children: [
        // Need AI Help card
        _AIHelpCard(isDark: isDark),
        const SizedBox(height: 14),
        // Quick Actions grid
        _QuickActionsGrid(isDark: isDark),
        const SizedBox(height: 14),
        // Upgrade to Pro card
        _UpgradeCard(isDark: isDark),
        const SizedBox(height: 14),
        // Profile card
        _ProfileCard(isDark: isDark),
      ],
    );
  }
}

class _AIHelpCard extends StatelessWidget {
  final bool isDark;
  const _AIHelpCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeData.neonPurple.withValues(alpha: 0.12),
            AppThemeData.neonBlue.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppThemeData.neonPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need AI Help?',
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 15,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ask anything, I'm here to help!",
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 12,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppThemeData.neonPurple, AppThemeData.neonBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppThemeData.neonPurple.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              SolarIconsBold.magicStick,
              size: 22,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final bool isDark;
  const _QuickActionsGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _GridAction(
        icon: SolarIconsBold.checkCircle,
        label: 'Add Task',
        color: AppThemeData.neonPurple,
        route: Routes.PERSONAL_TASKS,
      ),
      _GridAction(
        icon: SolarIconsBold.alarm,
        label: 'Add Reminder',
        color: AppThemeData.neonOrange,
        route: Routes.REMINDER,
      ),
      _GridAction(
        icon: SolarIconsBold.wallet,
        label: 'Add Expense',
        color: AppThemeData.danger300,
        route: Routes.DUES_TRACKER,
      ),
      _GridAction(
        icon: SolarIconsBold.camera,
        label: 'Scan Document',
        color: AppThemeData.neonTeal,
        route: Routes.VAULT,
      ),
      _GridAction(
        icon: SolarIconsBold.user,
        label: 'New Contact',
        color: AppThemeData.neonMint,
        route: Routes.MY_CONTACTS,
      ),
      _GridAction(
        icon: SolarIconsBold.bolt,
        label: 'Voice Note',
        color: AppThemeData.neonLavender,
        route: Routes.VAULT,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.12)
              : AppThemeData.grey3.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 14,
              color: isDark ? AppThemeData.grey2 : AppThemeData.grey9,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 24) / 3;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: actions.map((action) {
                  return SizedBox(
                    width: itemWidth,
                    child: _ActionTile(action: action, isDark: isDark),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GridAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _GridAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _ActionTile extends StatelessWidget {
  final _GridAction action;
  final bool isDark;
  const _ActionTile({required this.action, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          final dc = Get.find<DashboardController>();
          dc.navigateToRoute(action.route);
        } catch (_) {
          Get.toNamed(action.route);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppThemeData.surfaceMid.withValues(alpha: 0.3)
              : AppThemeData.grey2.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? AppThemeData.surfaceBorder.withValues(alpha: 0.10)
                : AppThemeData.grey3.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, size: 18, color: action.color),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: TextStyle(
                fontFamily: FontFamily.medium,
                fontSize: 10,
                color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final bool isDark;
  const _UpgradeCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeData.neonPurple.withValues(alpha: 0.15),
            AppThemeData.neonBlue.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppThemeData.neonPurple.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppThemeData.neonPurple, AppThemeData.neonBlue],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Upgrade to Pro',
                style: TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 14,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock advanced features and priority support.',
            style: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 11,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemeData.neonPurple, AppThemeData.neonBlue],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppThemeData.neonPurple.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Upgrade Now',
                  style: TextStyle(
                    fontFamily: FontFamily.semiBold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final bool isDark;
  const _ProfileCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final userName = MahekConstant.ownerModel?.fullName ?? 'Mahek Kevat';
    final initials = _initials(userName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.12)
              : AppThemeData.grey3.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppThemeData.neonPurpleBlueGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppThemeData.neonPurple.withValues(alpha: 0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 14,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Premium User',
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 11,
                    color: AppThemeData.neonPurple,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
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
