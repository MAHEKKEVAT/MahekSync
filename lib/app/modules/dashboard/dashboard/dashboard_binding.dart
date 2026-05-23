import 'package:get/get.dart';
import 'dashboard_controller.dart';
import 'dashboard_nav_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardNavController>(() => DashboardNavController());
    Get.lazyPut<DashboardHomeController>(() => DashboardHomeController());
  }
}
