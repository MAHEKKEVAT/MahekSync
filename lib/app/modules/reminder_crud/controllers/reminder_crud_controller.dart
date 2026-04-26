// lib/app/modules/reminder_crud/controllers/reminder_crud_controller.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/models/reminder_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/reminder_firestore_utils.dart';

class ReminderCrudController extends GetxController {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final selectedImportance = 'MEDIUM'.obs;
  final isActive = true.obs;
  final createdDate = Rxn<DateTime>();
  final expiryDate = Rxn<DateTime>();

  final importances = ['HIGH', 'MEDIUM', 'LOW'];

  final selectedIcon = Rxn<XFile>();
  final iconBytes = Rxn<Uint8List>();

  final isLoading = false.obs;
  final isEditMode = false.obs;
  final editingReminder = Rxn<ReminderModel>();

  @override
  void onInit() {
    super.onInit();
    final reminder = Get.arguments as ReminderModel?;
    if (reminder != null) {
      isEditMode.value = true;
      editingReminder.value = reminder;
      _populateForm(reminder);
    }
  }

  void _populateForm(ReminderModel r) {
    nameController.text = r.name ?? '';
    descriptionController.text = r.description ?? '';
    selectedImportance.value = r.importance ?? 'MEDIUM';
    isActive.value = r.isActive ?? true;
    createdDate.value = r.createdDate;
    expiryDate.value = r.expiryDate;
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

  Future<void> saveReminder() async {
    if (nameController.text.isEmpty) {
      ShowToastDialog.showError('Reminder name is required');
      return;
    }

    isLoading.value = true;
    try {
      String? iconUrl = editingReminder.value?.iconUrl;
      if (selectedIcon.value != null) {
        final ownerId = MahekConstant.ownerModel?.id ?? 'unknown';
        iconUrl = await ImageKitAPI.uploadImage(imageFile: selectedIcon.value!, folderName: 'reminders/$ownerId');
      }

      final reminder = ReminderModel(
        id: editingReminder.value?.id ?? MahekConstant.getUuid(),
        ownerId: MahekConstant.ownerModel?.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        importance: selectedImportance.value,
        iconUrl: iconUrl,
        isActive: isActive.value,
        createdDate: createdDate.value,
        expiryDate: expiryDate.value,
        createdAt: editingReminder.value?.createdAt,
      );

      bool success = isEditMode.value
          ? await ReminderFirestoreUtils.updateReminder(reminder)
          : await ReminderFirestoreUtils.addReminder(reminder);

      if (success) {
        ShowToastDialog.showSuccess(isEditMode.value ? 'Reminder updated!' : 'Reminder added!');
        Get.back(result: true);
      } else {
        ShowToastDialog.showError('Failed to save reminder');
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
    super.onClose();
  }
}