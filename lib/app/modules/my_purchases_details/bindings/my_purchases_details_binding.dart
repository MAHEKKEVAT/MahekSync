import 'package:get/get.dart';

import '../controllers/my_purchases_details_controller.dart';

class MyPurchasesDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyPurchasesDetailsController>(
      () => MyPurchasesDetailsController(),
    );
  }
}
