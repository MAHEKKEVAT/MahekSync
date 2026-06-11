import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/models/personal_task_model.dart';
import 'package:maheksync/app/models/reminder_model.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/dashboard_charts.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/dashboard_models.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  // ─── Design System Tokens ────────────────────────────────────────
  static const _bg = Color(0xFF0F1117);
  static const _card = Color(0xFF171A23);
  static const _cardHover = Color(0xFF1E2230);
  static const _border = Color(0xFF252830);
  static const _textPrimary = Color(0xFFE8EAF0);
  static const _textSecondary = Color(0xFF8B8FA3);
  static const _textTertiary = Color(0xFF5C5F72);
  static const _accentBlue = Color(0xFF4A6CF7);
  static const _accentGreen = Color(0xFF34D399);
  static const _accentRed = Color(0xFFF87171);
  static const _accentAmber = Color(0xFFFBBF24);
  static const _accentPurple = Color(0xFFA78BFA);
  static const _radius = 24.0;
  static const _spacing = 24.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkThemeProvider>(context).isDarkTheme();
    final isDesktop = ResponsiveWidget.isDesktop(context);
    final c = Get.find<DashboardHomeController>();

    return Obx(() {
      if (c.isLoading.value) {
        return Center(
          child: MahekLoader(
            message: 'Loading...',
            size: 40,
            textSize: 13,
            style: MahekLoaderStyle.ring,
          ),
        );
      }

      return Container(
        color: isDark ? _bg : AppThemeData.grey1,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(isDesktop ? _spacing : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(c, isDesktop, isDark),
              spaceH(height: _spacing),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildHeroCard(c, isDark)),
                    spaceW(width: _spacing),
                    Expanded(flex: 1, child: _buildProfileSummary(c, isDark)),
                  ],
                )
              else ...[
                _buildHeroCard(c, isDark),
                spaceH(height: 16),
                _buildProfileSummary(c, isDark),
              ],
              spaceH(height: _spacing),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDevicesWidget(c, isDark)),
                    spaceW(width: _spacing),
                    Expanded(child: _buildPurchasesWidget(c, isDark)),
                  ],
                )
              else ...[
                _buildDevicesWidget(c, isDark),
                spaceH(height: 16),
                _buildPurchasesWidget(c, isDark),
              ],
              spaceH(height: _spacing),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildActivityWidget(c, isDark)),
                    spaceW(width: _spacing),
                    SizedBox(
                      width: 280,
                      child: _buildAnalyticsWidget(c, isDark),
                    ),
                  ],
                )
              else ...[
                _buildActivityWidget(c, isDark),
                spaceH(height: 16),
                _buildAnalyticsWidget(c, isDark),
              ],
              spaceH(height: _spacing),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTasksWidget(c, isDark)),
                    spaceW(width: _spacing),
                    Expanded(child: _buildRemindersWidget(c, isDark)),
                  ],
                )
              else ...[
                _buildTasksWidget(c, isDark),
                spaceH(height: 16),
                _buildRemindersWidget(c, isDark),
              ],
              spaceH(height: _spacing),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSentinelWidget(c, isDark)),
                    spaceW(width: _spacing),
                    Expanded(child: _buildVaultWidget(c, isDark)),
                  ],
                )
              else ...[
                _buildSentinelWidget(c, isDark),
                spaceH(height: 16),
                _buildVaultWidget(c, isDark),
              ],
              spaceH(height: 32),
            ],
          ),
        ),
      );
    });
  }

  // ─── Header ─────────────────────────────────────────────────────
  Widget _buildHeader(DashboardHomeController c, bool isDesktop, bool isDark) {
    final name = MahekConstant.ownerModel?.fullName ?? 'User';
    return Row(
      children: [
        TextCustom(
          title: 'Good ${_greeting()}, $name',
          fontSize: isDesktop ? 28 : 22,
          fontFamily: FontFamily.bold,
          color: isDark ? _textPrimary : AppThemeData.grey10,
        ),
        const Spacer(),
        if (c.hasAlerts)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _accentRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accentRed.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: _accentRed),
                spaceW(width: 8),
                TextCustom(title: '${c.overdueTaskCount + c.highPriorityReminderCount} Alerts', fontSize: 13, fontFamily: FontFamily.semiBold, color: _accentRed),
              ],
            ),
          ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  // ─── Hero Card ──────────────────────────────────────────────────
  Widget _buildHeroCard(DashboardHomeController c, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF252D4A), Color(0xFF171A23)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextCustom(
            title: 'Your digital life, organized.',
            fontSize: 22,
            fontFamily: FontFamily.bold,
            color: isDark ? _textPrimary : AppThemeData.grey10,
          ),
          spaceH(height: 8),
          TextCustom(
            title: '${c.totalItems} records across ${c.totalModules} active modules.',
            fontSize: 15,
            fontFamily: FontFamily.regular,
            color: isDark ? _textSecondary : AppThemeData.grey7,
          ),
          spaceH(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _quickActionChip('Add Task', Icons.add_rounded, _accentPurple, Routes.PERSONAL_TASKS),
              _quickActionChip('Add Device', Icons.add_rounded, _accentBlue, Routes.MY_DEVICES),
              _quickActionChip('Add Purchase', Icons.add_rounded, _accentGreen, Routes.MY_PURCHASES),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActionChip(String label, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Get.find<DashboardController>().navigateToRoute(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            spaceW(width: 8),
            TextCustom(title: label, fontSize: 13, fontFamily: FontFamily.semiBold, color: color),
          ],
        ),
      ),
    );
  }

  // ─── Profile Summary ────────────────────────────────────────────
  Widget _buildProfileSummary(DashboardHomeController c, bool isDark) {
    final score = c.sentinelPasswordSet.value ? 92 : 20;
    final scoreColor = score > 70 ? _accentGreen : (score > 40 ? _accentAmber : _accentRed);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? _card : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border.withOpacity(isDark ? 1 : 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _accentBlue.withOpacity(0.1),
                child: Icon(Icons.person, size: 20, color: _accentBlue),
              ),
              spaceW(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextCustom(title: MahekConstant.ownerModel?.fullName ?? 'User', fontSize: 15, fontFamily: FontFamily.semiBold, color: isDark ? _textPrimary : AppThemeData.grey10, maxLine: 1),
                    TextCustom(title: 'Personal Workspace', fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? _textTertiary : AppThemeData.grey6),
                  ],
                ),
              ),
            ],
          ),
          spaceH(height: 24),
          _profileStatRow(Icons.devices_rounded, '${c.deviceCount.value} Devices', _accentBlue, isDark),
          spaceH(height: 12),
          _profileStatRow(Icons.people_rounded, '${c.contactCount.value} Contacts', _accentPurple, isDark),
          spaceH(height: 12),
          _profileStatRow(Icons.shield_rounded, 'Security: $score', scoreColor, isDark),
        ],
      ),
    );
  }

  Widget _profileStatRow(IconData icon, String text, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        spaceW(width: 10),
        TextCustom(title: text, fontSize: 13, fontFamily: FontFamily.medium, color: isDark ? _textSecondary : AppThemeData.grey7),
      ],
    );
  }

  // ─── Devices Widget ─────────────────────────────────────────────
  Widget _buildDevicesWidget(DashboardHomeController c, bool isDark) {
    return _workspaceCard(
      title: 'My Devices',
      icon: Icons.devices_rounded,
      accent: _accentBlue,
      route: Routes.MY_DEVICES,
      isDark: isDark,
      child: Obx(() {
        final items = c.latestDevices;
        if (items.isEmpty) return _emptyState('No devices added yet', isDark);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((d) => _listItem(
            title: d.deviceName ?? 'Unknown',
            subtitle: d.brandName ?? 'Device',
            isDark: isDark,
          )).toList(),
        );
      }),
    );
  }

  // ─── Purchases Widget ───────────────────────────────────────────
  Widget _buildPurchasesWidget(DashboardHomeController c, bool isDark) {
    return _workspaceCard(
      title: 'Purchases',
      icon: Icons.shopping_bag_rounded,
      accent: _accentGreen,
      route: Routes.MY_PURCHASES,
      isDark: isDark,
      child: Obx(() {
        final items = c.latestPurchases;
        if (items.isEmpty) return _emptyState('No purchases tracked', isDark);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((p) => _listItem(
            title: p.assetName ?? 'Purchase',
            subtitle: p.formattedPrice,
            isDark: isDark,
          )).toList(),
        );
      }),
    );
  }

  // ─── Activity Widget ────────────────────────────────────────────
  Widget _buildActivityWidget(DashboardHomeController c, bool isDark) {
    return _workspaceCard(
      title: 'Recent Activity',
      icon: Icons.history_rounded,
      accent: _textSecondary,
      isDark: isDark,
      child: Obx(() {
        final items = <_ActivityItem>[];
        if (c.latestDevices.isNotEmpty) items.add(_ActivityItem(c.latestDevices.first.deviceName ?? 'Device', 'Device added', Icons.devices_rounded, _accentBlue));
        if (c.latestPurchases.isNotEmpty) items.add(_ActivityItem(c.latestPurchases.first.assetName ?? 'Purchase', 'Purchased', Icons.shopping_bag_rounded, _accentGreen));
        if (c.latestTasks.isNotEmpty) {
          final t = c.latestTasks.first;
          items.add(_ActivityItem(t.title ?? 'Task', t.isCompleted == true ? 'Completed' : 'Pending', Icons.task_alt_rounded, t.isCompleted == true ? _accentGreen : _accentAmber));
        }
        if (c.latestReminders.isNotEmpty) items.add(_ActivityItem(c.latestReminders.first.name ?? 'Reminder', 'Scheduled', Icons.alarm_rounded, _accentRed));

        if (items.isEmpty) return _emptyState('No activity yet', isDark);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((a) => _timelineRow(a, isDark)).toList(),
        );
      }),
    );
  }

  Widget _timelineRow(_ActivityItem a, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: a.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(a.icon, size: 14, color: a.color),
          ),
          spaceW(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextCustom(title: a.title, fontSize: 14, fontFamily: FontFamily.medium, color: isDark ? _textPrimary : AppThemeData.grey10, maxLine: 1),
                spaceH(height: 2),
                TextCustom(title: a.subtitle, fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? _textTertiary : AppThemeData.grey6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Analytics Widget ───────────────────────────────────────────
  Widget _buildAnalyticsWidget(DashboardHomeController c, bool isDark) {
    return _workspaceCard(
      title: 'Overview',
      icon: Icons.donut_large_rounded,
      accent: _accentPurple,
      isDark: isDark,
      child: Obx(() {
        final data = [
          ChartDataPoint(label: 'Devices', value: c.deviceCount.value.toDouble(), color: _accentBlue),
          ChartDataPoint(label: 'Tasks', value: c.taskCount.value.toDouble(), color: _accentPurple),
          ChartDataPoint(label: 'Purchases', value: c.purchaseCount.value.toDouble(), color: _accentGreen),
          ChartDataPoint(label: 'Dues', value: c.duesCount.value.toDouble(), color: _accentRed),
        ];

        if (data.every((d) => d.value == 0)) return _emptyState('Add items to see analytics', isDark);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDonutChart(data: data, size: 160, strokeWidth: 20),
            spaceH(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: data.where((d) => d.value > 0).map((d) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
                  spaceW(width: 6),
                  TextCustom(title: d.label, fontSize: 12, fontFamily: FontFamily.medium, color: isDark ? _textSecondary : AppThemeData.grey7),
                ],
              )).toList(),
            ),
          ],
        );
      }),
    );
  }

  // ─── Tasks Widget ───────────────────────────────────────────────
  Widget _buildTasksWidget(DashboardHomeController c, bool isDark) {
    return _workspaceCard(
      title: 'Tasks',
      icon: Icons.task_alt_rounded,
      accent: _accentPurple,
      route: Routes.PERSONAL_TASKS,
      isDark: isDark,
      badgeCount: c.overdueTaskCount, // int getter, no .value
      child: Obx(() {
        final items = c.latestTasks;
        if (items.isEmpty) return _emptyState('All clear', isDark);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((t) => _taskRow(t, isDark)).toList(),
        );
      }),
    );
  }

  Widget _taskRow(PersonalTaskModel t, bool isDark) {
    final done = t.isCompleted == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: done ? _accentGreen : _textTertiary),
          spaceW(width: 12),
          Expanded(child: TextCustom(title: t.title ?? '-', fontSize: 14, fontFamily: FontFamily.medium, color: isDark ? (done ? _textTertiary : _textPrimary) : AppThemeData.grey10, maxLine: 1, islineThrough: done)),
        ],
      ),
    );
  }

  // ─── Reminders Widget ───────────────────────────────────────────
  Widget _buildRemindersWidget(DashboardHomeController c, bool isDark) {
    return _workspaceCard(
      title: 'Reminders',
      icon: Icons.alarm_rounded,
      accent: _accentAmber,
      route: Routes.REMINDER,
      isDark: isDark,
      child: Obx(() {
        final items = c.latestReminders;
        if (items.isEmpty) return _emptyState('No upcoming reminders', isDark);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((r) => _reminderRow(r, isDark)).toList(),
        );
      }),
    );
  }

  Widget _reminderRow(ReminderModel r, bool isDark) {
    final isHigh = r.importance == 'HIGH';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: (isHigh ? _accentRed : _accentAmber).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.alarm, size: 14, color: isHigh ? _accentRed : _accentAmber),
          ),
          spaceW(width: 12),
          Expanded(child: TextCustom(title: r.name ?? '-', fontSize: 14, fontFamily: FontFamily.medium, color: isDark ? _textPrimary : AppThemeData.grey10, maxLine: 1)),
          if (isHigh) Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: _accentRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: TextCustom(title: 'HIGH', fontSize: 10, fontFamily: FontFamily.bold, color: _accentRed),
          ),
        ],
      ),
    );
  }

  // ─── Sentinel Widget ────────────────────────────────────────────
  Widget _buildSentinelWidget(DashboardHomeController c, bool isDark) {
    return _workspaceCard(
      title: 'Sentinel',
      icon: SolarIconsOutline.shieldKeyhole,
      accent: _accentBlue,
      route: Routes.SENTINEL,
      isDark: isDark,
      child: Obx(() {
        final isOn = c.sentinelPasswordSet.value;
        final isLocked = c.sentinelLocked.value;
        return Row(
          children: [
            Icon(isOn ? (isLocked ? Icons.lock_rounded : Icons.shield_rounded) : Icons.shield_outlined, size: 28, color: isOn ? _accentBlue : _textTertiary),
            spaceW(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextCustom(title: isOn ? (isLocked ? 'Locked' : 'Protected') : 'Not Set', fontSize: 16, fontFamily: FontFamily.semiBold, color: isDark ? _textPrimary : AppThemeData.grey10),
                spaceH(height: 2),
                TextCustom(title: isOn ? 'System is secure' : 'Configure security', fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? _textTertiary : AppThemeData.grey6),
              ],
            ),
          ],
        );
      }),
    );
  }

  // ─── Vault Widget ───────────────────────────────────────────────
  Widget _buildVaultWidget(DashboardHomeController c, bool isDark) {
    return _workspaceCard(
      title: 'Vault',
      icon: Icons.lock_outline,
      accent: _accentPurple,
      route: Routes.VAULT,
      isDark: isDark,
      child: Obx(() {
        return Row(
          children: [
            Icon(Icons.lock_outline, size: 28, color: _accentPurple),
            spaceW(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextCustom(title: '${c.vaultCount.value} Items', fontSize: 16, fontFamily: FontFamily.semiBold, color: isDark ? _textPrimary : AppThemeData.grey10),
                spaceH(height: 2),
                TextCustom(title: 'Encrypted & secured', fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? _textTertiary : AppThemeData.grey6),
              ],
            ),
          ],
        );
      }),
    );
  }

  // ─── Shared Components ──────────────────────────────────────────
  Widget _workspaceCard({
    required String title,
    required IconData icon,
    required Color accent,
    required bool isDark,
    required Widget child,
    String? route,
    int badgeCount = 0,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? _card : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border.withOpacity(isDark ? 1 : 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              spaceW(width: 10),
              TextCustom(title: title, fontSize: 17, fontFamily: FontFamily.bold, color: isDark ? _textPrimary : AppThemeData.grey10),
              if (badgeCount > 0) ...[
                spaceW(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: _accentRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: TextCustom(title: '$badgeCount', fontSize: 10, fontFamily: FontFamily.bold, color: _accentRed),
                ),
              ],
              const Spacer(),
              if (route != null)
                GestureDetector(
                  onTap: () => Get.find<DashboardController>().navigateToRoute(route),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextCustom(title: 'View All', fontSize: 12, fontFamily: FontFamily.medium, color: isDark ? _textTertiary : AppThemeData.grey6),
                      spaceW(width: 4),
                      Icon(Icons.chevron_right, size: 16, color: isDark ? _textTertiary : AppThemeData.grey6),
                    ],
                  ),
                ),
            ],
          ),
          spaceH(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _listItem({required String title, required String subtitle, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextCustom(title: title, fontSize: 14, fontFamily: FontFamily.medium, color: isDark ? _textPrimary : AppThemeData.grey10, maxLine: 1),
                TextCustom(title: subtitle, fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? _textTertiary : AppThemeData.grey6, maxLine: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: TextCustom(title: text, fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? _textTertiary : AppThemeData.grey6),
      ),
    );
  }
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _ActivityItem(this.title, this.subtitle, this.icon, this.color);
}