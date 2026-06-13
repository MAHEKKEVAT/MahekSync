// lib/app/modules/dashboard/views/dashboard_home_view.dart
// ──────────────────────────────────────────────────────────────
//  MaheKSync Digital Life OS Dashboard – v4 Redesign
//  Apple Intelligence / Arc / Linear / Raycast / Notion AI style
//  Preserves ALL DashboardHomeController data & Firestore streams.
//  Only UI/UX rebuilt; no business logic altered.
// ──────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/dashboard_top_bar.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';

// ─── Section Widgets ─────────────────────────────────────
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/dashboard_hero_section.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/analytics_overview_section.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/financial_chart_card.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/category_showcase_row.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/dashboard_graphs_section.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/upcoming_timeline_section.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/activity_feed_section.dart';
import 'package:maheksync/app/modules/dashboard/dashboard/widgets/profile_sidebar_section.dart';

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  static const _spacing = 24.0;

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
        child: Column(
          children: [
            // ════════════════════════════════════════════
            //  TOP BAR
            // ════════════════════════════════════════════
            DashboardTopBar(
              onMenuTap: () {
                try {
                  final dc = Get.find<DashboardController>();
                  dc.toggleNavigation();
                } catch (_) {}
              },
            ),

            // ════════════════════════════════════════════
            //  MAIN CONTENT AREA
            // ════════════════════════════════════════════
            Expanded(
              child: isDesktop
                  ? _buildDesktopLayout(c, isDark)
                  : _buildMobileLayout(c, isDark, isTablet),
            ),
          ],
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════
  //  DESKTOP LAYOUT: Main Content + Right Sidebar
  // ════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(DashboardHomeController c, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main Content (scrollable) ────────────────
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(_spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: Hero (Good Morning + Name + Chips)
                DashboardHeroSection(controller: c, isDark: isDark),
                spaceH(height: _spacing),

                // SECTION 2: Category Showcase Row (Devices, Purchases, Subs, Dues)
                CategoryShowcaseRow(
                  controller: c,
                  isDark: isDark,
                  onViewDevices: () => _navigateTo(Routes.MY_DEVICES),
                  onViewPurchases: () => _navigateTo(Routes.MY_PURCHASES),
                  onViewSubscriptions: () => _navigateTo(Routes.SUBSCRIPTION),
                  onViewDues: () => _navigateTo(Routes.DUES_TRACKER),
                ),
                spaceH(height: _spacing),

                // SECTION 3: Analytics Overview (4 cards)
                _sectionHeader('Insights', Icons.insights_rounded,
                    AppThemeData.neonPurple, isDark),
                const SizedBox(height: 14),
                AnalyticsOverviewSection(controller: c, isDark: isDark),
                spaceH(height: _spacing),

                // SECTION 4: Financial Chart
                FinancialChartCard(controller: c, isDark: isDark),
                spaceH(height: _spacing),

                // SECTION 5: Analytics Graphs (8 graphs)
                DashboardGraphsSection(controller: c, isDark: isDark),
                spaceH(height: _spacing),

                // SECTION 6 + 7: Timeline + Activity (side by side)
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
                          controller: c, isDark: isDark),
                    ),
                  ],
                ),
                spaceH(height: _spacing),

                // Quick Actions Bar
                _buildQuickActions(c, isDark),
              ],
            ),
          ),
        ),

        // ── Right Sidebar (sticky) ───────────────────
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

  // ════════════════════════════════════════════════════════════
  //  MOBILE / TABLET LAYOUT (single column, no sidebar)
  // ════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(
      DashboardHomeController c, bool isDark, bool isTablet) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(isTablet ? _spacing : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero
          DashboardHeroSection(controller: c, isDark: isDark),
          spaceH(height: _spacing),

          // Profile Sidebar (shown inline on mobile)
          ProfileSidebarSection(controller: c, isDark: isDark),
          spaceH(height: _spacing),

          // Category Showcase
          CategoryShowcaseRow(
            controller: c,
            isDark: isDark,
            onViewDevices: () => _navigateTo(Routes.MY_DEVICES),
            onViewPurchases: () => _navigateTo(Routes.MY_PURCHASES),
            onViewSubscriptions: () => _navigateTo(Routes.SUBSCRIPTION),
            onViewDues: () => _navigateTo(Routes.DUES_TRACKER),
          ),
          spaceH(height: _spacing),

          // Analytics
          _sectionHeader('Insights', Icons.insights_rounded,
              AppThemeData.neonPurple, isDark),
          const SizedBox(height: 14),
          AnalyticsOverviewSection(controller: c, isDark: isDark),
          spaceH(height: _spacing),

          // Financial
          FinancialChartCard(controller: c, isDark: isDark),
          spaceH(height: _spacing),

          // Graphs
          DashboardGraphsSection(controller: c, isDark: isDark),
          spaceH(height: _spacing),

          // Timeline
          UpcomingTimelineSection(
            controller: c,
            isDark: isDark,
            onViewAll: () => _navigateTo(Routes.REMINDER),
          ),
          spaceH(height: _spacing),

          // Activity
          ActivityFeedSection(controller: c, isDark: isDark),
          spaceH(height: _spacing),

          // Quick Actions
          _buildQuickActions(c, isDark),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  QUICK ACTIONS (Scan Doc REMOVED)
  // ════════════════════════════════════════════════════════════
  Widget _buildQuickActions(DashboardHomeController c, bool isDark) {
    final actions = [
      _QuickActionData(Icons.add_task_rounded, 'Add Task',
          AppThemeData.neonPurple, () => _navigateTo(Routes.PERSONAL_TASKS)),
      _QuickActionData(Icons.alarm_add_rounded, 'Reminder',
          AppThemeData.neonOrange, () => _navigateTo(Routes.REMINDER)),
      _QuickActionData(Icons.add_circle_rounded, 'Add Device',
          AppThemeData.neonTeal, () => _navigateTo(Routes.MY_DEVICES)),
      _QuickActionData(Icons.add_shopping_cart_rounded, 'Add Purchase',
          AppThemeData.neonMint, () => _navigateTo(Routes.MY_PURCHASES)),
      _QuickActionData(Icons.note_add_rounded, 'Create Note',
          AppThemeData.neonLavender, () => _navigateTo(Routes.VAULT)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Quick Actions', Icons.bolt_rounded,
            AppThemeData.neonBlue, isDark),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: actions
              .map((a) => _QuickActionButton(action: a, isDark: isDark))
              .toList(),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  //  SECTION HEADER
  // ════════════════════════════════════════════════════════════
  Widget _sectionHeader(
      String label, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppThemeData.neonPurpleBlueGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(width: 8),
        TextCustom(
          title: label,
          fontSize: 15,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
      ],
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

// ══════════════════════════════════════════════════════════════
//  QUICK ACTION DATA + BUTTON (improved UI)
// ══════════════════════════════════════════════════════════════
class _QuickActionData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionData(this.icon, this.label, this.color, this.onTap);
}

class _QuickActionButton extends StatefulWidget {
  final _QuickActionData action;
  final bool isDark;
  const _QuickActionButton(
      {required this.action, required this.isDark});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.action.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            gradient: _hovered
                ? LinearGradient(
                    colors: [
                      widget.action.color.withOpacity(0.2),
                      widget.action.color.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: _hovered
                ? null
                : (widget.isDark
                    ? AppThemeData.surfaceElevated
                    : AppThemeData.grey2),
            borderRadius: BorderRadius.circular(14),
            border: _hovered
                ? Border.all(
                    color: widget.action.color.withOpacity(0.35))
                : Border.all(
                    color: widget.isDark
                        ? AppThemeData.surfaceBorder.withOpacity(0.3)
                        : AppThemeData.grey4.withOpacity(0.3),
                  ),
            boxShadow: _hovered
                ? AppThemeData.neonGlow(widget.action.color,
                    blur: 14, opacity: 0.12)
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.action.icon,
                size: 16,
                color: _hovered
                    ? Colors.white
                    : widget.action.color,
              ),
              const SizedBox(width: 7),
              Text(
                widget.action.label,
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 12,
                  color: _hovered
                      ? widget.action.color
                      : (widget.isDark
                          ? AppThemeData.grey3
                          : AppThemeData.grey8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
