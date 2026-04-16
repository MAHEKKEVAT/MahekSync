// lib/app/modules/dashboard/bindings/dashboard_binding.dart
import 'package:get/get.dart';
import 'package:maheksync/app/modules/auth/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}