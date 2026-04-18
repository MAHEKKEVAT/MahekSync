// lib/app/modules/add_new_devices/controllers/add_new_devices_controller.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/device_firestore_utils.dart';
import '../../../constant/show_toast.dart';

class AddNewDevicesController extends GetxController {
  final deviceNameController = TextEditingController();
  final brandNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final warrantyEndDate = Rxn<DateTime>();
  final priceController = TextEditingController();
  final storeNameController = TextEditingController();

  final selectedCategory = 'Art & Decor'.obs;
  final selectedCondition = 'NEW'.obs;
  final purchaseDate = Rxn<DateTime>();

  void setWarrantyEndDate(DateTime date) => warrantyEndDate.value = date;

  final deviceImages = <XFile>[].obs;
  final imageBytes = <Uint8List>[].obs;
  final isLoading = false.obs;

  final categories = ['Art & Decor', 'Computing', 'Mobile', 'Tablet', 'Wearable', 'Audio', 'Accessories'];
  final conditions = ['NEW', 'USED', 'REFURB', 'MINT', 'FACTORY NEW'];

  @override
  void onClose() {
    deviceNameController.dispose();
    brandNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    storeNameController.dispose();
    super.onClose();
  }

  Future<void> pickImages() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(imageQuality: 85);

      if (images.isNotEmpty) {
        for (var img in images) {
          deviceImages.add(img);
          final bytes = await img.readAsBytes();
          imageBytes.add(bytes);
        }
      }
    } catch (e) {
      ShowToastDialog.showError('Failed to pick images');
    }
  }

  void removeImage(int index) {
    deviceImages.removeAt(index);
    imageBytes.removeAt(index);
  }

  void setPurchaseDate(DateTime date) => purchaseDate.value = date;

  Future<void> registerDevice() async {
    if (deviceNameController.text.isEmpty) {
      ShowToastDialog.showError('Device name is required');
      return;
    }

    isLoading.value = true;

    try {
      List<String> uploadedUrls = [];

      if (deviceImages.isNotEmpty) {
        final ownerId = MahekConstant.ownerModel?.id ?? 'unknown';
        for (var img in deviceImages) {
          final url = await ImageKitAPI.uploadImage(
            imageFile: img,
            folderName: 'devices/$ownerId',
          );
          if (url != null) uploadedUrls.add(url);
        }
      }

      final device = DeviceModel(
        ownerId: MahekConstant.ownerModel?.id,
        deviceName: deviceNameController.text.trim(),
        brandName: brandNameController.text.trim(),
        category: selectedCategory.value,
        condition: selectedCondition.value,
        price: double.tryParse(priceController.text) ?? 0.0,
        storeName: storeNameController.text.trim(),
        description: descriptionController.text.trim(),
        purchaseDate: purchaseDate.value,
        warrantyEndDate: warrantyEndDate.value,
        deviceImageUrls: uploadedUrls,
      );

      final success = await DeviceFirestoreUtils.addDevice(device);

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

  void discardChanges() => Get.back();
}