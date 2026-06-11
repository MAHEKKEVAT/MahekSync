// lib/app/modules/dashboard/bindings/dashboard_binding.dart
import 'package:get/get.dart';
import 'package:maheksync/app/modules/auth/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/dashboard_home_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    Get.put(DashboardController(), permanent: true);
    if (!Get.isRegistered<DashboardHomeController>()) {
      Get.put(DashboardHomeController());
    }
  }
}