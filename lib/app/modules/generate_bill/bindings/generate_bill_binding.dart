// lib/app/modules/generate_bill/bindings/generate_bill_binding.dart
import 'package:get/get.dart';
import 'package:maheksync/app/modules/generate_bill/controllers/generate_bill_controller.dart';

class GenerateBillBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GenerateBillController>(
      () => GenerateBillController(),
    );
  }
}
