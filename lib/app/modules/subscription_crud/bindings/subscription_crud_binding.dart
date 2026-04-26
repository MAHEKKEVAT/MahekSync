import 'package:get/get.dart';

import '../controllers/subscription_crud_controller.dart';

class SubscriptionCrudBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionCrudController>(
      () => SubscriptionCrudController(),
    );
  }
}
