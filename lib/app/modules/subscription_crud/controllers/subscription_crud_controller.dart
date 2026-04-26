// lib/app/modules/subscription_crud/controllers/subscription_crud_controller.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/models/subscription_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/subscription_firestore_utils.dart';
import '../../../routes/app_pages.dart';

class SubscriptionCrudController extends GetxController {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final notesController = TextEditingController();

  final selectedCategory = 'ENTERTAINMENT'.obs;
  final selectedBillingCycle = 'MONTHLY'.obs;
  final selectedStatus = 'ACTIVE'.obs;
  final autoRenew = false.obs;
  final reminderDays = 3.obs;
  final startDate = Rxn<DateTime>();
  final expiryDate = Rxn<DateTime>();

  final categories = ['ENTERTAINMENT', 'UTILITIES', 'PRODUCTIVITY', 'CLOUD', 'MUSIC', 'VIDEO', 'OTHER'];
  final billingCycles = ['MONTHLY', 'QUARTERLY', 'YEARLY'];
  final statuses = ['ACTIVE', 'EXPIRED', 'CANCELLED', 'PENDING'];

  // Images
  final selectedIcon = Rxn<XFile>();
  final iconBytes = Rxn<Uint8List>();
  final selectedImages = <XFile>[].obs;
  final imageBytes = <Uint8List>[].obs;
  final existingImages = <String>[].obs;
  final removedImages = <String>[].obs;

  final isLoading = false.obs;
  final isEditMode = false.obs;
  final editingSubscription = Rxn<SubscriptionModel>();

  @override
  void onInit() {
    super.onInit();
    final sub = Get.arguments as SubscriptionModel?;
    if (sub != null) {
      isEditMode.value = true;
      editingSubscription.value = sub;
      _populateForm(sub);
    }
  }

  void _populateForm(SubscriptionModel sub) {
    nameController.text = sub.name ?? '';
    descriptionController.text = sub.description ?? '';
    priceController.text = sub.price?.toString() ?? '';
    notesController.text = sub.notes ?? '';
    selectedCategory.value = sub.category ?? 'ENTERTAINMENT';
    selectedBillingCycle.value = sub.billingCycle ?? 'MONTHLY';
    selectedStatus.value = sub.status ?? 'ACTIVE';
    autoRenew.value = sub.autoRenew ?? false;
    reminderDays.value = sub.reminderDays ?? 3;
    startDate.value = sub.startDate;
    expiryDate.value = sub.expiryDate;
    existingImages.value = sub.imageUrls ?? [];
  }

  Future<void> pickIcon() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 512);
      if (image != null) {
        selectedIcon.value = image;
        iconBytes.value = await image.readAsBytes();
      }
    } catch (e) {
      ShowToastDialog.showError('Failed to pick icon');
    }
  }

  Future<void> pickImages() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(imageQuality: 85);
      for (var img in images) {
        selectedImages.add(img);
        imageBytes.add(await img.readAsBytes());
      }
    } catch (e) {
      ShowToastDialog.showError('Failed to pick images');
    }
  }

  void removeNewImage(int index) {
    selectedImages.removeAt(index);
    imageBytes.removeAt(index);
  }

  void removeExistingImage(String url) {
    existingImages.remove(url);
    removedImages.add(url);
  }

  Future<void> saveSubscription() async {
    if (nameController.text.isEmpty) {
      ShowToastDialog.showError('Subscription name is required');
      return;
    }

    isLoading.value = true;
    try {
      String? iconUrl = editingSubscription.value?.iconUrl;
      if (selectedIcon.value != null) {
        final ownerId = MahekConstant.ownerModel?.id ?? 'unknown';
        iconUrl = await ImageKitAPI.uploadImage(imageFile: selectedIcon.value!, folderName: 'subscriptions/$ownerId');
      }

      List<String> finalImages = List.from(existingImages);
      if (selectedImages.isNotEmpty) {
        final ownerId = MahekConstant.ownerModel?.id ?? 'unknown';
        final newUrls = await ImageKitAPI.uploadMultipleImages(imageFiles: selectedImages, folderName: 'subscriptions/$ownerId');
        finalImages.addAll(newUrls);
      }

      final sub = SubscriptionModel(
        id: editingSubscription.value?.id ?? MahekConstant.getUuid(),
        ownerId: MahekConstant.ownerModel?.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.tryParse(priceController.text) ?? 0,
        billingCycle: selectedBillingCycle.value,
        startDate: startDate.value,
        expiryDate: expiryDate.value,
        status: selectedStatus.value,
        category: selectedCategory.value,
        iconUrl: iconUrl,
        imageUrls: finalImages,
        notes: notesController.text.trim(),
        autoRenew: autoRenew.value,
        reminderDays: reminderDays.value,
        createdAt: editingSubscription.value?.createdAt,
      );

      bool success = isEditMode.value
          ? await SubscriptionFirestoreUtils.updateSubscription(sub)
          : await SubscriptionFirestoreUtils.addSubscription(sub);

      if (success) {
        ShowToastDialog.showSuccess(isEditMode.value ? 'Subscription updated!' : 'Subscription added!');
        Get.back(result: true);
      } else {
        ShowToastDialog.showError('Failed to save subscription');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.onClose();
  }
}