// lib/app/modules/dashboard/controllers/dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/modules/admin_profile/views/admin_profile_view.dart';
import 'package:maheksync/app/modules/categories/controllers/categories_controller.dart';
import 'package:maheksync/app/modules/categories/views/categories_view.dart';
import 'package:maheksync/app/modules/dues_tracker/controllers/dues_tracker_controller.dart';
import 'package:maheksync/app/modules/dues_tracker/views/dues_tracker_view.dart';
import 'package:maheksync/app/modules/my_contacts/controllers/my_contacts_controller.dart';
import 'package:maheksync/app/modules/my_contacts/views/my_contacts_view.dart';
import 'package:maheksync/app/modules/image_to_text/controllers/image_to_text_controller.dart';
import 'package:maheksync/app/modules/image_to_text/views/image_to_text_view.dart';
import 'package:maheksync/app/modules/my_devices/controllers/my_devices_controller.dart';
import 'package:maheksync/app/modules/my_devices/views/my_devices_view.dart';
import 'package:maheksync/app/modules/my_purchases/controllers/my_purchases_controller.dart';
import 'package:maheksync/app/modules/my_purchases/views/my_purchases_view.dart';
import 'package:maheksync/app/modules/payement_method/views/payement_method_view.dart' show PaymentMethodsView;
import 'package:maheksync/app/modules/generate_bill/controllers/generate_bill_controller.dart';
import 'package:maheksync/app/modules/generate_bill/views/generate_bill_list_view.dart';
import 'package:maheksync/app/modules/personal_tasks/controllers/personal_tasks_controller.dart';
import 'package:maheksync/app/modules/personal_tasks/views/personal_tasks_view.dart';
import 'package:maheksync/app/modules/policy_settings/views/policy_settings_view.dart';
import 'package:maheksync/app/modules/reminder/controllers/reminder_controller.dart';
import 'package:maheksync/app/modules/reminder/views/reminder_view.dart';
import 'package:maheksync/app/modules/smart_map_dashboard/controllers/smart_map_dashboard_controller.dart';
import 'package:maheksync/app/modules/smart_map_dashboard/views/smart_map_dashboard_view.dart';
import 'package:maheksync/app/modules/subscription/controllers/subscription_controller.dart';
import 'package:maheksync/app/modules/subscription/views/subscription_view.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/modules/settings/views/settings_view.dart';
import 'package:maheksync/app/modules/settings/controllers/settings_controller.dart';
import 'package:maheksync/app/modules/aegis/controllers/aegis_controller.dart';
import 'package:maheksync/app/modules/aegis/views/aegis_view.dart';
import 'package:maheksync/app/modules/movies/controllers/movies_controller.dart';
import 'package:maheksync/app/modules/movies/views/movies_view.dart';
import 'package:maheksync/app/modules/weather/controllers/weather_controller.dart';
import 'package:maheksync/app/modules/weather/views/weather_view.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/font_family.dart';
import '../../../widgets/text_widget.dart';
import '../../../utils/web_history.dart'; // ✅ REPLACED dart:html
import '../../../constant/show_toast.dart';
import '../../payement_method/controllers/payement_method_controller.dart';
import '../views/dashboard_home_view.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  var isNavExpanded = true.obs;
  static const String profileRoute = '/admin-profile';

  RxBool isEmployeeLoading = true.obs;
  DateTime? currentBackPressTime;

  final List<NavigationSection> navigationSections = [
    NavigationSection(
      title: "OVERVIEW".tr,
      items: [
        NavigationItem(
          title: "Dashboard".tr,
          route: Routes.DASHBOARD,
          svgIcon: 'assets/icons/ic_dashboard.svg',
        ),
      ],
    ),

    NavigationSection(
      title: 'MANAGEMENT'.tr,
      items: [
        NavigationItem(
          title: 'My Devices'.tr,
          route: Routes.MY_DEVICES,
          svgIcon: 'assets/icons/ic_devices.svg',
        ),
        NavigationItem(
          title: 'Payment Methods'.tr,
          route: Routes.PAYEMENT_METHOD,
          svgIcon: 'assets/icons/ic_payment.svg',
        ),
        NavigationItem(
          title: 'Categories'.tr,
          route: Routes.CATEGORIES,
          svgIcon: 'assets/icons/ic_categories.svg',
        ),
        NavigationItem(
          title: 'My Purchases'.tr,
          route: Routes.MY_PURCHASES,
          svgIcon: 'assets/icons/ic_purchases.svg',
        ),
        NavigationItem(
          title: 'Subscriptions'.tr,
          route: Routes.SUBSCRIPTION,
          svgIcon: 'assets/icons/ic_subscriptions.svg',
        ),
        NavigationItem(
          title: 'Reminders'.tr,
          route: Routes.REMINDER,
          svgIcon: 'assets/icons/ic_reminder.svg',
        ),
        NavigationItem(
          title: 'Dues Tracker'.tr,
          route: Routes.DUES_TRACKER,
          svgIcon: 'assets/icons/ic_dues.svg',
        ),
        NavigationItem(
          title: 'Generate Bill'.tr,
          route: Routes.GENERATE_BILL,
          svgIcon: 'assets/icons/ic_bill.svg',
        ),
        NavigationItem(
          title: 'Movies'.tr,
          route: Routes.MOVIES,
          svgIcon: 'assets/icons/ic_movies.svg',
        ),
      ],
    ),
    NavigationSection(
      title: 'PRODUCTIVITY'.tr,
      items: [
        NavigationItem(
          title: 'Personal Tasks'.tr,
          route: Routes.PERSONAL_TASKS,
          svgIcon: 'assets/icons/ic_tasks.svg',
        ),
        NavigationItem(
          title: 'Smart Map'.tr,
          route: '/smart-map-dashboard',
          svgIcon: 'assets/icons/ic_pin.svg',
        ),
        NavigationItem(
          title: 'My Contacts'.tr,
          route: '/my-contacts',
          svgIcon: 'assets/icons/ic_contacts.svg',
        ),
        NavigationItem(
          title: 'Image to Text'.tr,
          svgIcon: 'assets/icons/ic_image_text.svg',
          route: Routes.IMAGE_TO_TEXT,
        ),
        NavigationItem(
          title: 'Weather'.tr,
          route: Routes.WEATHER,
          svgIcon: 'assets/icons/ic_weather.svg',
        ),
      ],
    ),

    NavigationSection(
      title: 'SETTINGS'.tr,
      items: [
        NavigationItem(
          title: 'Settings'.tr,
          route: Routes.SETTINGS,
          svgIcon: 'assets/icons/ic_settings.svg',
        ),
        NavigationItem(
          title: 'Policy Settings'.tr,
          route: Routes.POLICY_SETTINGS,
          svgIcon: 'assets/icons/ic_policy.svg',
        ),
      ],
    ),
    NavigationSection(
      title: 'SECURITY'.tr,
      items: [
        NavigationItem(title: 'Aegis'.tr, route: Routes.AEGIS, svgIcon: 'assets/icons/ic_aegis.svg'),
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

    // ✅ Safe on all platforms — returns empty stream on Android/iOS
    WebHistory.onPopState.listen((_) {
      syncIndexFromRoute();
    });
  }

  Future<bool> onWillPop(BuildContext context, bool isDark) async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      bool? exitApp = await showDialog(
        context: context,
        barrierColor: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.5),
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
    WebHistory.pushState(profileRoute); 
  }

  void changePage(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
      final items = allItems;
      if (index >= 0 && index < items.length) {
        String route = items[index].route;
        String title = items[index].title;
        WebHistory.pushState(route);
        ShowToastDialog.showSuccess('Navigated to $title');
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
    String currentPath = WebHistory.getPathname(); // ✅ Safe on all platforms (returns '' on mobile)

    // Check for profile route
    if (currentPath.contains(profileRoute) || currentPath.endsWith(profileRoute)) {
      if (selectedIndex.value != -1) {
        selectedIndex.value = -1;
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

    if (index == -1) {
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
        return SubscriptionView();
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
      case Routes.PERSONAL_TASKS:
        if (!Get.isRegistered<PersonalTasksController>()) {
          Get.put(PersonalTasksController());
        }
        return const PersonalTasksView();
      case '/smart-map-dashboard':
        if (!Get.isRegistered<SmartMapDashboardController>()) {
          Get.put(SmartMapDashboardController());
        }
        return const SmartMapDashboardView();
      case Routes.AEGIS:
        if (!Get.isRegistered<AegisController>()) {
          Get.put(AegisController());
        }
        return const AegisView();

      case '/my-contacts':
        if (!Get.isRegistered<MyContactsController>()) {
          Get.put(MyContactsController());
        }
        return const MyContactsView();

      case Routes.IMAGE_TO_TEXT:
        if (!Get.isRegistered<ImageToTextController>()) {
          Get.put(ImageToTextController());
        }
        return const ImageToTextView();

      case Routes.WEATHER:
        if (!Get.isRegistered<WeatherController>()) {
          Get.put(WeatherController());
        }
        return const WeatherView();

      case Routes.GENERATE_BILL:
        if (!Get.isRegistered<GenerateBillController>()) {
          Get.put(GenerateBillController());
        }
        return const GenerateBillListView();

      case Routes.MOVIES:
        if (!Get.isRegistered<MoviesController>()) {
          Get.put(MoviesController());
        }
        return const MoviesView();

      case Routes.SETTINGS:
        if (!Get.isRegistered<SettingsController>()) {
          Get.put(SettingsController());
        }
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
  final String route;
  final String svgIcon;

  NavigationItem({
    required this.title,
    required this.route,
    required this.svgIcon,
  });
}