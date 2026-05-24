import 'package:get/get.dart';

import '../controllers/my_contacts_controller.dart';

class MyContactsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyContactsController>(
      () => MyContactsController(),
    );
  }
}
