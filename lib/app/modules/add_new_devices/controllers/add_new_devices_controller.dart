import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/firestore_utills/device_firestore_utils.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/firestore_utills/category_firestore_utils.dart';
import 'package:maheksync/app/firestore_utills/payment_method_firestore_utils.dart';
import '../../../constant/show_toast.dart';

class AddNewDevicesController extends GetxController {
  final deviceNameController = TextEditingController();
  final brandNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final warrantyEndDate = Rxn<DateTime>();
  final priceController = TextEditingController();
  final storeNameController = TextEditingController();

  final categories = <CategoryModel>[].obs;
  final paymentMethods = <PaymentMethodModel>[].obs;

  final selectedCategory = Rxn<CategoryModel>();
  final selectedPaymentMethod = Rxn<PaymentMethodModel>();
  final selectedCondition = 'NEW'.obs;
  final purchaseDate = Rxn<DateTime>();

  final deviceImages = <XFile>[].obs;
  final imageBytes = <Uint8List>[].obs;
  final isLoading = false.obs;

  final totalDevices = 0.obs;
  final totalCategories = 0.obs;
  final totalValue = 0.0.obs;

  final conditions = ['NEW', 'USED', 'REFURB', 'MINT', 'FACTORY NEW'];

  DeviceModel? _editingDevice;
  bool get isEditMode => _editingDevice != null;

  @override
  void onInit() {
    super.onInit();
    _populateFromArguments();
    loadCategories();
    loadPaymentMethods();
    _loadStats();
  }

  void _populateFromArguments() {
    final device = Get.arguments;
    if (device is DeviceModel) {
      _editingDevice = device;
      deviceNameController.text = device.deviceName ?? '';
      brandNameController.text = device.brandName ?? '';
      descriptionController.text = device.description ?? '';
      priceController.text = (device.price ?? 0.0).toString();
      storeNameController.text = device.storeName ?? '';
      selectedCondition.value = device.condition ?? 'NEW';
      purchaseDate.value = device.purchaseDate;
      warrantyEndDate.value = device.warrantyEndDate;
    }
  }

  void _loadStats() {
    final ownerId = MahekConstant.ownerModel?.id;
    if (ownerId == null) return;
    DeviceFirestoreUtils.getUserDevices(ownerId).listen((devices) {
      totalDevices.value = devices.length;
      totalValue.value = devices.fold(0.0, (sum, d) => sum + (d.price ?? 0.0));
    });
    CategoryFirestoreUtils.getCategories().listen((cats) {
      totalCategories.value = cats.length;
    });
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

  void setWarrantyEndDate(DateTime date) => warrantyEndDate.value = date;

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

      bool success;
      if (isEditMode) {
        final updated = DeviceModel(
          id: _editingDevice!.id,
          ownerId: _editingDevice!.ownerId,
          deviceName: deviceNameController.text.trim(),
          brandName: brandNameController.text.trim(),
          category: selectedCategory.value?.name ?? device.category,
          condition: selectedCondition.value,
          price: double.tryParse(priceController.text) ?? 0.0,
          storeName: storeNameController.text.trim(),
          description: descriptionController.text.trim(),
          purchaseDate: purchaseDate.value,
          warrantyEndDate: warrantyEndDate.value,
          paymentMethod: selectedPaymentMethod.value?.pName,
          deviceImageUrls: _editingDevice!.deviceImageUrls,
          notes: _editingDevice!.notes,
          createdAt: _editingDevice!.createdAt,
        );
        success = await DeviceFirestoreUtils.updateDevice(updated);
        if (success) {
          ShowToastDialog.showSuccess('Device updated successfully!');
          Get.back(result: true);
        } else {
          ShowToastDialog.showError('Failed to update device');
        }
      } else {
        success = await DeviceFirestoreUtils.addDevice(device);
        if (success) {
          ShowToastDialog.showSuccess('Device registered successfully!');
          Get.back(result: true);
        } else {
          ShowToastDialog.showError('Failed to register device');
        }
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void discardChanges() => Get.back();
}
