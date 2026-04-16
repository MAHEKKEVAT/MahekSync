// lib/app/modules/add_new_devices/controllers/add_new_devices_controller.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/services/device_service.dart';
import 'package:maheksync/app/services/imagekit_service.dart';
import '../../../constant/show_toast.dart';

class AddNewDevicesController extends GetxController {
  final deviceNameController = TextEditingController();
  final storeNameController = TextEditingController();
  final priceController = TextEditingController();
  final notesController = TextEditingController();

  final selectedCategory = 'Computing'.obs;
  final selectedCondition = 'NEW'.obs;
  final selectedPaymentMethod = 'Credit Card'.obs;

  final purchaseDate = Rxn<DateTime>();
  final warrantyEndDate = Rxn<DateTime>();
  final deviceImage = Rxn<XFile>();

  final isLoading = false.obs;

  final categories = ['Computing', 'Mobile', 'Tablet', 'Wearable', 'Audio', 'Accessories'];
  final conditions = ['NEW', 'USED', 'REFURB'];
  final paymentMethods = ['Credit Card', 'PayPal', 'Cash', 'Other'];

  @override
  void onClose() {
    deviceNameController.dispose();
    storeNameController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final image = await ImageKitService.pickImage();
    if (image != null) {
      deviceImage.value = image;
    }
  }

  void removeImage() {
    deviceImage.value = null;
  }

  void setPurchaseDate(DateTime date) {
    purchaseDate.value = date;
  }

  void setWarrantyEndDate(DateTime date) {
    warrantyEndDate.value = date;
  }

  Future<void> registerDevice() async {
    if (deviceNameController.text.isEmpty) {
      ShowToastDialog.showError('Device name is required');
      return;
    }
    if (purchaseDate.value == null) {
      ShowToastDialog.showError('Purchase date is required');
      return;
    }

    isLoading.value = true;

    try {
      String? imageUrl;

      if (deviceImage.value != null) {
        imageUrl = await ImageKitService.uploadDeviceImage(deviceImage.value!);
      }

      final device = DeviceModel(
        ownerId: MahekConstant.ownerModel?.id,
        deviceName: deviceNameController.text.trim(),
        category: selectedCategory.value,
        condition: selectedCondition.value,
        price: double.tryParse(priceController.text) ?? 0.0,
        storeName: storeNameController.text.trim(),
        purchaseDate: purchaseDate.value,
        warrantyEndDate: warrantyEndDate.value,
        paymentMethod: selectedPaymentMethod.value,
        deviceImageUrl: imageUrl,
        notes: notesController.text.trim(),
      );

      final success = await DeviceService.addDevice(device);

      if (success) {
        ShowToastDialog.showSuccess('Device registered successfully!');
        Get.back(result: true);
      } else {
        ShowToastDialog.showError('Failed to register device');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void discardChanges() {
    Get.back();
  }
}