// lib/app/modules/dashboard/controllers/dashboard_controller.dart
import 'package:get/get.dart';
import 'package:maheksync/app/modules/auth/controllers/auth_controller.dart';
import 'package:maheksync/app/routes/app_pages.dart';

class DashboardController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }


  void signOut() {
    _authController.signOut();
  }

  void onNavItemTapped(int index) {
    selectedIndex.value = index;

    switch (index) {
      case 0:
        Get.offNamedUntil(Routes.DASHBOARD, (route) => route.settings.name == Routes.DASHBOARD);
        break;
      case 1:
        Get.offNamedUntil(Routes.MY_DEVICES, (route) => route.settings.name == Routes.DASHBOARD);
        break;
      case 2:
       // Get.offNamedUntil(Routes.WARRANTY_TRACKER, (route) => route.settings.name == Routes.DASHBOARD);
        break;
      case 3:
      //  Get.offNamedUntil(Routes.EXPENSES, (route) => route.settings.name == Routes.DASHBOARD);
        break;
      case 4:
      //  Get.offNamedUntil(Routes.SETTINGS, (route) => route.settings.name == Routes.DASHBOARD);
        break;
      case 5:
       // Get.offNamedUntil(Routes.SUPPORT, (route) => route.settings.name == Routes.DASHBOARD);
        break;
    }
  }
}