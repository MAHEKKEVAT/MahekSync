import 'package:get/get.dart';
import '../controllers/vault_crud_controller.dart';

class VaultCrudBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VaultCrudController>(() => VaultCrudController());
  }
}
