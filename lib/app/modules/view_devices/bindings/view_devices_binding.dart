import 'package:get/get.dart';

import '../controllers/view_devices_controller.dart';

class ViewDevicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewDevicesController>(
      () => ViewDevicesController(),
    );
  }
}
