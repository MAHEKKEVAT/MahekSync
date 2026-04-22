// lib/app/modules/my_purchases_details/controllers/my_purchases_details_controller.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/models/purchase_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/category_firestore_utils.dart';
import 'package:maheksync/app/utils/payment_method_firestore_utils.dart';
import 'package:maheksync/app/utils/purchase_firestore_utils.dart';
import '../../../routes/app_pages.dart';

class MyPurchasesDetailsController extends GetxController {
  final purchase = Rxn<PurchaseModel>();
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isEditMode = false.obs;

  // Form Controllers
  final assetNameController = TextEditingController();
  final brandController = TextEditingController();
  final priceController = TextEditingController();
  final storeLocationController = TextEditingController();
  final sizeController = TextEditingController();
  final descriptionController = TextEditingController();
  final unitsController = TextEditingController();

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
  final existingImages = <String>[].obs;
  final newImages = <XFile>[].obs;
  final newImageBytes = <Uint8List>[].obs;
  final removedImages = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadPaymentMethods();

    final args = Get.arguments as PurchaseModel?;
    if (args != null) {
      purchase.value = args;
      _populateForm(args);
    }
  }

  void _populateForm(PurchaseModel p) {
    assetNameController.text = p.assetName ?? '';
    brandController.text = p.brand ?? '';
    priceController.text = p.price?.toString() ?? '';
    storeLocationController.text = p.storeLocation ?? '';
    sizeController.text = p.size ?? '';
    descriptionController.text = p.description ?? '';
    unitsController.text = (p.units ?? 1).toString();
    selectedCondition.value = p.condition ?? 'Pristine';
    selectedStatus.value = p.status ?? 'DELIVERED';
    purchaseDate.value = p.purchaseDate;
    warrantyDate.value = p.warrantyDate;
    existingImages.value = p.imageUrls ?? [];
  }

  void loadCategories() {
    CategoryFirestoreUtils.getCategories().listen((cats) {
      categories.value = cats;
      // Set selected category after loading
      if (purchase.value?.category != null) {
        selectedCategory.value = cats.firstWhereOrNull(
              (c) => c.name == purchase.value!.category,
        );
      }
    });
  }

  void loadPaymentMethods() {
    PaymentMethodFirestoreUtils.getPaymentMethods().listen((methods) {
      paymentMethods.value = methods;
      // Set selected payment method after loading
      if (purchase.value?.paymentMethod != null) {
        selectedPaymentMethod.value = methods.firstWhereOrNull(
              (m) => m.pName == purchase.value!.paymentMethod,
        );
      }
    });
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) {
      // Reset form if cancelling edit
      _populateForm(purchase.value!);
      newImages.clear();
      newImageBytes.clear();
      removedImages.clear();
    }
  }

  Future<void> pickImages() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(imageQuality: 85);

      if (images.isNotEmpty) {
        for (var img in images) {
          newImages.add(img);
          final bytes = await img.readAsBytes();
          newImageBytes.add(bytes);
        }
      }
    } catch (e) {
      ShowToastDialog.showError('Failed to pick images');
    }
  }

  void removeNewImage(int index) {
    newImages.removeAt(index);
    newImageBytes.removeAt(index);
  }

  void removeExistingImage(String imageUrl) {
    existingImages.remove(imageUrl);
    removedImages.add(imageUrl);
  }

  void setPurchaseDate(DateTime date) => purchaseDate.value = date;
  void setWarrantyDate(DateTime date) => warrantyDate.value = date;

  Future<void> savePurchase() async {
    if (assetNameController.text.isEmpty) {
      ShowToastDialog.showError('Asset name is required');
      return;
    }

    if (existingImages.isEmpty && newImages.isEmpty) {
      ShowToastDialog.showError('At least one image is required');
      return;
    }

    isSaving.value = true;

    try {
      List<String> finalImageUrls = List.from(existingImages);

      // Upload new images
      if (newImages.isNotEmpty) {
        final ownerId = MahekConstant.ownerModel?.id ?? 'unknown';
        final newUrls = await ImageKitAPI.uploadMultipleImages(
          imageFiles: newImages,
          folderName: 'my_purchases/$ownerId',
        );
        finalImageUrls.addAll(newUrls);
      }

      final updatedPurchase = PurchaseModel(
        id: purchase.value!.id,
        ownerId: purchase.value!.ownerId,
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
        imageUrls: finalImageUrls,
        status: selectedStatus.value,
        units: int.tryParse(unitsController.text) ?? 1,
        createdAt: purchase.value!.createdAt,
      );

      final success = await PurchaseFirestoreUtils.updatePurchase(updatedPurchase);

      if (success) {
        ShowToastDialog.showSuccess('Purchase updated successfully!');
        purchase.value = updatedPurchase;
        isEditMode.value = false;
        newImages.clear();
        newImageBytes.clear();
        removedImages.clear();
      } else {
        ShowToastDialog.showError('Failed to update purchase');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deletePurchase() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Purchase'),
        content: Text('Are you sure you want to delete "${purchase.value?.assetName}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (purchase.value?.id == null) return;

    isLoading.value = true;
    final success = await PurchaseFirestoreUtils.deletePurchase(purchase.value!.id!);
    isLoading.value = false;

    if (success) {
      ShowToastDialog.showSuccess('Purchase deleted successfully');
      Get.offNamed(Routes.MY_PURCHASES);
    } else {
      ShowToastDialog.showError('Failed to delete purchase');
    }
  }

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