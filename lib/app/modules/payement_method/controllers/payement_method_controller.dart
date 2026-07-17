// lib/app/modules/payment_methods/controllers/payment_methods_controller.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/firestore_utills/payment_method_firestore_utils.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import '../../../constant/show_toast.dart';

class PaymentMethodsController extends GetxController {
  final paymentMethods = <PaymentMethodModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Form controllers
  final nameController = TextEditingController();
  final selectedIcon = Rxn<XFile>();
  final iconBytes = Rxn<Uint8List>();
  final editingMethod = Rxn<PaymentMethodModel>();

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void loadPaymentMethods() {
    PaymentMethodFirestoreUtils.getPaymentMethods().listen((methods) {
      paymentMethods.value = methods;
    });
  }

  Future<void> pickIcon() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
      );
      if (image != null) {
        selectedIcon.value = image;
        final bytes = await image.readAsBytes();
        iconBytes.value = bytes;
      }
    } catch (e) {
      ShowToastDialog.showError('Failed to pick image');
    }
  }

  void removeIcon() {
    selectedIcon.value = null;
    iconBytes.value = null;
  }

  void startEditing(PaymentMethodModel method) {
    editingMethod.value = method;
    nameController.text = method.pName ?? '';
    selectedIcon.value = null;
    iconBytes.value = null;
  }

  void cancelEditing() {
    editingMethod.value = null;
    nameController.clear();
    removeIcon();
  }

  Future<void> savePaymentMethod() async {
    if (nameController.text.trim().isEmpty) {
      ShowToastDialog.showError('Payment method name is required');
      return;
    }

    // Check if icon exists (either existing or newly selected)
    if (editingMethod.value == null && selectedIcon.value == null) {
      ShowToastDialog.showError('Please select an icon');
      return;
    }

    isSaving.value = true;

    try {
      String? iconUrl = editingMethod.value?.pIcon;

      // Upload new icon if selected
      if (selectedIcon.value != null) {
        final ownerId = MahekConstant.ownerModel?.id ?? 'unknown';
        iconUrl = await ImageKitAPI.uploadImage(
          imageFile: selectedIcon.value!,
          folderName: 'payment_methods/$ownerId',
        );
        if (iconUrl == null) {
          ShowToastDialog.showError('Failed to upload icon');
          isSaving.value = false;
          return;
        }
      }

      final method = PaymentMethodModel(
        id: editingMethod.value?.id ?? MahekConstant.getUuid(),
        pIcon: iconUrl,
        pName: nameController.text.trim(),
        createdAt: editingMethod.value?.createdAt ?? DateTime.now(),
      );

      bool success;
      if (editingMethod.value == null) {
        success = await PaymentMethodFirestoreUtils.addPaymentMethod(method);
      } else {
        success = await PaymentMethodFirestoreUtils.updatePaymentMethod(method);
      }

      if (success) {
        ShowToastDialog.showSuccess(
            editingMethod.value == null
                ? 'Payment method added successfully!'
                : 'Payment method updated successfully!'
        );
        cancelEditing();
      } else {
        ShowToastDialog.showError('Failed to save payment method');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deletePaymentMethod(PaymentMethodModel method) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete "${method.pName}"?'),
        actions: [
          RoundShapeButton(
            title: 'Cancel',
            buttonColor: Colors.transparent,
            buttonTextColor: AppThemeData.primary50,
            onTap: () => Get.back(result: false),
            borderRadius: 12,
            height: 44,
          ),
          RoundShapeButton(
            title: 'Delete',
            buttonColor: AppThemeData.danger300,
            buttonTextColor: Colors.white,
            onTap: () => Get.back(result: true),
            borderRadius: 12,
            height: 44,
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (method.id == null) {
      ShowToastDialog.showError('Invalid payment method');
      return;
    }

    final success = await PaymentMethodFirestoreUtils.deletePaymentMethod(method.id!);
    if (success) {
      ShowToastDialog.showSuccess('Payment method deleted successfully!');
      if (editingMethod.value?.id == method.id) {
        cancelEditing();
      }
    } else {
      ShowToastDialog.showError('Failed to delete payment method');
    }
  }
}