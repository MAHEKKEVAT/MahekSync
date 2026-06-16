import 'package:get/get.dart';
import '../controllers/image_to_text_controller.dart';

class ImageToTextBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageToTextController>(() => ImageToTextController());
  }
}
