import 'package:get/get.dart';

import '../controllers/subscription_details_controller.dart';

class SubscriptionDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionDetailsController>(
      () => SubscriptionDetailsController(),
    );
  }
}
