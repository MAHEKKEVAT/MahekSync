// lib/app/modules/payment_methods/bindings/payment_methods_binding.dart
import 'package:get/get.dart';
import 'package:maheksync/app/modules/payement_method/controllers/payement_method_controller.dart';

class PaymentMethodsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentMethodsController>(() => PaymentMethodsController());
  }
}