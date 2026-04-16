import 'package:get/get.dart';

import '../controllers/my_devices_controller.dart';

class MyDevicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyDevicesController>(
      () => MyDevicesController(),
    );
  }
}
