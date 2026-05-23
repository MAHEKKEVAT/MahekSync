import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/models/vault_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/vault_firestore_utils.dart';

class VaultCrudController extends GetxController {
  final titleController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final websiteController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();
  final tagController = TextEditingController();

  final selectedCategory = 'PASSWORD'.obs;
  final categories = ['PASSWORD', 'API_KEY', 'WIFI', 'BANK', 'EMAIL', 'SUBSCRIPTION', 'LICENSE', 'NOTE', 'VEHICLE', 'SERVER', 'DEVICE'];

  final tags = <String>[].obs;
  final selectedIcon = Rxn<XFile>();
  final iconBytes = Rxn<Uint8List>();

  final isLoading = false.obs;
  final isEditMode = false.obs;
  final editingItem = Rxn<VaultModel>();
  final obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    final item = Get.arguments as VaultModel?;
    if (item != null) {
      isEditMode.value = true;
      editingItem.value = item;
      _populateForm(item);
    }
  }

  void _populateForm(VaultModel i) {
    titleController.text = i.title ?? '';
    emailController.text = i.email ?? '';
    usernameController.text = i.username ?? '';
    passwordController.text = i.password ?? '';
    websiteController.text = i.website ?? '';
    phoneController.text = i.phone ?? '';
    notesController.text = i.notes ?? '';
    selectedCategory.value = i.category ?? 'PASSWORD';
    if (i.tags != null) tags.value = List<String>.from(i.tags!);
  }

  void addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
      tagController.clear();
    }
  }

  void removeTag(String tag) => tags.remove(tag);

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

  Future<void> saveItem() async {
    if (titleController.text.isEmpty) {
      ShowToastDialog.showError('Title is required');
      return;
    }

    isLoading.value = true;
    try {
      String? iconUrl = editingItem.value?.iconUrl;
      if (selectedIcon.value != null) {
        final ownerId = MahekConstant.ownerModel?.id ?? 'unknown';
        iconUrl = await ImageKitAPI.uploadImage(imageFile: selectedIcon.value!, folderName: 'vault/$ownerId');
      }

      final item = VaultModel(
        id: editingItem.value?.id ?? MahekConstant.getUuid(),
        ownerId: MahekConstant.ownerModel?.id,
        title: titleController.text.trim(),
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        website: websiteController.text.trim(),
        phone: phoneController.text.trim(),
        category: selectedCategory.value,
        tags: tags.toList(),
        notes: notesController.text.trim(),
        iconUrl: iconUrl,
        isFavorite: editingItem.value?.isFavorite ?? false,
        isPinned: editingItem.value?.isPinned ?? false,
        isHidden: editingItem.value?.isHidden ?? false,
        createdAt: editingItem.value?.createdAt,
        updatedAt: DateTime.now(),
      );

      bool success = isEditMode.value
          ? await VaultFirestoreUtils.updateVaultItem(item)
          : await VaultFirestoreUtils.addVaultItem(item);

      if (success) {
        ShowToastDialog.showSuccess(isEditMode.value ? 'Item updated!' : 'Item added!');
        Get.back(result: true);
      } else {
        ShowToastDialog.showError('Failed to save');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    websiteController.dispose();
    phoneController.dispose();
    notesController.dispose();
    tagController.dispose();
    super.onClose();
  }
}
