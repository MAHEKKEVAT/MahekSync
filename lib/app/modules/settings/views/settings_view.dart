import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final isDark = theme.isDarkTheme();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.primaryBlack : AppThemeData.grey1,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: MahekLoader());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              spaceH(height: 24),
              _buildStatsRow(isDark, isMobile),
              spaceH(height: 32),
              _buildCategoriesGrid(isDark, isMobile, context),
            ],
          ),
        );
      }),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppThemeData.primary50.withValues(alpha: 0.2),
                AppThemeData.primary50.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppThemeData.primary50.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.settings_rounded,
            size: 28,
            color: AppThemeData.primary50,
          ),
        ),
        spaceW(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: 'Settings',
              fontSize: 26,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            spaceH(height: 4),
            TextCustom(
              title: 'Manage your account and preferences',
              fontSize: 14,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ],
    );
  }

  // ── 4 Stat Cards ────────────────────────────────────────────────────
  Widget _buildStatsRow(bool isDark, bool isMobile) {
    final stats = [
      _StatData(
        icon: Icons.person_rounded,
        label: 'Profile',
        value: controller.displayName,
        sub: controller.accountType,
        color: AppThemeData.neonPurple,
      ),
      _StatData(
        icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        label: 'Theme',
        value: controller.themeModeLabel,
        sub: 'Appearance mode',
        color: AppThemeData.neonTeal,
      ),
      _StatData(
        icon: Icons.notifications_rounded,
        label: 'Notifications',
        value: controller.pushNotifications.value ? 'On' : 'Off',
        sub: '${controller.reminderAlerts.value ? '3' : '2'} alerts active',
        color: AppThemeData.neonOrange,
      ),
      _StatData(
        icon: Icons.shield_rounded,
        label: 'Security',
        value: controller.twoFactorAuth.value ? '2FA On' : 'Basic',
        sub: controller.biometricLock.value ? 'Biometric On' : 'No biometric',
        color: AppThemeData.neonMint,
      ),
    ];

    return isMobile
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard(stats[0], isDark)),
                  spaceW(width: 12),
                  Expanded(child: _buildStatCard(stats[1], isDark)),
                ],
              ),
              spaceH(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard(stats[2], isDark)),
                  spaceW(width: 12),
                  Expanded(child: _buildStatCard(stats[3], isDark)),
                ],
              ),
            ],
          )
        : Row(
            children: stats
                .map((s) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _buildStatCard(s, isDark),
                      ),
                    ))
                .toList(),
          );
  }

  Widget _buildStatCard(_StatData stat, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stat.color.withValues(alpha: isDark ? 0.2 : 0.12),
            stat.color.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stat.color.withValues(alpha: isDark ? 0.25 : 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  stat.color.withValues(alpha: 0.9),
                  stat.color,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: stat.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(stat.icon, size: 20, color: Colors.white),
          ),
          spaceW(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 11,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                  ),
                ),
                spaceH(height: 3),
                Text(
                  stat.value,
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 22,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                    letterSpacing: -0.5,
                  ),
                ),
                spaceH(height: 2),
                Text(
                  stat.sub,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 10,
                    color: stat.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Categories Grid (2-column on desktop) ───────────────────────────
  Widget _buildCategoriesGrid(bool isDark, bool isMobile, BuildContext context) {
    final categories = _buildCategories(isDark, context);

    if (isMobile) {
      return Column(
        children: categories.map((cat) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildCategorySection(cat, isDark, context),
        )).toList(),
      );
    }

    // Desktop: 2-column layout using Row + Expanded
    final leftColumn = <_CategoryData>[];
    final rightColumn = <_CategoryData>[];
    for (int i = 0; i < categories.length; i++) {
      if (i.isEven) {
        leftColumn.add(categories[i]);
      } else {
        rightColumn.add(categories[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn.map((cat) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildCategorySection(cat, isDark, context),
            )).toList(),
          ),
        ),
        spaceW(width: 24),
        Expanded(
          child: Column(
            children: rightColumn.map((cat) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildCategorySection(cat, isDark, context),
            )).toList(),
          ),
        ),
      ],
    );
  }

  List<_CategoryData> _buildCategories(bool isDark, BuildContext context) {
    return [
      // ── Profile ───────────────────────────────
      _CategoryData(
        title: 'PROFILE',
        icon: Icons.person_outline_rounded,
        color: AppThemeData.neonPurple,
        items: [
          _SettingItem(
            icon: Icons.badge_rounded,
            title: 'Display Name',
            value: controller.displayName,
            color: AppThemeData.neonPurple,
          ),
          _SettingItem(
            icon: Icons.email_rounded,
            title: 'Email',
            value: controller.email,
            color: AppThemeData.neonBlue,
          ),
          _SettingItem(
            icon: Icons.camera_alt_rounded,
            title: 'Profile Photo',
            value: controller.profilePic.isNotEmpty ? 'Uploaded' : 'Not set',
            color: AppThemeData.neonTeal,
          ),
          _SettingItem(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Account Type',
            value: controller.accountType,
            color: AppThemeData.neonMint,
          ),
        ],
      ),

      // ── Appearance ─────────────────────────────
      _CategoryData(
        title: 'APPEARANCE',
        icon: Icons.palette_outlined,
        color: AppThemeData.neonTeal,
        items: [
          _SettingItem(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'Theme Mode',
            value: controller.themeModeLabel,
            color: AppThemeData.neonTeal,
            isToggle: true,
            toggleValue: isDark,
            onToggle: () => controller.toggleThemeMode(context),
          ),
          _SettingItem(
            icon: Icons.color_lens_rounded,
            title: 'Accent Color',
            value: controller.accentColor.value,
            color: AppThemeData.neonPurple,
          ),
          _SettingItem(
            icon: Icons.language_rounded,
            title: 'Language',
            value: controller.language.value,
            color: AppThemeData.neonBlue,
          ),
        ],
      ),

      // ── Notifications ──────────────────────────
      _CategoryData(
        title: 'NOTIFICATIONS',
        icon: Icons.notifications_outlined,
        color: AppThemeData.neonOrange,
        items: [
          _SettingItem(
            icon: Icons.notifications_active_rounded,
            title: 'Push Notifications',
            value: '',
            color: AppThemeData.neonOrange,
            isToggle: true,
            toggleValue: controller.pushNotifications.value,
            onToggle: () => controller.togglePushNotifications(),
          ),
          _SettingItem(
            icon: Icons.mail_rounded,
            title: 'Email Notifications',
            value: '',
            color: AppThemeData.neonPink,
            isToggle: true,
            toggleValue: controller.emailNotifications.value,
            onToggle: () => controller.toggleEmailNotifications(),
          ),
          _SettingItem(
            icon: Icons.alarm_rounded,
            title: 'Reminder Alerts',
            value: '',
            color: AppThemeData.neonYellow,
            isToggle: true,
            toggleValue: controller.reminderAlerts.value,
            onToggle: () => controller.toggleReminderAlerts(),
          ),
        ],
      ),

      // ── Security ───────────────────────────────
      _CategoryData(
        title: 'SECURITY',
        icon: Icons.shield_outlined,
        color: AppThemeData.neonMint,
        items: [
          _SettingItem(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Lock',
            value: '',
            color: AppThemeData.neonMint,
            isToggle: true,
            toggleValue: controller.biometricLock.value,
            onToggle: () => controller.toggleBiometricLock(),
          ),
          _SettingItem(
            icon: Icons.lock_clock_rounded,
            title: 'Auto-Lock Timeout',
            value: controller.autoLockTimeout.value,
            color: AppThemeData.neonTeal,
          ),
          _SettingItem(
            icon: Icons.security_rounded,
            title: 'Two-Factor Auth',
            value: '',
            color: AppThemeData.neonBlue,
            isToggle: true,
            toggleValue: controller.twoFactorAuth.value,
            onToggle: () => controller.toggleTwoFactorAuth(),
          ),
        ],
      ),

      // ── Data & Storage ─────────────────────────
      _CategoryData(
        title: 'DATA & STORAGE',
        icon: Icons.cloud_outlined,
        color: AppThemeData.neonBlue,
        items: [
          _SettingItem(
            icon: Icons.cloud_rounded,
            title: 'Cloud Backup',
            value: '',
            color: AppThemeData.neonBlue,
            isToggle: true,
            toggleValue: controller.cloudBackup.value,
            onToggle: () => controller.toggleCloudBackup(),
          ),
          _SettingItem(
            icon: Icons.wifi_off_rounded,
            title: 'Offline Mode',
            value: '',
            color: AppThemeData.neonPurple,
            isToggle: true,
            toggleValue: controller.offlineMode.value,
            onToggle: () => controller.toggleOfflineMode(),
          ),
          _SettingItem(
            icon: Icons.sync_rounded,
            title: 'Auto-Sync',
            value: '',
            color: AppThemeData.neonTeal,
            isToggle: true,
            toggleValue: controller.autoSync.value,
            onToggle: () => controller.toggleAutoSync(),
          ),
          _SettingItem(
            icon: Icons.storage_rounded,
            title: 'Storage Used',
            value: controller.storageUsed.value,
            color: AppThemeData.neonMint,
          ),
        ],
      ),

      // ── About ──────────────────────────────────
      _CategoryData(
        title: 'ABOUT',
        icon: Icons.info_outline_rounded,
        color: AppThemeData.neonLavender,
        items: [
          _SettingItem(
            icon: Icons.apps_rounded,
            title: 'App Version',
            value: 'v${controller.appVersion}',
            color: AppThemeData.neonLavender,
          ),
          _SettingItem(
            icon: Icons.build_rounded,
            title: 'Build Number',
            value: controller.buildNumber,
            color: AppThemeData.neonPurple,
          ),
          _SettingItem(
            icon: Icons.description_rounded,
            title: 'Terms of Service',
            value: 'View',
            color: AppThemeData.neonBlue,
            isAction: true,
          ),
          _SettingItem(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            value: 'View',
            color: AppThemeData.neonTeal,
            isAction: true,
          ),
        ],
      ),
    ];
  }

  // ── Category Section ────────────────────────────────────────────────
  Widget _buildCategorySection(
    _CategoryData category,
    bool isDark,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.surfaceDeep.withValues(alpha: 0.6)
            : AppThemeData.grey1.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.15)
              : AppThemeData.grey3.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category.icon,
                    size: 18,
                    color: category.color,
                  ),
                ),
                spaceW(width: 12),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Settings items
          ...category.items.map((item) => _buildSettingItem(item, isDark, context)),

          spaceH(height: 8),
        ],
      ),
    );
  }

  // ── Setting Item ────────────────────────────────────────────────────
  Widget _buildSettingItem(
    _SettingItem item,
    bool isDark,
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.isAction
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening ${item.title}...'),
                    backgroundColor: AppThemeData.primary50,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            : item.isToggle
                ? item.onToggle
                : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark
                ? AppThemeData.surfaceMid.withValues(alpha: 0.4)
                : AppThemeData.grey2.withValues(alpha: 0.5),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 18,
                  color: item.color,
                ),
              ),
              spaceW(width: 14),

              // Title
              Expanded(
                child: TextCustom(
                  title: item.title,
                  fontSize: 14,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey2 : AppThemeData.grey10,
                ),
              ),

              // Toggle or Value
              if (item.isToggle)
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: item.toggleValue,
                    onChanged: (_) => item.onToggle?.call(),
                    activeThumbColor: AppThemeData.primary50,
                    activeTrackColor: AppThemeData.primary50.withValues(alpha: 0.3),
                    inactiveThumbColor: isDark ? AppThemeData.grey6 : AppThemeData.grey4,
                    inactiveTrackColor: isDark
                        ? AppThemeData.grey8.withValues(alpha: 0.5)
                        : AppThemeData.grey3,
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextCustom(
                      title: item.value,
                      fontSize: 13,
                      fontFamily: FontFamily.medium,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                    if (item.isAction) ...[
                      spaceW(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data Models ──────────────────────────────────────────────────────────
class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });
}

class _CategoryData {
  final String title;
  final IconData icon;
  final Color color;
  final List<_SettingItem> items;

  const _CategoryData({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isToggle;
  final bool isAction;
  final bool toggleValue;
  final VoidCallback? onToggle;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.isToggle = false,
    this.isAction = false,
    this.toggleValue = false,
    this.onToggle,
  });
}
