import 'package:get/get.dart';
import 'package:maheksync/app/routes/app_pages.dart';

class ErrorScreenController extends GetxController {
  String get attemptedPath {
    final fullPath = Uri.base.path;
    if (fullPath.isEmpty || fullPath == '/') return '';
    return fullPath;
  }

  void goToLogin() {
    Get.offAllNamed(Routes.LOGIN_SCREEN);
  }

  void goHome() {
    Get.offAllNamed(Routes.LOGIN_SCREEN);
  }
}
