import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/modules/admin_profile/views/admin_profile_view.dart';
import 'package:maheksync/app/modules/categories/controllers/categories_controller.dart';
import 'package:maheksync/app/modules/categories/views/categories_view.dart';
import 'package:maheksync/app/modules/dues_tracker/controllers/dues_tracker_controller.dart';
import 'package:maheksync/app/modules/dues_tracker/views/dues_tracker_view.dart';
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
import 'dashboard_controller.dart';
import 'dashboard_view.dart';

class DashboardNavController extends GetxController {
  var selectedIndex = 0.obs;
  var isNavExpanded = true.obs;
  var navHoverIndex = (-1).obs;

  static const String profileRoute = '/admin-profile';
  static const int profileIndex = -1;

  RxBool isEmployeeLoading = true.obs;
  DateTime? currentBackPressTime;

  final List<NavigationSection> navigationSections = [
    NavigationSection(
      title: "OVERVIEW".tr,
      items: [
        NavigationItem(
          title: "Dashboard".tr,
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          route: Routes.DASHBOARD,
        ),
      ],
    ),

    NavigationSection(
      title: 'MANAGEMENT'.tr,
      items: [
        NavigationItem(
          title: 'My Devices'.tr,
          icon: Icons.devices_outlined,
          selectedIcon: Icons.devices_rounded,
          route: Routes.MY_DEVICES,
        ),
        NavigationItem(
          title: 'Payment Methods'.tr,
          icon: Icons.payment_outlined,
          selectedIcon: Icons.payment_rounded,
          route: Routes.PAYEMENT_METHOD,
        ),
        NavigationItem(
          title: 'Categories'.tr,
          icon: Icons.category_outlined,
          selectedIcon: Icons.category_rounded,
          route: Routes.CATEGORIES,
        ),
        NavigationItem(
          title: 'My Purchases'.tr,
          icon: Icons.shopping_bag_outlined,
          selectedIcon: Icons.shopping_bag_rounded,
          route: Routes.MY_PURCHASES,
        ),
        NavigationItem(
          title: 'Subscriptions'.tr,
          icon: Icons.subscriptions_outlined,
          selectedIcon: Icons.subscriptions_rounded,
          route: Routes.SUBSCRIPTION,
        ),
        NavigationItem(
          title: 'Reminders'.tr,
          icon: Icons.alarm_outlined,
          selectedIcon: Icons.alarm_rounded,
          route: Routes.REMINDER,
        ),
        NavigationItem(
          title: 'Dues Tracker'.tr,
          icon: Icons.account_balance_wallet_outlined,
          selectedIcon: Icons.account_balance_wallet_rounded,
          route: Routes.DUES_TRACKER,
        ),
      ],
    ),

    NavigationSection(
      title: 'PRODUCTIVITY'.tr,
      items: [
        NavigationItem(
          title: 'Personal Tasks'.tr,
          icon: Icons.task_alt_outlined,
          selectedIcon: Icons.task_alt_rounded,
          route: '/dashboard/personal-tasks',
        ),
      ],
    ),

    NavigationSection(
      title: 'SECURITY'.tr,
      items: [
        NavigationItem(
          title: 'Sentinel'.tr,
          icon: Icons.security_outlined,
          selectedIcon: Icons.security_rounded,
          route: '/dashboard/sentinel',
        ),
        NavigationItem(
          title: 'Vault'.tr,
          icon: Icons.shield_outlined,
          selectedIcon: Icons.shield_rounded,
          route: '/dashboard/vault',
        ),
      ],
    ),

    NavigationSection(
      title: 'SETTINGS'.tr,
      items: [
        NavigationItem(
          title: 'Settings'.tr,
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          route: Routes.SETTINGS,
        ),
        NavigationItem(
          title: 'Policy Settings'.tr,
          icon: Icons.gavel_outlined,
          selectedIcon: Icons.gavel,
          route: Routes.POLICY_SETTINGS,
        ),
      ],
    ),
  ];

  List<NavigationItem> get allItems {
    List<NavigationItem> items = [];
    for (var section in navigationSections) {
      items.addAll(section.items);
    }
    return items;
  }

  String get currentPageTitle {
    if (selectedIndex.value == profileIndex) return 'Profile';
    final items = allItems;
    if (selectedIndex.value >= 0 && selectedIndex.value < items.length) {
      return items[selectedIndex.value].title;
    }
    return 'Dashboard';
  }

  bool get isProfilePage => selectedIndex.value == profileIndex;
  int get itemCount => allItems.length;

  @override
  Future<void> onInit() async {
    super.onInit();
    syncIndexFromRoute();

    html.window.onPopState.listen((event) {
      syncIndexFromRoute();
    });
  }

  Future<bool> onWillPop(BuildContext context, bool isDark) async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      return true;
    }
    return true;
  }

  void goToProfile() {
    if (selectedIndex.value == profileIndex) return;
    selectedIndex.value = profileIndex;
    html.window.history.pushState(null, '', profileRoute);
  }

  void changePage(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
      final items = allItems;
      if (index >= 0 && index < items.length) {
        String route = items[index].route;
        html.window.history.pushState(null, '', route);
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

  void syncIndexFromRoute() {
    String currentPath = html.window.location.pathname ?? '';

    if (currentPath.contains(profileRoute) ||
        currentPath.endsWith(profileRoute)) {
      if (selectedIndex.value != profileIndex) {
        selectedIndex.value = profileIndex;
      }
      return;
    }

    final items = allItems;
    final sortedItems = items.toList()
      ..sort((a, b) => b.route.length.compareTo(a.route.length));

    for (int i = 0; i < sortedItems.length; i++) {
      String route = sortedItems[i].route;
      int originalIndex = items.indexOf(sortedItems[i]);

      bool isExactMatch = currentPath == route;
      bool isPathSegmentMatch = currentPath.endsWith(route) &&
          (currentPath.length == route.length ||
              currentPath[currentPath.length - route.length - 1] == '/');

      if (isExactMatch || isPathSegmentMatch) {
        if (selectedIndex.value != originalIndex) {
          selectedIndex.value = originalIndex;
        }
        return;
      }
    }

    if (currentPath == '/' || currentPath == '/dashboard' || currentPath.isEmpty) {
      if (selectedIndex.value != 0) {
        selectedIndex.value = 0;
      }
    }
  }

  void toggleNavigation() {
    isNavExpanded.value = !isNavExpanded.value;
  }

  Widget getPageWidget(int index) {
    if (index == profileIndex) {
      return const AdminProfileView();
    }

    final items = allItems;
    if (index < 0 || index >= items.length) {
      return const DashboardHomeView();
    }

    String route = items[index].route;

    switch (route) {
      case Routes.DASHBOARD:
        return const DashboardHomeView();

      case Routes.MY_DEVICES:
        if (!Get.isRegistered<MyDevicesController>()) {
          Get.put(MyDevicesController());
        }
        return const MyDevicesView();

      case Routes.PAYEMENT_METHOD:
        if (!Get.isRegistered<PaymentMethodsController>()) {
          Get.put(PaymentMethodsController());
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
        }
        return const SubscriptionView();

      case Routes.REMINDER:
        if (!Get.isRegistered<ReminderController>()) {
          Get.put(ReminderController());
        }
        return const ReminderView();

      case Routes.DUES_TRACKER:
        if (!Get.isRegistered<DuesTrackerController>()) {
          Get.put(DuesTrackerController());
        }
        return const DuesTrackerView();

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

  NavigationItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}
