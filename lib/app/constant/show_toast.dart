import 'package:maheksync/app/constant/toast_service.dart';

class ShowToastDialog {
  static void showLoader(String message) {
    ToastService().showLoader(message);
  }

  static void closeLoader() {
    ToastService().closeLoader();
  }

  static void showSuccess(String message, {ToastPosition position = ToastPosition.top}) {
    ToastService().showSuccessToast(message, position: position);
  }

  static void showError(String message, {ToastPosition position = ToastPosition.top}) {
    ToastService().showErrorToast(message, position: position);
  }

  static void showWarning(String message, {ToastPosition position = ToastPosition.top}) {
    ToastService().showWarningToast(message, position: position);
  }
}
