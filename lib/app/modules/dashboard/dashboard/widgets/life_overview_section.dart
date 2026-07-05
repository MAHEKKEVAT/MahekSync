import 'package:flutter/material.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:solar_icons/solar_icons.dart';

class LifeOverviewSection extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final VoidCallback? onDevicesTap;
  final VoidCallback? onSubscriptionsTap;
  final VoidCallback? onVaultTap;
  final VoidCallback? onContactsTap;
  final VoidCallback? onViewAll;

  const LifeOverviewSection({
    super.key,
    required this.controller,
    this.isDark = true,
    this.onDevicesTap,
    this.onSubscriptionsTap,
    this.onVaultTap,
    this.onContactsTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemeData.neonPurple, AppThemeData.neonBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.grid_view_rounded,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  TextCustom(
                    title: 'Life Overview',
                    fontSize: 17,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ],
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppThemeData.surfaceElevated.withValues(alpha: 0.5)
                          : AppThemeData.grey2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AppThemeData.surfaceBorder.withValues(alpha: 0.2)
                            : AppThemeData.grey3.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 11,
                        color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // 2x2 Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _MetricTile(
                title: 'Devices',
                value: '${controller.deviceCount.value}',
                icon: SolarIconsBold.lockKeyhole,
                accentColor: AppThemeData.neonBlue,
                isDark: isDark,
                onTap: onDevicesTap,
              ),
              _MetricTile(
                title: 'Subscriptions',
                value: '${controller.subscriptionCount.value}',
                icon: SolarIconsBold.bookmark,
                accentColor: AppThemeData.pending400,
                isDark: isDark,
                onTap: onSubscriptionsTap,
              ),
              _MetricTile(
                title: 'Vault Items',
                value: '${controller.vaultCount.value}',
                icon: SolarIconsBold.lock,
                accentColor: AppThemeData.neonPurple,
                isDark: isDark,
                onTap: onVaultTap,
              ),
              _MetricTile(
                title: 'Contacts',
                value: '${controller.contactCount.value}',
                icon: SolarIconsBold.usersGroupRounded,
                accentColor: AppThemeData.neonMint,
                isDark: isDark,
                onTap: onContactsTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final VoidCallback? onTap;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_MetricTile> createState() => _MetricTileState();
}

class _MetricTileState extends State<_MetricTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered
                ? (widget.isDark
                    ? AppThemeData.surfaceElevated
                    : AppThemeData.grey2)
                : (widget.isDark
                    ? AppThemeData.surfaceMid.withValues(alpha: 0.35)
                    : AppThemeData.grey2.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor.withValues(alpha: 0.2)
                  : widget.isDark
                      ? AppThemeData.surfaceBorder.withValues(alpha: 0.10)
                      : AppThemeData.grey3.withValues(alpha: 0.3),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.accentColor.withValues(alpha: 0.2),
                      widget.accentColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 16, color: widget.accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: 18,
                        color: widget.isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 10,
                        color: widget.isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
