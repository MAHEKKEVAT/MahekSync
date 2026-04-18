import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/modules/admin_profile/views/admin_profile_view.dart';
import 'package:maheksync/app/modules/my_devices/controllers/my_devices_controller.dart';
import 'package:maheksync/app/modules/my_devices/views/my_devices_view.dart';
import 'package:maheksync/app/modules/policy_settings/views/policy_settings_view.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/modules/settings/views/settings_view.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/font_family.dart';
import '../../../widgets/text_widget.dart';
import '../views/dashboard_home_view.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  var isNavExpanded = true.obs;
  static const String profileRoute = '/admin-profile';

  RxBool isEmployeeLoading = true.obs;
  DateTime? currentBackPressTime;

  final List<NavigationSection> navigationSections = [
    // ── Overview ──
    NavigationSection(
      title: "OVERVIEW".tr,
      items: [
        NavigationItem(
          title: "Dashboard".tr,
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          route: Routes.DASHBOARD,
          svgIcon: 'assets/icons/ic_dashboard.svg',
        ),
      ],
    ),

    // ── Management ──
    NavigationSection(
      title: 'MANAGEMENT'.tr,
      items: [
        NavigationItem(
          title: 'My Devices'.tr,
          icon: Icons.devices_outlined,
          selectedIcon: Icons.devices,
          route: Routes.MY_DEVICES,
          svgIcon: 'assets/icons/ic_devices.svg',
        ),
      ],
    ),

    // ── Settings ──
    NavigationSection(
      title: 'SETTINGS'.tr,
      items: [
        NavigationItem(
          title: 'Settings'.tr,
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          route: Routes.SETTINGS,
          svgIcon: 'assets/icons/ic_settings.svg',
        ),
        NavigationItem(
          title: 'Policy Settings'.tr,
          icon: Icons.gavel_outlined,
          selectedIcon: Icons.gavel,
          route: Routes.POLICY_SETTINGS,
          svgIcon: 'assets/icons/ic_policy.svg',
        ),
      ],
    ),
  ];

  /// All items from navigation sections (for index mapping).
  List<NavigationItem> get allItems {
    List<NavigationItem> items = [];
    for (var section in navigationSections) {
      items.addAll(section.items);
    }
    return items;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    syncIndexFromRoute();

    // Listen to browser popstate events (back/forward buttons)
    html.window.onPopState.listen((event) {
      syncIndexFromRoute();
    });
  }

  Future<bool> onWillPop(BuildContext context, bool isDark) async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      bool? exitApp = await showDialog(
        context: context,
        barrierColor: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(.5),
        builder: (context) => AlertDialog(
          title: const TextCustom(
            title: 'Exit App',
            fontSize: 20,
            fontFamily: FontFamily.bold,
          ),
          content: TextCustom(
            title: 'Are you sure you want to exit?',
            fontSize: 16,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      return exitApp ?? false;
    }
    return true;
  }

  void goToProfile() {
    if (selectedIndex.value == -1) return;
    selectedIndex.value = -1;
    html.window.history.pushState(null, '', profileRoute);
  }

  void changePage(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
      final items = allItems;
      if (index >= 0 && index < items.length) {
        String route = items[index].route;
        // Ensure we push the full dashboard route
        html.window.history.pushState(null, '', route);
        print('Navigated to: $route');
      }
    }
  }

  void navigateToRoute(String route) {
    final items = allItems;
    for (int i = 0; i < items.length; i++) {
      if (items[i].route == route) {
        changePage(i);
        return;
      }
    }
    if (route == profileRoute) {
      goToProfile();
      return;
    }
    changePage(0);
  }

  /// Set selected index based on current browser URL
  void syncIndexFromRoute() {
    String currentPath = html.window.location.pathname ?? '';
    print('🔄 Syncing from path: $currentPath');

    // Check for profile route
    if (currentPath.contains(profileRoute) || currentPath.endsWith(profileRoute)) {
      if (selectedIndex.value != -1) {
        selectedIndex.value = -1;
        print('✅ Synced to profile');
      }
      return;
    }

    final items = allItems;
    for (int i = 0; i < items.length; i++) {
      String route = items[i].route;
      // Check multiple matching patterns
      if (currentPath.endsWith(route) ||
          currentPath.contains(route) ||
          currentPath == route) {
        if (selectedIndex.value != i) {
          selectedIndex.value = i;
          print('✅ Synced to index: $i, route: $route');
        }
        return;
      }
    }

    // If no match found, stay on current page or default to dashboard
    print('⚠️ No route match found for: $currentPath');
    // Don't force change to 0 - keep current selection
  }

  void toggleNavigation() {
    isNavExpanded.value = !isNavExpanded.value;
  }

  Widget getPageWidget(int index) {
    print('📄 getPageWidget called with index: $index');

    if (index == -1) {
      return const AdminProfileView();
    }

    final items = allItems;
    if (index < 0 || index >= items.length) {
      return const DashboardHomeView();
    }

    String route = items[index].route;
    print('📄 Loading page for route: $route');

    switch (route) {
      case Routes.DASHBOARD:
        return const DashboardHomeView();
      case Routes.MY_DEVICES:
      // Ensure controller is registered before returning the view
        if (!Get.isRegistered<MyDevicesController>()) {
          Get.put(MyDevicesController());
        }
        return const MyDevicesView();
      case Routes.SETTINGS:
        return const SettingsView();
      case Routes.POLICY_SETTINGS:
        return const PolicySettingsView();
      default:
        return const DashboardHomeView();
    }
  }
}

class NavigationSection {
  final String title;
  final List<NavigationItem> items;

  NavigationSection({required this.title, required this.items});
}

class NavigationItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final String? svgIcon;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.route,
    this.svgIcon,
  });
}