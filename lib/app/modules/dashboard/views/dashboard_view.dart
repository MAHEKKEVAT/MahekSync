import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:ui';
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

    return _DashboardViewBody(
      isDark: isDark,
      isMobile: isMobile,
      isTablet: isTablet,
      isDesktop: isDesktop,
      controller: controller,
      theme: theme,
    );
  }
}

class _DashboardViewBody extends StatefulWidget {
  final bool isDark;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final DashboardController controller;
  final DarkThemeProvider theme;

  const _DashboardViewBody({
    required this.isDark,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.controller,
    required this.theme,
  });

  @override
  State<_DashboardViewBody> createState() => _DashboardViewBodyState();
}

class _DashboardViewBodyState extends State<_DashboardViewBody>
    with TickerProviderStateMixin {
  late Timer _timer;
  DateTime _now = DateTime.now();
  late AnimationController _starAnim;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    _starAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer.cancel();
    _starAnim.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = _now.hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    if (h < 20) return 'Evening';
    return 'Night';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? AppThemeData.primaryBlack : AppThemeData.grey1,
      body: widget.isMobile
          ? _buildMobileLayout(context, widget.theme, widget.isDark)
          : _buildDesktopLayout(context, widget.theme, widget.isDesktop, widget.isTablet, widget.isDark),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DarkThemeProvider theme,
      bool isDesktop, bool isTablet, bool isDark) {
    return WillPopScope(
      onWillPop: () => widget.controller.onWillPop(context, isDark),
      child: Row(
        children: [
          Obx(
                () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              width: widget.controller.isNavExpanded.value
                  ? (isDesktop
                  ? (MediaQuery.of(context).size.width > 1600 ? 280 : 260)
                  : (isTablet ? 240 : 72))
                  : 72,
              color: Colors.transparent,
              child: _GlassmorphicNavShell(
                isDark: isDark,
                child: _buildSideNavigation(
                    context, theme, widget.controller.isNavExpanded.value),
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
      onWillPop: () => widget.controller.onWillPop(context, isDark),
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
    final sections = widget.controller.navigationSections;
    final allItems = widget.controller.allItems;

    return Column(
      children: [
        Container(
          height: isMobile ? 72 : 124,
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
                padding: const EdgeInsets.all(2),
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
                child: Image.asset(
                  'assets/images/maheksync.png',
                  height: isDesktop ? 115 : 32,
                  fit: BoxFit.contain,
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
                          widget.controller.selectedIndex.value == itemIndex;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (isMobile) Navigator.pop(context);
                              widget.controller.changePage(itemIndex);
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
            child: _buildHeader(context, theme, scaffoldKey: scaffoldKey),
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
                      key: ValueKey(widget.controller.selectedIndex.value),
                      child: widget.controller.getPageWidget(widget.controller.selectedIndex.value),
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

    final hour = _now.hour;
    final isNight = hour >= 20 || hour < 6;
    final isEvening = hour >= 17 && hour < 20;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AnimatedBuilder(
        animation: _starAnim,
        builder: (_, _) => Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isNight
                  ? const [Color(0xFF0A0A1A), Color(0xFF1E1B4B), Color(0xFF312E81)]
                  : isEvening
                      ? const [Color(0xFF1A0533), Color(0xFF4C1D95), Color(0xFFDB2777)]
                      : const [Color(0xFF2D1B69), Color(0xFF5B21B6), Color(0xFFD97706)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Stars
              ...List.generate(18, (i) {
                final rng = math.Random(i);
                final twinkle = (math.sin(_starAnim.value * math.pi * 2 + i * 0.7) + 1) / 2;
                return Positioned(
                  left: rng.nextDouble() * 800 + 10,
                  top: rng.nextDouble() * 36 + 6,
                  child: Container(
                    width: rng.nextDouble() * 1.5 + 0.4,
                    height: rng.nextDouble() * 1.5 + 0.4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: twinkle * 0.45 + 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (!isDesktop)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (isMobile && scaffoldKey != null) {
                              scaffoldKey.currentState?.openDrawer();
                            } else {
                              widget.controller.toggleNavigation();
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Icon(
                              Icons.menu_rounded,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    if (isDesktop)
                      _ModernDesktopClock(
                        now: _now,
                        greeting: _greeting,
                        starAnim: _starAnim,
                      ),
                    if (!isDesktop) _PremiumHeaderBadge(isDark: true, now: _now),
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
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => widget.controller.goToProfile(),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: employee?.profilePic != null &&
                                  employee!.profilePic!.isNotEmpty
                                  ? NetworkImageWidget(
                                      imageUrl: employee.profilePic!,
                                      height: 36,
                                      width: 36,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 20,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                            ),
                          ),
                          if (!isMobile) ...[
                            spaceW(width: 10),
                            Text(
                              employee?.fullName ?? 'Admin',
                              style: TextStyle(
                                fontFamily: FontFamily.bold,
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
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
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: widget.isDark
                    ? const Color(0xFF0D0F14).withValues(alpha: 0.82)
                    : Colors.white.withValues(alpha: 0.80),
              ),
            ),
          ),
          // Content
          Container(
            decoration: BoxDecoration(
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
        ],
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

// ─── Modern Desktop Clock ──────────────────────────────────
class _ModernDesktopClock extends StatelessWidget {
  final DateTime now;
  final String greeting;
  final Animation<double> starAnim;

  const _ModernDesktopClock({
    required this.now,
    required this.greeting,
    required this.starAnim,
  });

  @override
  Widget build(BuildContext context) {
    final h = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final hh = h.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];

    final hourGlow = now.hour >= 20 || now.hour < 6 ? 0.3 : 0.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppThemeData.neonMint,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppThemeData.neonMint.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          spaceW(width: 10),
          // Greeting
          Text(
            'Good $greeting',
            style: TextStyle(
              fontFamily: FontFamily.medium,
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          spaceW(width: 12),
          // Time with hour glow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: hourGlow * 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  hh,
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 18,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                // Animated colon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 0.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (_, v, _) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: 18,
                        height: 1,
                        color: Colors.white.withValues(alpha: v * 0.6 + 0.2),
                      ),
                    ),
                  ),
                ),
                Text(
                  mm,
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 18,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                spaceW(width: 2),
                Text(
                  ss,
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 10,
                    color: AppThemeData.neonMint.withValues(alpha: 0.8),
                  ),
                ),
                spaceW(width: 3),
                Text(
                  period,
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 9,
                    color: AppThemeData.neonMint,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          spaceW(width: 10),
          // Vertical divider
          Container(
            width: 1,
            height: 18,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          spaceW(width: 10),
          // Date
          Icon(
            Icons.calendar_today_rounded,
            size: 12,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          spaceW(width: 5),
          Text(
            '$dayName ${now.day} $monthName',
            style: TextStyle(
              fontFamily: FontFamily.medium,
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Premium Header Badge (Mobile, Subscription Grade) ─────
class _PremiumHeaderBadge extends StatelessWidget {
  final bool isDark;
  final DateTime now;

  const _PremiumHeaderBadge({required this.isDark, required this.now});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4A843).withValues(alpha: 0.18),
            const Color(0xFFE8C564).withValues(alpha: 0.10),
            const Color(0xFFF5D76E).withValues(alpha: 0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD4A843).withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A843).withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown icon
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFD4A843), Color(0xFFF5D76E), Color(0xFFD4A843)],
            ).createShader(bounds),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 15,
              color: Colors.white,
            ),
          ),
          spaceW(width: 5),
          // PREMIUM text with gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFD4A843), Color(0xFFF5D76E), Color(0xFFD4A843)],
            ).createShader(bounds),
            child: const Text(
              'PREMIUM',
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 9,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
