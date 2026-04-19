// lib/app/modules/add_new_devices/controllers/add_new_devices_controller.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/category_firestore_utils.dart';
import 'package:maheksync/app/utils/device_firestore_utils.dart';
import 'package:maheksync/app/utils/payment_method_firestore_utils.dart';
import '../../../constant/show_toast.dart';

class AddNewDevicesController extends GetxController {
  final deviceNameController = TextEditingController();
  final brandNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final warrantyEndDate = Rxn<DateTime>();
  final priceController = TextEditingController();
  final storeNameController = TextEditingController();

  // Dynamic data from Firestore
  final categories = <CategoryModel>[].obs;
  final paymentMethods = <PaymentMethodModel>[].obs;

  final selectedCategory = Rxn<CategoryModel>();
  final selectedPaymentMethod = Rxn<PaymentMethodModel>();
  final selectedCondition = 'NEW'.obs;
  final purchaseDate = Rxn<DateTime>();

  void setWarrantyEndDate(DateTime date) => warrantyEndDate.value = date;

  final deviceImages = <XFile>[].obs;
  final imageBytes = <Uint8List>[].obs;
  final isLoading = false.obs;

  final conditions = ['NEW', 'USED', 'REFURB', 'MINT', 'FACTORY NEW'];

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadPaymentMethods();
  }

  void loadCategories() {
    CategoryFirestoreUtils.getCategories().listen((cats) {
      categories.value = cats;
    });
  }

  void loadPaymentMethods() {
    PaymentMethodFirestoreUtils.getPaymentMethods().listen((methods) {
      paymentMethods.value = methods;
    });
  }

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
        category: selectedCategory.value?.name ?? 'Uncategorized',
        condition: selectedCondition.value,
        price: double.tryParse(priceController.text) ?? 0.0,
        storeName: storeNameController.text.trim(),
        description: descriptionController.text.trim(),
        purchaseDate: purchaseDate.value,
        warrantyEndDate: warrantyEndDate.value,
        paymentMethod: selectedPaymentMethod.value?.pName,
        deviceImageUrls: uploadedUrls,
      );

      final success = await DeviceFirestoreUtils.addDevice(device);

      if (success) {
        ShowToastDialog.showSuccess('Device Registered successfully!');
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