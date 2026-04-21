import 'package:get/get.dart';

import '../controllers/add_edit_purchase_controller.dart';

class AddEditPurchaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddEditPurchaseController>(
      () => AddEditPurchaseController(),
    );
  }
}
