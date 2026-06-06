import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/fire_store_utils.dart';

class AdminProfileController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final isSaving = false.obs;
  final isUploadingImage = false.obs;
  final Rx<XFile?> selectedImageFile = Rx<XFile?>(null);
  final RxString previewImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final user = MahekConstant.ownerModel;
    if (user != null) {
      fullNameController.text = user.fullName ?? '';
      emailController.text = user.email ?? '';
      phoneController.text = user.phoneNumber ?? '';
    }
  }

  String? get currentProfilePicUrl => MahekConstant.ownerModel?.profilePic ?? '';

  Future<void> pickProfileImage() async {
    try {
      final XFile? picked = await ImageKitAPI.pickImage();
      if (picked != null) {
        selectedImageFile.value = picked;
        previewImagePath.value = picked.path;
      }
    } catch (e) {
      ShowToastDialog.showError('Failed to pick image');
    }
  }

  void clearSelectedImage() {
    selectedImageFile.value = null;
    previewImagePath.value = '';
  }

  Future<String?> uploadProfileImageToImageKit() async {
    final file = selectedImageFile.value;
    if (file == null) return null;

    isUploadingImage.value = true;
    try {
      final url = await ImageKitAPI.uploadProfileImage(imageFile: file);
      if (url == null || url.isEmpty) {
        ShowToastDialog.showError('Image upload failed. Please try again.');
        return null;
      }
      return url;
    } catch (e) {
      ShowToastDialog.showError('Image upload error: $e');
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> saveProfileChanges() async {
    if (isSaving.value) return;

    final fullName = fullNameController.text.trim();
    if (fullName.isEmpty) {
      ShowToastDialog.showError('Full name is required');
      return;
    }

    isSaving.value = true;
    try {
      String? newImageUrl;

      if (selectedImageFile.value != null) {
        newImageUrl = await uploadProfileImageToImageKit();
        if (newImageUrl == null && selectedImageFile.value != null) {
          isSaving.value = false;
          return;
        }
      }

      final user = MahekConstant.ownerModel;
      if (user == null) {
        ShowToastDialog.showError('User data not found');
        return;
      }

      user.fullName = fullName;
      user.email = emailController.text.trim();
      user.phoneNumber = phoneController.text.trim();

      if (newImageUrl != null) {
        user.profilePic = newImageUrl;
      }

      final success = await FireStoreUtils.updateOwner(user);
      if (success) {
        clearSelectedImage();
        ShowToastDialog.showSuccess('Profile updated successfully');
      } else {
        ShowToastDialog.showError('Failed to save profile');
      }
    } catch (e) {
      ShowToastDialog.showError('Error saving profile: $e');
    } finally {
      isSaving.value = false;
    }
  }

  bool get isLoading => isSaving.value || isUploadingImage.value;

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}