// lib/app/modules/dashboard/controllers/dashboard_controller.dart
import 'package:get/get.dart';
import 'package:maheksync/app/modules/auth/controllers/auth_controller.dart';
import 'package:maheksync/app/routes/app_pages.dart';

class DashboardController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final selectedIndex = 0.obs;
  var isNavigating = false.obs;

  @override
  void onInit() {
    super.onInit();
  }


  void signOut() {
    _authController.signOut();
  }


  void onNavItemTapped(int index) {
    if (isNavigating.value) return;
    if (selectedIndex.value == index) return;

    isNavigating.value = true;

    selectedIndex.value = index;

    Future.delayed(const Duration(milliseconds: 150), () {
      isNavigating.value = false;
    });
  }
}