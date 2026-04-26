import 'package:get/get.dart';

import '../controllers/reminder_crud_controller.dart';

class ReminderCrudBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReminderCrudController>(
      () => ReminderCrudController(),
    );
  }
}
