import 'package:get/get.dart';

import '../controllers/personal_task_crud_controller.dart';

class PersonalTaskCrudBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PersonalTaskCrudController>(
      () => PersonalTaskCrudController(),
    );
  }
}
