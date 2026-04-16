// lib/app/modules/dashboard/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import '../../../constant/constants.dart' ;
import '../../../routes/app_pages.dart';
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
          _buildSidebar(context, isDark),
          // Dynamic Content Area
          Expanded(
            child: _buildContentArea(context, isDark),
          ),
        ],
      ),
    );
  }

// In dashboard_view.dart - update _buildSidebar
  Widget _buildSidebar(BuildContext context, bool isDark) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
      child: Text(
        title,
        style: TextStyle(
          fontFamily: FontFamily.semiBold,
          fontSize: 11,
          letterSpacing: 1.5,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
      ),
    );
  }

// In dashboard_view.dart - replace the local onNavItemTapped method with:

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
            controller.selectedIndex.value = index;

            // Navigate to separate views
            switch (index) {
              case 0:
                Get.offAllNamed(Routes.DASHBOARD);
                break;
              case 1:
                Get.offAllNamed(Routes.MY_DEVICES);
                break;
              case 2:
              // Get.offAllNamed(Routes.WARRANTY_TRACKER);
                break;
              case 3:
              // Get.offAllNamed(Routes.EXPENSES);
                break;
              case 4:
              // Get.offAllNamed(Routes.SETTINGS);
                break;
              case 5:
              // Get.offAllNamed(Routes.SUPPORT);
                break;
            }
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
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: isActive ? FontFamily.semiBold : FontFamily.medium,
                      fontSize: 14,
                      color: isActive || isDestructive
                          ? activeColor
                          : (isDark ? AppThemeData.grey3 : AppThemeData.grey8),
                    ),
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


  Widget _buildContentArea(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : const Color(0xFFF5F7FA),
      appBar: _buildContentAppBar(isDark),
      body: Obx(() => _buildCurrentContent(isDark)),
    );
  }

  PreferredSizeWidget _buildContentAppBar(bool isDark) {
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
            Text(
              titles[controller.selectedIndex.value],
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 24,
                letterSpacing: -0.3,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ),
            spaceH(height: 4),
            Text(
              subtitles[controller.selectedIndex.value],
              style: TextStyle(
                fontFamily: FontFamily.regular,
                fontSize: 14,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ),
          ],
        );
      }),
      actions: [
        // Search Field
        Container(
          width: 260,
          height: 44,
          margin: const EdgeInsets.only(right: 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search devices, warranties...',
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
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF5D54F2),
                  width: 1.5,
                ),
              ),
              prefixIcon: Icon(
                Icons.search_outlined,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        // Filter Button
        Container(
          margin: const EdgeInsets.only(right: 24),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_outlined,
                      size: 18,
                      color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                    ),
                    spaceW(width: 8),
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 13,
                        color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentContent(bool isDark) {
    switch (controller.selectedIndex.value) {
      case 0:
        return _buildDashboardContent(isDark);
      case 1:
        return _buildMyDevicesContent(isDark);
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
              Expanded(
                flex: 2,
                child: _buildRecentActivityCard(isDark),
              ),
              spaceW(width: 24),
              Expanded(
                child: _buildInsightsCard(isDark),
              ),
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
    final accentColor = isWarning ? Colors.amber[700]! : const Color(0xFF5D54F2);

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
              child: Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
            ),
            spaceW(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 28,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : AppThemeData.grey10,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 13,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
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
          Text(
            'Recent Activity',
            style: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppThemeData.grey10,
            ),
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
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: FontFamily.semiBold,
                    fontSize: 14,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ),
                spaceH(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 13,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 12,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
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
          Text(
            'Quick Insights',
            style: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppThemeData.grey10,
            ),
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
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 14,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: FontFamily.semiBold,
            fontSize: 14,
            color: isDark ? Colors.white : AppThemeData.grey10,
          ),
        ),
      ],
    );
  }

  // Placeholder content methods
  Widget _buildMyDevicesContent(bool isDark) {
    return _buildPlaceholderContent(
      title: 'My Devices',
      description: 'Your registered devices will appear here.',
      icon: Icons.devices_outlined,
      isDark: isDark,
    );
  }

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
            child: Icon(
              icon,
              size: 40,
              color: const Color(0xFF5D54F2),
            ),
          ),
          spaceH(height: 24),
          Text(
            title,
            style: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 24,
              color: isDark ? Colors.white : AppThemeData.grey10,
            ),
          ),
          spaceH(height: 8),
          Text(
            description,
            style: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 16,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ),
          spaceH(height: 24),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontFamily: FontFamily.medium,
              fontSize: 14,
              color: const Color(0xFF5D54F2),
            ),
          ),
        ],
      ),
    );
  }
}