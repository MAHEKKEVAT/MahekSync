import 'package:maheksync/app/constant/toast_service.dart';

class ShowToastDialog {
  static void showLoader(String message) {
    ToastService().showLoader(message);
  }

  static void closeLoader() {
    ToastService().closeLoader();
  }

  static void showSuccess(String message, {String? subtitle, ToastPosition position = ToastPosition.top}) {
    ToastService().showSuccessToast(message, subtitle: subtitle, position: position);
  }

  static void showError(String message, {String? subtitle, ToastPosition position = ToastPosition.top}) {
    ToastService().showErrorToast(message, subtitle: subtitle, position: position);
  }

  static void showWarning(String message, {String? subtitle, ToastPosition position = ToastPosition.top}) {
    ToastService().showWarningToast(message, subtitle: subtitle, position: position);
  }
}
