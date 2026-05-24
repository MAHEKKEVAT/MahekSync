import 'package:get/get.dart';
import 'package:maheksync/app/modules/smart_map_dashboard/controllers/smart_map_dashboard_controller.dart';

class SmartMapDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SmartMapDashboardController>(() => SmartMapDashboardController());
  }
}
