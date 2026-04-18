import 'package:get/get.dart';

import '../controllers/policy_settings_controller.dart';

class PolicySettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PolicySettingsController>(
      () => PolicySettingsController(),
    );
  }
}
