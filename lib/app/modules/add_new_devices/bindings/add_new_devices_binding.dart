import 'package:get/get.dart';

import '../controllers/add_new_devices_controller.dart';

class AddNewDevicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddNewDevicesController>(
      () => AddNewDevicesController(),
    );
  }
}
