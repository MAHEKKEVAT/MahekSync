import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:provider/provider.dart';

import 'package:maheksync/app/modules/dashboard/dashboard/widgets/dashboard_hero_section.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/today_focus_section.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/life_overview_section.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/financial_snapshot_card.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/security_status_card.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/upcoming_timeline_section.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/activity_feed_section.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/profile_sidebar_section.dart';

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  static const _spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkThemeProvider>(context).isDarkTheme();
    final isDesktop = ResponsiveWidget.isDesktop(context);
    final isTablet = ResponsiveWidget.isTablet(context);
    final c = Get.find<DashboardHomeController>();

    return Obx(() {
      if (c.isLoading.value) {
        return Container(
          color: isDark ? AppThemeData.surfaceVoid : AppThemeData.grey1,
          child: Center(
            child: MahekLoader(
              message: 'Loading Dashboard...',
              size: 44,
              textSize: 13,
              style: MahekLoaderStyle.ring,
            ),
          ),
        );
      }

      return Container(
        color: isDark ? AppThemeData.surfaceVoid : AppThemeData.grey1,
        child: isDesktop
            ? _buildDesktopLayout(c, isDark)
            : _buildMobileLayout(c, isDark, isTablet),
      );
    });
  }

  Widget _buildDesktopLayout(DashboardHomeController c, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(_spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeroSection(
                  controller: c,
                  isDark: isDark,
                  onViewPlan: () => _navigateTo(Routes.PERSONAL_TASKS),
                ),
                spaceH(height: _spacing),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TodayFocusSection(
                        controller: c,
                        isDark: isDark,
                        onTaskTap: () => _navigateTo(Routes.PERSONAL_TASKS),
                        onDueTap: () => _navigateTo(Routes.DUES_TRACKER),
                        onReminderTap: () => _navigateTo(Routes.REMINDER),
                        onViewAll: () => _navigateTo(Routes.PERSONAL_TASKS),
                      ),
                    ),
                    const SizedBox(width: _spacing),
                    Expanded(
                      flex: 3,
                      child: LifeOverviewSection(
                        controller: c,
                        isDark: isDark,
                        onDevicesTap: () => _navigateTo(Routes.MY_DEVICES),
                        onSubscriptionsTap: () => _navigateTo(Routes.SUBSCRIPTION),
                        onVaultTap: () => _navigateTo(Routes.AEGIS),
                        onContactsTap: () => _navigateTo(Routes.MY_CONTACTS),
                        onViewAll: () => _navigateTo(Routes.SETTINGS),
                      ),
                    ),
                  ],
                ),
                spaceH(height: _spacing),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: FinancialSnapshotCard(
                        controller: c,
                        isDark: isDark,
                        onDuesTap: () => _navigateTo(Routes.DUES_TRACKER),
                        onViewAll: () => _navigateTo(Routes.DUES_TRACKER),
                      ),
                    ),
                    const SizedBox(width: _spacing),
                    Expanded(
                      flex: 2,
                      child: SecurityStatusCard(
                        controller: c,
                        isDark: isDark,
                        onTap: () => _navigateTo(Routes.AEGIS),
                      ),
                    ),
                  ],
                ),
                spaceH(height: _spacing),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: UpcomingTimelineSection(
                        controller: c,
                        isDark: isDark,
                        onViewAll: () => _navigateTo(Routes.REMINDER),
                      ),
                    ),
                    const SizedBox(width: _spacing),
                    Expanded(
                      flex: 2,
                      child: ActivityFeedSection(
                        controller: c,
                        isDark: isDark,
                        onViewAll: () => _navigateTo(Routes.MY_PURCHASES),
                      ),
                    ),
                  ],
                ),
                spaceH(height: _spacing),

                _buildQuickActions(c, isDark),
              ],
            ),
          ),
        ),

        SizedBox(
          width: 300,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              top: _spacing,
              right: _spacing,
              bottom: _spacing,
            ),
            child: ProfileSidebarSection(controller: c, isDark: isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      DashboardHomeController c, bool isDark, bool isTablet) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(isTablet ? _spacing : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeroSection(
            controller: c,
            isDark: isDark,
            onViewPlan: () => _navigateTo(Routes.PERSONAL_TASKS),
          ),
          spaceH(height: _spacing),

          TodayFocusSection(
            controller: c,
            isDark: isDark,
            onTaskTap: () => _navigateTo(Routes.PERSONAL_TASKS),
            onDueTap: () => _navigateTo(Routes.DUES_TRACKER),
            onReminderTap: () => _navigateTo(Routes.REMINDER),
            onViewAll: () => _navigateTo(Routes.PERSONAL_TASKS),
          ),
          spaceH(height: _spacing),

          LifeOverviewSection(
            controller: c,
            isDark: isDark,
            onDevicesTap: () => _navigateTo(Routes.MY_DEVICES),
            onSubscriptionsTap: () => _navigateTo(Routes.SUBSCRIPTION),
            onVaultTap: () => _navigateTo(Routes.AEGIS),
            onContactsTap: () => _navigateTo(Routes.MY_CONTACTS),
            onViewAll: () => _navigateTo(Routes.SETTINGS),
          ),
          spaceH(height: _spacing),

          FinancialSnapshotCard(
            controller: c,
            isDark: isDark,
            onDuesTap: () => _navigateTo(Routes.DUES_TRACKER),
            onViewAll: () => _navigateTo(Routes.DUES_TRACKER),
          ),
          spaceH(height: _spacing),

          SecurityStatusCard(
            controller: c,
            isDark: isDark,
            onTap: () => _navigateTo(Routes.AEGIS),
          ),
          spaceH(height: _spacing),

          UpcomingTimelineSection(
            controller: c,
            isDark: isDark,
            onViewAll: () => _navigateTo(Routes.REMINDER),
          ),
          spaceH(height: _spacing),

          ActivityFeedSection(
            controller: c,
            isDark: isDark,
            onViewAll: () => _navigateTo(Routes.MY_PURCHASES),
          ),
          spaceH(height: _spacing),

          _buildQuickActions(c, isDark),
          spaceH(height: _spacing),

          ProfileSidebarSection(controller: c, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildQuickActions(DashboardHomeController c, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
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
              fontSize: 16,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickCircleAction(
                icon: Icons.add_task_rounded,
                label: 'Add Task',
                color: AppThemeData.neonPurple,
                onTap: () => _navigateTo(Routes.PERSONAL_TASKS),
                isDark: isDark,
              ),
              _QuickCircleAction(
                icon: Icons.alarm_add_rounded,
                label: 'Add Reminder',
                color: AppThemeData.neonOrange,
                onTap: () => _navigateTo(Routes.REMINDER),
                isDark: isDark,
              ),
              _QuickCircleAction(
                icon: Icons.add_circle_rounded,
                label: 'Add Expense',
                color: AppThemeData.danger300,
                onTap: () => _navigateTo(Routes.DUES_TRACKER),
                isDark: isDark,
              ),
              _QuickCircleAction(
                icon: Icons.document_scanner_rounded,
                label: 'Scan Document',
                color: AppThemeData.neonTeal,
                onTap: () => _navigateTo(Routes.AEGIS),
                isDark: isDark,
              ),
              _QuickCircleAction(
                icon: Icons.person_add_rounded,
                label: 'New Contact',
                color: AppThemeData.neonMint,
                onTap: () => _navigateTo(Routes.MY_CONTACTS),
                isDark: isDark,
              ),
              _QuickCircleAction(
                icon: Icons.mic_rounded,
                label: 'Voice Note',
                color: AppThemeData.neonLavender,
                onTap: () => _navigateTo(Routes.AEGIS),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateTo(String route) {
    try {
      final dc = Get.find<DashboardController>();
      dc.navigateToRoute(route);
    } catch (_) {
      Get.toNamed(route);
    }
  }
}

class _QuickCircleAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickCircleAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.medium,
              fontSize: 10,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
