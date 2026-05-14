import 'package:get/get.dart';

import '../controllers/dues_tracker_controller.dart';

class DuesTrackerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DuesTrackerController>(
      () => DuesTrackerController(),
    );
  }
}
