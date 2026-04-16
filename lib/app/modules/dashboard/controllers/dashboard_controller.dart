// lib/app/modules/dashboard/controllers/dashboard_controller.dart
import 'package:get/get.dart';
import 'package:maheksync/app/modules/auth/controllers/auth_controller.dart';

class DashboardController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final selectedIndex = 0.obs;

  void signOut() {
    _authController.signOut();
  }

  void onNavItemTapped(int index) {
    selectedIndex.value = index;
  }
}