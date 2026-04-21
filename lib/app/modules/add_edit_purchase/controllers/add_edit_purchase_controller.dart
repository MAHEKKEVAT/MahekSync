// lib/app/modules/add_edit_purchase/controllers/add_edit_purchase_controller.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/models/purchase_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/category_firestore_utils.dart';
import 'package:maheksync/app/utils/payment_method_firestore_utils.dart';
import 'package:maheksync/app/utils/purchase_firestore_utils.dart';
import '../../../constant/show_toast.dart';

class AddEditPurchaseController extends GetxController {
  // Form Controllers
  final assetNameController = TextEditingController();
  final brandController = TextEditingController();
  final priceController = TextEditingController();
  final storeLocationController = TextEditingController();
  final sizeController = TextEditingController();
  final descriptionController = TextEditingController();
  final unitsController = TextEditingController(text: '1');

  // Selections
  final categories = <CategoryModel>[].obs;
  final paymentMethods = <PaymentMethodModel>[].obs;
  final selectedCategory = Rxn<CategoryModel>();
  final selectedPaymentMethod = Rxn<PaymentMethodModel>();
  final selectedCondition = 'Pristine'.obs;
  final selectedStatus = 'DELIVERED'.obs;
  final purchaseDate = Rxn<DateTime>();
  final warrantyDate = Rxn<DateTime>();

  final conditions = ['Pristine', 'Excellent', 'Good', 'Fair'];
  final statuses = ['DELIVERED', 'IN TRANSIT', 'PRE-ORDER'];

  // Images
  final selectedImages = <XFile>[].obs;
  final imageBytes = <Uint8List>[].obs;
  final isLoading = false.obs;
  final isEditMode = false.obs;
  final editingPurchase = Rxn<PurchaseModel>();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadPaymentMethods();

    final purchase = Get.arguments as PurchaseModel?;
    if (purchase != null) {
      isEditMode.value = true;
      editingPurchase.value = purchase;
      _populateForm(purchase);
    }
  }

  void _populateForm(PurchaseModel purchase) {
    assetNameController.text = purchase.assetName ?? '';
    brandController.text = purchase.brand ?? '';
    priceController.text = purchase.price?.toString() ?? '';
    storeLocationController.text = purchase.storeLocation ?? '';
    sizeController.text = purchase.size ?? '';
    descriptionController.text = purchase.description ?? '';
    unitsController.text = (purchase.units ?? 1).toString();
    selectedCondition.value = purchase.condition ?? 'Pristine';
    selectedStatus.value = purchase.status ?? 'DELIVERED';
    purchaseDate.value = purchase.purchaseDate;
    warrantyDate.value = purchase.warrantyDate;

    // Set category
    if (purchase.category != null) {
      selectedCategory.value = categories.firstWhereOrNull((c) => c.name == purchase.category);
    }

    // Set payment method
    if (purchase.paymentMethod != null) {
      selectedPaymentMethod.value = paymentMethods.firstWhereOrNull((p) => p.pName == purchase.paymentMethod);
    }
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

  Future<void> pickImages() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(imageQuality: 85);

      if (images.isNotEmpty) {
        for (var img in images) {
          selectedImages.add(img);
          final bytes = await img.readAsBytes();
          imageBytes.add(bytes);
        }
      }
    } catch (e) {
      ShowToastDialog.showError('Failed to pick images');
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
    imageBytes.removeAt(index);
  }

  void setPurchaseDate(DateTime date) => purchaseDate.value = date;
  void setWarrantyDate(DateTime date) => warrantyDate.value = date;

  Future<void> savePurchase() async {
    if (assetNameController.text.isEmpty) {
      ShowToastDialog.showError('Asset name is required');
      return;
    }

    if (selectedImages.length < 3 && !isEditMode.value) {
      ShowToastDialog.showError('At least three high-resolution images are required');
      return;
    }

    isLoading.value = true;

    try {
      List<String> uploadedUrls = editingPurchase.value?.imageUrls ?? [];

      if (selectedImages.isNotEmpty) {
        final ownerId = MahekConstant.ownerModel?.id ?? 'unknown';
        final newUrls = await ImageKitAPI.uploadMultipleImages(
          imageFiles: selectedImages,
          folderName: 'my_purchases/$ownerId',
        );
        if (isEditMode.value) {
          uploadedUrls.addAll(newUrls);
        } else {
          uploadedUrls = newUrls;
        }
      }

      final purchase = PurchaseModel(
        id: editingPurchase.value?.id ?? MahekConstant.getUuid(),
        ownerId: MahekConstant.ownerModel?.id,
        assetName: assetNameController.text.trim(),
        brand: brandController.text.trim(),
        category: selectedCategory.value?.name,
        condition: selectedCondition.value,
        price: double.tryParse(priceController.text) ?? 0.0,
        paymentMethod: selectedPaymentMethod.value?.pName,
        storeLocation: storeLocationController.text.trim(),
        size: sizeController.text.trim(),
        description: descriptionController.text.trim(),
        purchaseDate: purchaseDate.value,
        warrantyDate: warrantyDate.value,
        imageUrls: uploadedUrls,
        status: selectedStatus.value,
        units: int.tryParse(unitsController.text) ?? 1,
        createdAt: editingPurchase.value?.createdAt,
      );

      bool success;
      if (isEditMode.value) {
        success = await PurchaseFirestoreUtils.updatePurchase(purchase);
      } else {
        success = await PurchaseFirestoreUtils.addPurchase(purchase);
      }

      if (success) {
        ShowToastDialog.showSuccess(
          isEditMode.value ? 'Purchase updated successfully!' : 'Purchase added successfully!',
        );
        Get.back(result: true);
      } else {
        ShowToastDialog.showError('Failed to save purchase');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void discardChanges() => Get.back();

  @override
  void onClose() {
    assetNameController.dispose();
    brandController.dispose();
    priceController.dispose();
    storeLocationController.dispose();
    sizeController.dispose();
    descriptionController.dispose();
    unitsController.dispose();
    super.onClose();
  }
}