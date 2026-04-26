import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/modules/admin_profile/views/admin_profile_view.dart';
import 'package:maheksync/app/modules/categories/controllers/categories_controller.dart';
import 'package:maheksync/app/modules/categories/views/categories_view.dart';
import 'package:maheksync/app/modules/my_devices/controllers/my_devices_controller.dart';
import 'package:maheksync/app/modules/my_devices/views/my_devices_view.dart';
import 'package:maheksync/app/modules/my_purchases/controllers/my_purchases_controller.dart';
import 'package:maheksync/app/modules/my_purchases/views/my_purchases_view.dart';
import 'package:maheksync/app/modules/payement_method/views/payement_method_view.dart' show PaymentMethodsView;
import 'package:maheksync/app/modules/policy_settings/views/policy_settings_view.dart';
import 'package:maheksync/app/modules/reminder/controllers/reminder_controller.dart';
import 'package:maheksync/app/modules/reminder/views/reminder_view.dart';
import 'package:maheksync/app/modules/subscription/controllers/subscription_controller.dart';
import 'package:maheksync/app/modules/subscription/views/subscription_view.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/modules/settings/views/settings_view.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/font_family.dart';
import '../../../widgets/text_widget.dart';
import '../../payement_method/controllers/payement_method_controller.dart';
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
          selectedIcon: Icons.devices_rounded,
          route: Routes.MY_DEVICES,
          svgIcon: 'assets/icons/ic_devices.svg',
        ),
        NavigationItem(
          title: 'Payment Methods'.tr,
          icon: Icons.payment_outlined,
          selectedIcon: Icons.payment_rounded,
          route: Routes.PAYEMENT_METHOD,
          svgIcon: 'assets/icons/ic_payment.svg',
        ),
        NavigationItem(
          title: 'Categories'.tr,
          icon: Icons.category_outlined,
          selectedIcon: Icons.category_rounded,
          route: Routes.CATEGORIES,
            svgIcon: 'assets/icons/ic_categories.svg',
        ),
        NavigationItem(
          title: 'My Purchases'.tr,
          icon: Icons.shopping_bag_outlined,
          selectedIcon: Icons.shopping_bag_rounded,
          route: Routes.MY_PURCHASES,
          svgIcon: 'assets/icons/ic_purchases.svg',
        ),
        NavigationItem(
          title: 'Subscriptions'.tr,
          icon: Icons.subscriptions_outlined,
          selectedIcon: Icons.subscriptions_rounded,
          route: Routes.SUBSCRIPTION,
          svgIcon: 'assets/icons/ic_subscriptions.svg',
        ),
        NavigationItem(
          title: 'Reminders'.tr,
          icon: Icons.alarm_outlined,
          selectedIcon: Icons.alarm_rounded,
          route: Routes.REMINDER,
          svgIcon: 'assets/icons/ic_reminder.svg',
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

    print('📋 Available routes in navigation:');
    for (int i = 0; i < allItems.length; i++) {
      print('   [$i] ${allItems[i].route} - ${allItems[i].title}');
    }

    syncIndexFromRoute();

    html.window.onPopState.listen((event) {
      print('🔙 PopState event detected');
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
    print('🔄 changePage called with index: $index, current: ${selectedIndex.value}');

    if (selectedIndex.value != index) {
      selectedIndex.value = index;
      final items = allItems;
      if (index >= 0 && index < items.length) {
        String route = items[index].route;
        html.window.history.pushState(null, '', route);
        print('✅ Navigated to: $route');
      }
    } else {
      print('⚠️ Same index, no change needed');
    }
  }

  void navigateToRoute(String route) {
    print('🧭 navigateToRoute: $route');
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
    print('🔄 Syncing from path: "$currentPath"');

    // Check for profile route
    if (currentPath.contains(profileRoute) || currentPath.endsWith(profileRoute)) {
      if (selectedIndex.value != -1) {
        selectedIndex.value = -1;
        print('✅ Synced to profile (index: -1)');
      }
      return;
    }

    final items = allItems;

    final sortedItems = items.toList()
      ..sort((a, b) => b.route.length.compareTo(a.route.length));

    print('📋 Checking against routes (sorted by specificity):');
    for (int i = 0; i < sortedItems.length; i++) {
      print('   ${sortedItems[i].route}');
    }

    for (int i = 0; i < sortedItems.length; i++) {
      String route = sortedItems[i].route;
      int originalIndex = items.indexOf(sortedItems[i]);

      bool isExactMatch = currentPath == route;
      bool isPathSegmentMatch = currentPath.endsWith(route) &&
          (currentPath.length == route.length ||
              currentPath[currentPath.length - route.length - 1] == '/');

      print('🔍 Checking route: "$route" (original index: $originalIndex)');
      print('   Exact match? $isExactMatch');
      print('   Path segment match? $isPathSegmentMatch');

      if (isExactMatch || isPathSegmentMatch) {
        if (selectedIndex.value != originalIndex) {
          selectedIndex.value = originalIndex;
          print('✅ Synced to index: $originalIndex, route: $route');
        } else {
          print('ℹ️ Already at correct index: $originalIndex');
        }
        return;
      }
    }

    // If no match found, check if we should default to dashboard
    print('⚠️ No route match found for: "$currentPath"');

    // Only default to dashboard if we're at the root dashboard URL
    if (currentPath == '/' || currentPath == '/dashboard' || currentPath.isEmpty) {
      if (selectedIndex.value != 0) {
        selectedIndex.value = 0;
        print('✅ Defaulted to dashboard (index: 0)');
      }
    } else {
      print('⚠️ Keeping current index: ${selectedIndex.value}');
    }
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
      print('⚠️ Index out of range, returning DashboardHomeView');
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
          print('📦 Registered MyDevicesController');
        }
        return const MyDevicesView();
      case Routes.PAYEMENT_METHOD:
        if (!Get.isRegistered<PaymentMethodsController>()) {
          Get.put(PaymentMethodsController());
          print('📦 Registered PaymentMethodsController');
        }
        return const PaymentMethodsView();
      case Routes.CATEGORIES:
        if (!Get.isRegistered<CategoriesController>()) {
          Get.put(CategoriesController());
        }
        return const CategoriesView();
      case Routes.MY_PURCHASES:
        if (!Get.isRegistered<MyPurchasesController>()) {
          Get.put(MyPurchasesController());
        }
        return const MyPurchasesView();
      case Routes.SUBSCRIPTION:
        if (!Get.isRegistered<SubscriptionController>()) {
          Get.put(SubscriptionController());
          print('📦 Registered SubscriptionController');
        }
        return const SubscriptionView();

      case Routes.REMINDER:
        if (!Get.isRegistered<ReminderController>()) {
          Get.put(ReminderController());
        }
        return const ReminderView();
      case Routes.SETTINGS:
        return const SettingsView();
      case Routes.POLICY_SETTINGS:
        return const PolicySettingsView();
      default:
        print('⚠️ Unknown route: $route, returning DashboardHomeView');
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