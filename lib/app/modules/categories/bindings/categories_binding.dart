// lib/app/modules/categories/bindings/categories_binding.dart
import 'package:get/get.dart';
import '../controllers/categories_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoriesController>(() => CategoriesController());
  }
}