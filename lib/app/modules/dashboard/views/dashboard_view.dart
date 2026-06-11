import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import '../../../utils/screen_size.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/font_family.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/responsive.dart';

import '../../../widgets/app_logo_widget.dart';
import '../../../widgets/global_widgets.dart';
import '../../../components/logout_dialog.dart';
import '../../../widgets/text_widget.dart';
import '../controllers/dashboard_controller.dart';
import 'package:lottie/lottie.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final isDark = theme.isDarkTheme();
    final isMobile = ResponsiveWidget.isMobile(context);
    final isTablet = ResponsiveWidget.isTablet(context);
    final isDesktop = ResponsiveWidget.isDesktop(context);

    controller.syncIndexFromRoute();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.primaryBlack : AppThemeData.grey1,
      body: isMobile
          ? _buildMobileLayout(context, theme, isDark)
          : _buildDesktopLayout(context, theme, isDesktop, isTablet, isDark),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DarkThemeProvider theme,
      bool isDesktop, bool isTablet, bool isDark) {
    return WillPopScope(
      onWillPop: () => controller.onWillPop(context, isDark),
      child: Row(
        children: [
          Obx(
                () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              width: controller.isNavExpanded.value
                  ? (isDesktop
                  ? (MediaQuery.of(context).size.width > 1600 ? 280 : 260)
                  : (isTablet ? 240 : 72))
                  : 72,
              color: Colors.transparent,
              child: _GlassmorphicNavShell(
                isDark: isDark,
                child: _buildSideNavigation(
                    context, theme, controller.isNavExpanded.value),
              ),
            ),
          ),
          Container(
            width: 1,
            height: double.infinity,
            color: isDark
                ? AppThemeData.grey8.withValues(alpha: 0.25)
                : AppThemeData.grey3.withValues(alpha: 0.4),
          ),
          Expanded(child: _buildMainContent(context, theme)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, DarkThemeProvider theme, bool isDark) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: () => controller.onWillPop(context, isDark),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: isDark ? AppThemeData.primaryBlack : AppThemeData.grey1,
        drawer: Drawer(
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24)),
          ),
          width: ScreenSize.width(78, context),
          child: _GlassmorphicNavShell(
            isDark: isDark,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24)),
            child: _buildSideNavigation(context, theme, true),
          ),
        ),
        body: _buildMainContent(context, theme, scaffoldKey: scaffoldKey),
      ),
    );
  }

  Widget _buildSideNavigation(
      BuildContext context, DarkThemeProvider theme, bool isExpanded) {
    final isDark = theme.isDarkTheme();
    final isMobile = ResponsiveWidget.isMobile(context);
    final isDesktop = ResponsiveWidget.isDesktop(context);
    final sections = controller.navigationSections;
    final allItems = controller.allItems;

    return Column(
      children: [
        Container(
          height: isMobile ? 72 : 84,
          padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 18 : 8, vertical: 14),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? AppThemeData.grey8.withValues(alpha: 0.15)
                    : AppThemeData.grey3.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: isExpanded
              ? Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                    AppThemeData.primary50.withValues(alpha: 0.25),
                  ),
                ),
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Lottie.asset(
                    'assets/animation/diamond.json',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),
              spaceW(width: 14),
              Expanded(
                child: TextCustom(
                  title: MahekConstant.appName.toString(),
                  fontSize: isDesktop ? 22 : 20,
                  fontFamily: FontFamily.bold,
                  color: isDark
                      ? AppThemeData.textNeonPurple
                      : AppThemeData.primary50,
                  maxLine: 1,
                ),
              ),
            ],
          )
              : Center(
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                  AppThemeData.primary50.withValues(alpha: 0.25),
                ),
              ),
              child: const AppLogoWidget(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sections.length,
            padding:
            EdgeInsets.symmetric(horizontal: isExpanded ? 14 : 6, vertical: 12),
            itemBuilder: (context, sectionIndex) {
              final section = sections[sectionIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isExpanded)
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 14, top: 8, bottom: 8),
                      child: TextCustom(
                        title: section.title.toUpperCase(),
                        fontSize: 10,
                        fontFamily: FontFamily.bold,
                        color: isDark
                            ? AppThemeData.grey5.withValues(alpha: 0.7)
                            : AppThemeData.grey6.withValues(alpha: 0.8),
                      ),
                    ),
                  ...section.items.map((item) {
                    final itemIndex = allItems.indexOf(item);
                    return Obx(() {
                      final isSelected =
                          controller.selectedIndex.value == itemIndex;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (isMobile) Navigator.pop(context);
                              controller.changePage(itemIndex);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              padding: EdgeInsets.symmetric(
                                horizontal: isExpanded ? 14 : 10,
                                vertical: isMobile ? 12 : 11,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                    ? AppThemeData.primary50.withValues(alpha: 0.22)
                                    : AppThemeData.primary50.withValues(alpha: 0.14))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                  color: AppThemeData.primary50.withValues(alpha: 0.3),
                                  width: 1,
                                )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    alignment: Alignment.center,
                                    child: item.svgIcon != null
                                        ? SvgPicture.asset(
                                      item.svgIcon!,
                                      width: 22,
                                      height: 22,
                                      colorFilter: ColorFilter.mode(
                                        isSelected
                                            ? (isDark
                                            ? AppThemeData.textNeonPurple
                                            : AppThemeData.primary50)
                                            : (isDark
                                            ? AppThemeData.grey4
                                            : AppThemeData.grey7),
                                        BlendMode.srcIn,
                                      ),
                                    )
                                        : Icon(
                                      isSelected
                                          ? item.selectedIcon
                                          : item.icon,
                                      color: isSelected
                                          ? (isDark
                                          ? AppThemeData.textNeonPurple
                                          : AppThemeData.primary50)
                                          : (isDark
                                          ? AppThemeData.grey4
                                          : AppThemeData.grey7),
                                      size: 22,
                                    ),
                                  ),
                                  if (isExpanded) ...[
                                    spaceW(width: 14),
                                    Expanded(
                                      child: TextCustom(
                                        title: item.title,
                                        fontSize: 14,
                                        fontFamily: isSelected
                                            ? FontFamily.bold
                                            : FontFamily.medium,
                                        color: isSelected
                                            ? (isDark
                                            ? AppThemeData.textNeonPurple
                                            : AppThemeData.primary50)
                                            : (isDark
                                            ? AppThemeData.grey2
                                            : AppThemeData.grey9),
                                        maxLine: 2,
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
                  }),
                  if (sectionIndex < sections.length - 1 && isExpanded)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Divider(
                        color: isDark
                            ? AppThemeData.grey8.withValues(alpha: 0.12)
                            : AppThemeData.grey3.withValues(alpha: 0.2),
                        height: 1,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding:
          EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 8, vertical: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Get.dialog(
                  LogoutDialog(
                    onLogout: () async {
                      await FirebaseAuth.instance.signOut();
                      Get.offAllNamed(Routes.LOGIN_SCREEN);
                      html.window.history.pushState(
                          null, '', Routes.LOGIN_SCREEN);
                      ShowToastDialog.showSuccess(
                          "Logged out successfully.".tr);
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isExpanded ? 16 : 0,
                  vertical: isMobile ? 14 : 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.danger600.withValues(alpha: 0.2)
                      : AppThemeData.danger50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppThemeData.danger300.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: isExpanded
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ic_logout.svg',
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                          AppThemeData.danger400, BlendMode.srcIn),
                    ),
                    spaceW(width: 14),
                    Flexible(
                      child: TextCustom(
                        title: 'Logout'.tr,
                        fontSize: 15,
                        fontFamily: FontFamily.semiBold,
                        color: AppThemeData.danger400,
                        maxLine: 1,
                      ),
                    ),
                  ],
                )
                    : Center(
                  child: SvgPicture.asset(
                    'assets/icons/ic_logout.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                        AppThemeData.danger400, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),
        ),
        spaceH(height: 8),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, DarkThemeProvider theme,
      {GlobalKey<ScaffoldState>? scaffoldKey}) {
    final isMobile = ResponsiveWidget.isMobile(context);
    final isDark = theme.isDarkTheme();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 20, isMobile ? 14 : 18, isMobile ? 16 : 20, 0),
            child: _GlassmorphicHeaderShell(
              isDark: isDark,
              child: _buildHeader(context, theme, scaffoldKey: scaffoldKey),
            ),
          ),
          spaceH(height: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: isMobile ? 14 : 20,
                right: isMobile ? 14 : 20,
                bottom: isMobile ? 14 : 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color:
                        Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return ClipRect(child: FadeTransition(opacity: animation, child: child));
                    },
                    child: Obx(() => KeyedSubtree(
                      key: ValueKey(controller.selectedIndex.value),
                      child: controller.getPageWidget(controller.selectedIndex.value),
                    )),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DarkThemeProvider theme,
      {GlobalKey<ScaffoldState>? scaffoldKey}) {
    final isDark = theme.isDarkTheme();
    final isMobile = ResponsiveWidget.isMobile(context);
    final isDesktop = ResponsiveWidget.isDesktop(context);
    final employee = MahekConstant.ownerModel;

    return Row(
      children: [
        if (!isDesktop)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isMobile && scaffoldKey != null) {
                  scaffoldKey.currentState?.openDrawer();
                } else {
                  controller.toggleNavigation();
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.surfaceElevated.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
                  size: 24,
                ),
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: Row(
            children: [
              if (!isMobile) ...[
                spaceW(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextCustom(
                      title: 'PREMIUM',
                      fontSize: 23,
                      fontFamily: FontFamily.bold,
                      color: const Color(0xFFFFD700),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => theme.darkTheme = isDark ? 1 : 0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeData.surfaceElevated.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? AppThemeData.pending300 : AppThemeData.primary50,
                size: 22,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () => controller.goToProfile(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppThemeData.surfaceElevated.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppThemeData.primary50.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: employee?.profilePic != null &&
                        employee!.profilePic!.isNotEmpty
                        ? NetworkImageWidget(
                      imageUrl: employee.profilePic!,
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: isDark
                          ? AppThemeData.grey8
                          : AppThemeData.grey2,
                      child: Icon(
                        Icons.person_rounded,
                        size: 22,
                        color: AppThemeData.primary50,
                      ),
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  spaceW(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextCustom(
                        title: employee?.fullName ?? 'Admin',
                        fontSize: 14,
                        fontFamily: FontFamily.bold,
                        color: isDark
                            ? AppThemeData.primaryWhite
                            : AppThemeData.primaryBlack,
                        maxLine: 1,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassmorphicNavShell extends StatefulWidget {
  final Widget child;
  final bool isDark;
  final BorderRadius? borderRadius;

  const _GlassmorphicNavShell({
    required this.child,
    required this.isDark,
    this.borderRadius,
  });

  @override
  State<_GlassmorphicNavShell> createState() => _GlassmorphicNavShellState();
}

class _GlassmorphicNavShellState extends State<_GlassmorphicNavShell> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppThemeData.surfaceDeep.withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.85),
          borderRadius: widget.borderRadius,
          border: widget.borderRadius != null
              ? Border.all(
            color: widget.isDark
                ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.5),
            width: 1,
          )
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}

class _GlassmorphicHeaderShell extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const _GlassmorphicHeaderShell({
    required this.child,
    required this.isDark,
  });

  @override
  State<_GlassmorphicHeaderShell> createState() => _GlassmorphicHeaderShellState();
}

class _GlassmorphicHeaderShellState extends State<_GlassmorphicHeaderShell> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: widget.isDark ? AppThemeData.surfaceDeep.withValues(alpha: 0.88) : Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark
                ? AppThemeData.surfaceBorder.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
