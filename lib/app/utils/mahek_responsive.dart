// lib/app/utils/mahek_responsive.dart
import 'package:flutter/material.dart';

class MahekResponsive {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double laptopBreakpoint = 1200;
  static const double desktopBreakpoint = 1440;
  static const double largeDesktopBreakpoint = 1920;

  // Get screen width
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  // Get screen height
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  // Device type checks
  static bool isMobile(BuildContext context) => screenWidth(context) < mobileBreakpoint;
  static bool isTablet(BuildContext context) => screenWidth(context) >= mobileBreakpoint && screenWidth(context) < tabletBreakpoint;
  static bool isSmallLaptop(BuildContext context) => screenWidth(context) >= tabletBreakpoint && screenWidth(context) < laptopBreakpoint;
  static bool isLaptop(BuildContext context) => screenWidth(context) >= laptopBreakpoint && screenWidth(context) < desktopBreakpoint;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= desktopBreakpoint && screenWidth(context) < largeDesktopBreakpoint;
  static bool isLargeDesktop(BuildContext context) => screenWidth(context) >= largeDesktopBreakpoint;

  // Specific device checks
  static bool isMacBook13(BuildContext context) {
    final width = screenWidth(context);
    return width >= 1280 && width <= 1440;
  }

  static bool isMacBook16(BuildContext context) {
    final width = screenWidth(context);
    return width >= 1440 && width <= 1728;
  }

  static bool isMonitor27(BuildContext context) {
    final width = screenWidth(context);
    return width >= 1920 && width <= 2560;
  }

  static bool isMonitor32(BuildContext context) {
    final width = screenWidth(context);
    return width >= 2560;
  }

  // Responsive width calculations
  static double responsiveWidth(BuildContext context, {
    required double mobile,
    required double tablet,
    required double laptop,
    required double desktop,
    double? largeDesktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    if (isSmallLaptop(context) || isLaptop(context)) return laptop;
    if (isDesktop(context)) return desktop;
    return largeDesktop ?? desktop;
  }

  // Responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12);
    if (isTablet(context)) return const EdgeInsets.all(16);
    if (isSmallLaptop(context)) return const EdgeInsets.all(18);
    if (isLaptop(context)) return const EdgeInsets.all(20);
    return const EdgeInsets.all(24);
  }

  // Responsive font size
  static double responsiveFontSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double laptop,
    required double desktop,
  }) {
    return responsiveWidth(
      context,
      mobile: mobile,
      tablet: tablet,
      laptop: laptop,
      desktop: desktop,
    );
  }

  // Grid columns based on screen size
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    if (isSmallLaptop(context)) return 2;
    if (isLaptop(context)) return 3;
    return 3;
  }

  // Filter panel width
  static double filterPanelWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width < 1000) return 280;
    if (width < 1300) return 320;
    if (width < 1500) return 360;
    return 420;
  }

  // Card aspect ratio
  static double cardAspectRatio(BuildContext context) {
    if (isMobile(context)) return 0.75;
    if (isTablet(context)) return 0.8;
    if (isSmallLaptop(context)) return 0.85;
    return 0.9;
  }

  // Check if filter panel should be collapsible
  static bool shouldCollapseFilter(BuildContext context) {
    return screenWidth(context) < 1100;
  }

  // Get max cross axis extent for grid
  static double maxCrossAxisExtent(BuildContext context) {
    if (isMobile(context)) return 400;
    if (isTablet(context)) return 350;
    if (isSmallLaptop(context)) return 320;
    if (isLaptop(context)) return 350;
    return 350;
  }
}

// Extension for easy access
extension MahekResponsiveExtension on BuildContext {
  double get screenWidth => MahekResponsive.screenWidth(this);
  double get screenHeight => MahekResponsive.screenHeight(this);
  bool get isMobile => MahekResponsive.isMobile(this);
  bool get isTablet => MahekResponsive.isTablet(this);
  bool get isLaptop => MahekResponsive.isLaptop(this);
  bool get isDesktop => MahekResponsive.isDesktop(this);
  bool get isMacBook13 => MahekResponsive.isMacBook13(this);
  bool get isMonitor27 => MahekResponsive.isMonitor27(this);
  EdgeInsets get responsivePadding => MahekResponsive.responsivePadding(this);
  double get filterPanelWidth => MahekResponsive.filterPanelWidth(this);
}