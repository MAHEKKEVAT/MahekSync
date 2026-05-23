import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/responsive.dart';
import 'package:maheksync/app/utils/screen_size.dart';
import 'package:maheksync/app/widgets/app_logo_widget.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/components/logout_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';

import 'dashboard_nav_controller.dart';

class DashboardView extends GetView<DashboardNavController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final isDark = theme.isDarkTheme();
    final isMobile = ResponsiveWidget.isMobile(context);

    controller.syncIndexFromRoute();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceVoid : AppThemeData.grey1,
      body: isMobile
          ? _buildMobileLayout(context, theme, isDark)
          : _buildDesktopLayout(context, theme, isDark),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DarkThemeProvider theme, bool isDark) {
    final isDesktop = ResponsiveWidget.isDesktop(context);
    final isTablet = ResponsiveWidget.isTablet(context);

    return Row(
      children: [
        Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          width: controller.isNavExpanded.value
              ? (isDesktop ? (MediaQuery.of(context).size.width > 1600 ? 272 : 256) : (isTablet ? 240 : 72))
              : 72,
          child: _buildSideNavigation(context, theme, controller.isNavExpanded.value, isDark),
        )),
        Expanded(child: _buildMainContent(context, theme, isDark)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, DarkThemeProvider theme, bool isDark) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: isDark ? AppThemeData.surfaceVoid : AppThemeData.grey1,
      drawer: _buildMobileDrawer(context, theme, isDark),
      body: _buildMainContent(context, theme, isDark, scaffoldKey: scaffoldKey),
    );
  }

  Widget _buildMobileDrawer(BuildContext context, DarkThemeProvider theme, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? AppThemeData.surfaceDeep : AppThemeData.primaryWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      width: ScreenSize.width(78, context),
      child: _buildSideNavigation(context, theme, true, isDark),
    );
  }

  Widget _buildSideNavigation(BuildContext context, DarkThemeProvider theme, bool isExpanded, bool isDark) {
    final isMobile = ResponsiveWidget.isMobile(context);
    final sections = controller.navigationSections;
    final allItems = controller.allItems;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep.withOpacity(0.95) : AppThemeData.primaryWhite,
        border: Border(
          right: BorderSide(
            color: isDark ? AppThemeData.surfaceBorder.withOpacity(0.3) : AppThemeData.grey3.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 20, offset: const Offset(4, 0)),
        ],
      ),
      child: Column(
        children: [
          _buildSidebarHeader(isDark, isExpanded, isMobile),
          Expanded(
            child: ListView.builder(
              itemCount: sections.length,
              padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12 : 6, vertical: 8),
              itemBuilder: (context, sectionIndex) {
                final section = sections[sectionIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isExpanded) _buildSectionLabel(section.title, isDark),
                    if (!isExpanded && sectionIndex > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: AppThemeData.surfaceBorder.withOpacity(0.2), height: 1, indent: 12, endIndent: 12),
                      ),
                    ...section.items.map((item) {
                      final itemIndex = allItems.indexOf(item);
                      return _buildNavItem(context: context, item: item, itemIndex: itemIndex, isExpanded: isExpanded, isDark: isDark, isMobile: isMobile);
                    }),
                  ],
                );
              },
            ),
          ),
          _buildSidebarFooter(isDark, isExpanded, isMobile),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(bool isDark, bool isExpanded, bool isMobile) {
    return Container(
      height: isMobile ? 72 : 80,
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 8, vertical: 14),
      width: double.infinity,
      child: isExpanded
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppThemeData.appleIntelligenceGradientCool,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppThemeData.neonGlow(AppThemeData.neonPurple, blur: 12, opacity: 0.1),
                  ),
                  child: const Icon(SolarIconsBold.bolt, color: Colors.white, size: 22),
                ),
                spaceW(width: 12),
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (b) => AppThemeData.appleIntelligenceGradient.createShader(b),
                    child: TextCustom(
                      title: MahekConstant.appName.toString(),
                      fontSize: 18,
                      fontFamily: FontFamily.bold,
                      color: Colors.white,
                      maxLine: 1,
                    ),
                  ),
                ),
                if (!isMobile)
                  GestureDetector(
                    onTap: controller.toggleNavigation,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppThemeData.surfaceElevated.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.chevron_left_rounded, size: 16, color: AppThemeData.textNeonBlue.withOpacity(0.5)),
                    ),
                  ),
              ],
            )
          : Center(
              child: GestureDetector(
                onTap: isMobile ? null : controller.toggleNavigation,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: AppThemeData.appleIntelligenceGradientCool,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppThemeData.neonGlow(AppThemeData.neonPurple, blur: 12, opacity: 0.1),
                  ),
                  child: const Icon(SolarIconsBold.bolt, color: Colors.white, size: 20),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 16, bottom: 6),
      child: TextCustom(
        title: title,
        fontSize: 10,
        fontFamily: FontFamily.bold,
        color: AppThemeData.textNeonPurple.withOpacity(0.5),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required NavigationItem item,
    required int itemIndex,
    required bool isExpanded,
    required bool isDark,
    required bool isMobile,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == itemIndex;
      final isHovered = controller.navHoverIndex.value == itemIndex;

      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: MouseRegion(
          onEnter: (_) => controller.navHoverIndex.value = itemIndex,
          onExit: (_) => controller.navHoverIndex.value = -1,
          child: GestureDetector(
            onTap: () {
              if (isMobile) Navigator.pop(context);
              controller.changePage(itemIndex);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12 : 0, vertical: isMobile ? 11 : 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppThemeData.neonPurple.withOpacity(isDark ? 0.12 : 0.06)
                    : isHovered
                        ? AppThemeData.surfaceElevated.withOpacity(0.3)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppThemeData.neonPurple.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected ? AppThemeData.neonPurple : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      size: 18,
                    ),
                  ),
                  if (isExpanded) ...[
                    spaceW(width: 12),
                    Expanded(
                      child: TextCustom(
                        title: item.title,
                        fontSize: 13,
                        fontFamily: isSelected ? FontFamily.semiBold : FontFamily.medium,
                        color: isSelected ? AppThemeData.neonPurple : (isDark ? AppThemeData.grey3 : AppThemeData.grey8),
                        maxLine: 2,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppThemeData.appleIntelligenceGradientCool,
                          boxShadow: AppThemeData.neonGlow(AppThemeData.neonPurple, blur: 6, opacity: 0.3),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSidebarFooter(bool isDark, bool isExpanded, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12 : 6, vertical: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Get.dialog(LogoutDialog(
              onLogout: () async {
                await FirebaseAuth.instance.signOut();
                Get.offAllNamed(Routes.LOGIN_SCREEN);
                ShowToastDialog.showSuccess("Logged out successfully.".tr);
              },
            ));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12 : 0, vertical: isMobile ? 12 : 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: isExpanded
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppThemeData.danger300.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.logout_rounded, size: 16, color: AppThemeData.danger400),
                      ),
                      spaceW(width: 12),
                      Expanded(
                        child: TextCustom(title: 'Logout'.tr, fontSize: 13, fontFamily: FontFamily.medium, color: AppThemeData.danger400, maxLine: 1),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppThemeData.danger300.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.logout_rounded, size: 16, color: AppThemeData.danger400),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, DarkThemeProvider theme, bool isDark, {GlobalKey<ScaffoldState>? scaffoldKey}) {
    final isMobile = ResponsiveWidget.isMobile(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, isMobile ? 12 : 16, isMobile ? 16 : 24, 0),
            child: _buildHeader(context, theme, isDark, scaffoldKey: scaffoldKey),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: isMobile ? 12 : 24, right: isMobile ? 12 : 24, bottom: isMobile ? 12 : 24),
              child: _buildContentShell(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentShell(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceVoid : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.03), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: ValueKey(controller.selectedIndex.value),
            child: controller.getPageWidget(controller.selectedIndex.value),
          ),
        )),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DarkThemeProvider theme, bool isDark, {GlobalKey<ScaffoldState>? scaffoldKey}) {
    final isMobile = ResponsiveWidget.isMobile(context);
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Row(
      children: [
        if (!isDesktop) _buildMenuToggle(context, isDark, scaffoldKey),
        if (!isMobile)
          Obx(() => TextCustom(
            title: controller.currentPageTitle,
            fontSize: 20,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
          )),
        const Spacer(),
        if (!isMobile) _buildPremiumBadge(),
        const SizedBox(width: 12),
        _buildThemeToggle(theme, isDark),
        const SizedBox(width: 12),
        _buildProfileChip(isDark, isMobile),
      ],
    );
  }

  Widget _buildMenuToggle(BuildContext context, bool isDark, GlobalKey<ScaffoldState>? scaffoldKey) {
    final isMobile = ResponsiveWidget.isMobile(context);
    return GestureDetector(
      onTap: () {
        if (isMobile && scaffoldKey != null) {
          scaffoldKey.currentState?.openDrawer();
        } else {
          controller.toggleNavigation();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppThemeData.surfaceElevated.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppThemeData.surfaceBorder.withOpacity(0.3), width: 0.5),
        ),
        child: Icon(Icons.menu_rounded, color: AppThemeData.textNeonBlue.withOpacity(0.6), size: 20),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppThemeData.neonOrange.withOpacity(0.1),
          AppThemeData.neonYellow.withOpacity(0.05),
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeData.neonOrange.withOpacity(0.15), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_rounded, size: 12, color: AppThemeData.neonOrange.withOpacity(0.8)),
          const SizedBox(width: 6),
          TextCustom(title: 'PREMIUM', fontSize: 10, fontFamily: FontFamily.bold, color: AppThemeData.neonOrange),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(DarkThemeProvider theme, bool isDark) {
    return GestureDetector(
      onTap: () => theme.darkTheme = isDark ? 1 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppThemeData.surfaceElevated.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppThemeData.surfaceBorder.withOpacity(0.3), width: 0.5),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey<bool>(isDark),
            color: isDark ? AppThemeData.neonYellow : AppThemeData.neonBlue,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileChip(bool isDark, bool isMobile) {
    final employee = MahekConstant.ownerModel;
    return GestureDetector(
      onTap: () => controller.goToProfile(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppThemeData.surfaceElevated.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppThemeData.surfaceBorder.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 32,
              width: 32,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppThemeData.appleIntelligenceGradientCool,
              ),
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppThemeData.surfaceDeep),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: employee?.profilePic != null && employee!.profilePic!.isNotEmpty
                      ? NetworkImageWidget(imageUrl: employee.profilePic!, height: 32, width: 32, fit: BoxFit.cover)
                      : Icon(Icons.person_rounded, size: 16, color: AppThemeData.neonPurple),
                ),
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextCustom(title: employee?.fullName ?? 'Admin', fontSize: 12, fontFamily: FontFamily.semiBold, color: AppThemeData.primaryWhite, maxLine: 1),
                  TextCustom(title: 'Pro Account', fontSize: 9, fontFamily: FontFamily.regular, color: AppThemeData.textNeonBlue.withOpacity(0.4)),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 14, color: AppThemeData.textNeonBlue.withOpacity(0.3)),
            ],
          ],
        ),
      ),
    );
  }
}
