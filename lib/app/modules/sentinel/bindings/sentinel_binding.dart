import 'package:get/get.dart';
import '../controllers/sentinel_controller.dart';

class SentinelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SentinelController>(() => SentinelController());
  }
}
