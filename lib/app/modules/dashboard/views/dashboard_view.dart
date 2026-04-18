// lib/app/modules/dashboard/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import '../../../constant/constants.dart';
import '../../my_devices/bindings/my_devices_binding.dart';
import '../../my_devices/controllers/my_devices_controller.dart';
import '../../my_devices/views/my_devices_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // Fixed Sidebar Navigation
          _buildSidebar(context, isDark, themeChange),
          // Dynamic Content Area
          Expanded(child: _buildContentArea(context, isDark, themeChange)),
        ],
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    bool isDark,
    DarkThemeProvider themeChange,
  ) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildUserProfile(isDark),
          Expanded(child: _buildNavigationMenu(isDark)),
        ],
      ),
    );
  }

  Widget _buildUserProfile(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D54F2), Color(0xFF8B7EFF)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                MahekConstant.ownerModel?.fullName?[0].toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontFamily: FontFamily.semiBold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          spaceW(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MahekConstant.ownerModel?.fullName ?? 'User Name',
                  style: TextStyle(
                    fontFamily: FontFamily.semiBold,
                    fontSize: 15,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                spaceH(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D54F2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PRO MEMBER',
                    style: TextStyle(
                      fontFamily: FontFamily.semiBold,
                      fontSize: 9,
                      letterSpacing: 1,
                      color: const Color(0xFF5D54F2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        _buildNavSection('MAIN', isDark),
        spaceH(height: 8),
        _buildNavItem(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          index: 0,
          isDark: isDark,
        ),
        _buildNavItem(
          icon: Icons.devices_outlined,
          label: 'My Devices',
          index: 1,
          isDark: isDark,
        ),
        _buildNavItem(
          icon: Icons.verified_outlined,
          label: 'Warranty Tracker',
          index: 2,
          isDark: isDark,
        ),
        _buildNavItem(
          icon: Icons.receipt_outlined,
          label: 'Expenses',
          index: 3,
          isDark: isDark,
        ),
        spaceH(height: 24),
        _buildNavSection('PREFERENCES', isDark),
        spaceH(height: 8),
        _buildNavItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
          index: 4,
          isDark: isDark,
        ),
        _buildNavItem(
          icon: Icons.headset_mic_outlined,
          label: 'Support',
          index: 5,
          isDark: isDark,
        ),
        spaceH(height: 24),
        _buildNavItem(
          icon: Icons.logout_outlined,
          label: 'Sign Out',
          index: 6,
          isDark: isDark,
          isDestructive: true,
          onTap: () => controller.signOut(),
        ),
      ],
    );
  }

  Widget _buildNavSection(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: TextCustom(
        title: title,
        fontSize: 11,
        fontFamily: FontFamily.semiBold,
        color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Obx(() {
      final isActive = controller.selectedIndex.value == index;
      final activeColor = isDestructive
          ? const Color(0xFFEF4444)
          : const Color(0xFF5D54F2);

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap ?? () {
            controller.onNavItemTapped(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive && !isDestructive
                  ? activeColor.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isActive || isDestructive
                        ? activeColor
                        : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                  ),
                ),
                spaceW(width: 14),
                Expanded(
                  child: TextCustom(
                    title: label,
                    fontSize: 14,
                    fontFamily: isActive
                        ? FontFamily.semiBold
                        : FontFamily.medium,
                    color: isActive || isDestructive
                        ? activeColor
                        : (isDark ? AppThemeData.grey3 : AppThemeData.grey8),
                  ),
                ),
                if (isActive && !isDestructive)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

// Replace _buildContentArea method
  Widget _buildContentArea(
      BuildContext context,
      bool isDark,
      DarkThemeProvider themeChange,
      ) {
    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : const Color(0xFFF5F7FA),
      appBar: _buildContentAppBar(isDark, themeChange),
      body: _buildCurrentContent(isDark), // Remove Obx wrapper
    );
  }

// Update _buildContentAppBar to use Obx only where needed
  PreferredSizeWidget _buildContentAppBar(
      bool isDark,
      DarkThemeProvider themeChange,
      ) {
    return AppBar(
      backgroundColor: isDark ? AppThemeData.primaryBlack : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 24,
      title: Obx(() {
        final titles = [
          'Dashboard',
          'My Devices',
          'Warranty Tracker',
          'Expenses',
          'Settings',
          'Support',
          '',
        ];
        final subtitles = [
          'Overview of your inventory and insights',
          'Manage and track all your registered devices',
          'Monitor warranty status and expiration dates',
          'Track spending and generate expense reports',
          'Configure your account and preferences',
          'Get help and contact our support team',
          '',
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: titles[controller.selectedIndex.value],
              fontSize: 24,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            spaceH(height: 4),
            TextCustom(
              title: subtitles[controller.selectedIndex.value],
              fontSize: 14,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        );
      }),
      actions: [
        // Theme Toggle Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(30),
          ),
          child: IconButton(
            onPressed: () {
              themeChange.darkTheme = themeChange.darkTheme == 0 ? 1 : 0;
            },
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? Colors.amber : AppThemeData.grey7,
              size: 20,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ),
        // Search Field (only for My Devices)
        Obx(() {  // Wrap only the conditional widget with Obx
          if (controller.selectedIndex.value == 1) {
            return Container(
              width: 260,
              height: 44,
              margin: const EdgeInsets.only(right: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search devices...',
                  hintStyle: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 14,
                    color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  ),
                  filled: true,
                  fillColor: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.search_outlined,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    size: 20,
                  ),
                ),
              ),
            );
          }
          return spaceW(width: 8); // Return empty widget when not shown
        }),
      ],
    );
  }

  Widget _buildCurrentContent(bool isDark) {
    return Obx(() {
      switch (controller.selectedIndex.value) {
        case 0:
          return _buildDashboardContent(isDark);

        case 1:
          if (!Get.isRegistered<MyDevicesController>()) {
            MyDevicesBinding().dependencies();
          }
          return const MyDevicesView(); // ✅ IMPORTANT (missing)

        case 2:
          return _buildWarrantyContent(isDark);

        case 3:
          return _buildExpensesContent(isDark);

        case 4:
          return _buildSettingsContent(isDark);

        case 5:
          return _buildSupportContent(isDark);

        default:
          return _buildDashboardContent(isDark);
      }
    });
  }

  Widget _buildDashboardContent(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          _buildStatsRow(isDark),
          spaceH(height: 24),
          // Two Column Layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRecentActivityCard(isDark)),
              spaceW(width: 24),
              Expanded(child: _buildInsightsCard(isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        _buildStatCard(
          label: 'Total Devices',
          value: '12',
          icon: Icons.devices_outlined,
          isDark: isDark,
        ),
        spaceW(width: 20),
        _buildStatCard(
          label: 'Active Warranties',
          value: '8',
          icon: Icons.verified_outlined,
          isDark: isDark,
        ),
        spaceW(width: 20),
        _buildStatCard(
          label: 'Total Spent',
          value: '\$5,596',
          icon: Icons.payments_outlined,
          isDark: isDark,
        ),
        spaceW(width: 20),
        _buildStatCard(
          label: 'Expiring Soon',
          value: '2',
          icon: Icons.warning_amber_outlined,
          isDark: isDark,
          isWarning: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    bool isWarning = false,
  }) {
    final accentColor = isWarning
        ? Colors.amber[700]!
        : const Color(0xFF5D54F2);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.primaryBlack : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            spaceW(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: value,
                  fontSize: 28,
                  fontFamily: FontFamily.bold,
                  color: isDark ? Colors.white : AppThemeData.grey10,
                ),
                TextCustom(
                  title: label,
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            title: 'Recent Activity',
            fontSize: 18,
            fontFamily: FontFamily.bold,
            color: isDark ? Colors.white : AppThemeData.grey10,
          ),
          spaceH(height: 20),
          _buildActivityItem(
            icon: Icons.add_circle_outline,
            title: 'New device registered',
            subtitle: 'MacBook Pro 14" added to inventory',
            time: '2 hours ago',
            isDark: isDark,
          ),
          _buildActivityItem(
            icon: Icons.warning_amber_outlined,
            title: 'Warranty expiring soon',
            subtitle: 'iPhone 15 Pro Max warranty ends in 30 days',
            time: '5 hours ago',
            isDark: isDark,
            isWarning: true,
          ),
          _buildActivityItem(
            icon: Icons.receipt_outlined,
            title: 'Receipt uploaded',
            subtitle: 'iPad Pro purchase receipt added',
            time: 'Yesterday',
            isDark: isDark,
          ),
          _buildActivityItem(
            icon: Icons.update_outlined,
            title: 'Device updated',
            subtitle: 'Apple Watch Ultra details updated',
            time: '2 days ago',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required bool isDark,
    bool isWarning = false,
  }) {
    final iconColor = isWarning ? Colors.amber[700]! : const Color(0xFF5D54F2);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          spaceW(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: title,
                  fontSize: 14,
                  fontFamily: FontFamily.semiBold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                spaceH(height: 2),
                TextCustom(
                  title: subtitle,
                  fontSize: 13,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ),
          TextCustom(
            title: time,
            fontSize: 12,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            title: 'Quick Insights',
            fontSize: 18,
            fontFamily: FontFamily.bold,
            color: isDark ? Colors.white : AppThemeData.grey10,
          ),
          spaceH(height: 20),
          _buildInsightItem(
            label: 'Most Used Device',
            value: 'MacBook Pro 14"',
            icon: Icons.laptop_mac_outlined,
            isDark: isDark,
          ),
          spaceH(height: 16),
          _buildInsightItem(
            label: 'Total Warranty Value',
            value: '\$4,596',
            icon: Icons.shield_outlined,
            isDark: isDark,
          ),
          spaceH(height: 16),
          _buildInsightItem(
            label: 'Avg. Device Age',
            value: '1.4 years',
            icon: Icons.calendar_today_outlined,
            isDark: isDark,
          ),
          spaceH(height: 16),
          _buildInsightItem(
            label: 'Next Expiration',
            value: 'Oct 24, 2025',
            icon: Icons.event_busy_outlined,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceW(width: 12),
        Expanded(
          child: TextCustom(
            title: label,
            fontSize: 14,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        TextCustom(
          title: value,
          fontSize: 14,
          fontFamily: FontFamily.semiBold,
          color: isDark ? Colors.white : AppThemeData.grey10,
        ),
      ],
    );
  }

  // Placeholder content methods
  Widget _buildWarrantyContent(bool isDark) {
    return _buildPlaceholderContent(
      title: 'Warranty Tracker',
      description: 'Track warranty status and expiration dates.',
      icon: Icons.verified_outlined,
      isDark: isDark,
    );
  }

  Widget _buildExpensesContent(bool isDark) {
    return _buildPlaceholderContent(
      title: 'Expenses',
      description: 'Monitor your spending and generate reports.',
      icon: Icons.receipt_outlined,
      isDark: isDark,
    );
  }

  Widget _buildSettingsContent(bool isDark) {
    return _buildPlaceholderContent(
      title: 'Settings',
      description: 'Configure your account preferences.',
      icon: Icons.settings_outlined,
      isDark: isDark,
    );
  }

  Widget _buildSupportContent(bool isDark) {
    return _buildPlaceholderContent(
      title: 'Support',
      description: 'Get help from our support team.',
      icon: Icons.headset_mic_outlined,
      isDark: isDark,
    );
  }

  Widget _buildPlaceholderContent({
    required String title,
    required String description,
    required IconData icon,
    required bool isDark,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF5D54F2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 40, color: const Color(0xFF5D54F2)),
          ),
          spaceH(height: 24),
          TextCustom(
            title: title,
            fontSize: 24,
            fontFamily: FontFamily.bold,
            color: isDark ? Colors.white : AppThemeData.grey10,
          ),
          spaceH(height: 8),
          TextCustom(
            title: description,
            fontSize: 16,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          spaceH(height: 24),
          TextCustom(
            title: 'Coming Soon',
            fontSize: 14,
            fontFamily: FontFamily.medium,
            color: const Color(0xFF5D54F2),
          ),
        ],
      ),
    );
  }
}
