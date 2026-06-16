import 'package:get/get.dart';
import '../controllers/aegis_controller.dart';

class AegisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AegisController>(() => AegisController());
  }
}
