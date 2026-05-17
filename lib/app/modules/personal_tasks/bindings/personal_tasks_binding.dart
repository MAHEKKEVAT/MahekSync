import 'package:get/get.dart';

import '../controllers/personal_tasks_controller.dart';

class PersonalTasksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PersonalTasksController>(
      () => PersonalTasksController(),
    );
  }
}
