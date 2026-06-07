import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/services/imagekit_api.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/fire_store_utils.dart';

class AdminProfileController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final isSaving = false.obs;
  final isUploadingImage = false.obs;
  final Rx<XFile?> selectedImageFile = Rx<XFile?>(null);
  final RxString previewImagePath = ''.obs;
  final RxBool removeExistingImage = false.obs;

  bool get hasImage => previewImagePath.value.isNotEmpty ||
      (MahekConstant.ownerModel?.profilePic?.isNotEmpty ?? false);

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

  String? get currentProfilePicUrl =>
      MahekConstant.ownerModel?.profilePic ?? '';

  Future<void> pickAndCropImage() async {
    try {
      final XFile? picked = await ImageKitAPI.pickImage();
      if (picked == null) return;

      XFile? resultFile;
      try {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: picked.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 90,
          maxWidth: 800,
          maxHeight: 800,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Profile Photo',
              toolbarColor: AppThemeData.neonPurple,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              aspectRatioPresets: [CropAspectRatioPreset.square],
            ),
            IOSUiSettings(
              title: 'Crop Profile Photo',
              aspectRatioPresets: [CropAspectRatioPreset.square],
              aspectRatioLockEnabled: true,
            ),
          ],
        );
        if (croppedFile != null) {
          resultFile = XFile(croppedFile.path);
        }
      } catch (_) {
        // image_cropper not supported on this platform (e.g., desktop)
      }

      selectedImageFile.value = resultFile ?? picked;
      previewImagePath.value = selectedImageFile.value!.path;
    } catch (e) {
      ShowToastDialog.showError('Failed to pick or crop image');
    }
  }

  void clearSelectedImage() {
    selectedImageFile.value = null;
    previewImagePath.value = '';
  }

  void removeProfileImage() {
    if (selectedImageFile.value != null || previewImagePath.value.isNotEmpty) {
      clearSelectedImage();
    } else {
      removeExistingImage.value = true;
      previewImagePath.value = '';
    }
  }

  void viewFullScreenImage(BuildContext context) {
    final imageUrl = previewImagePath.value.isNotEmpty
        ? previewImagePath.value
        : currentProfilePicUrl;
    if (imageUrl == null || imageUrl.isEmpty) return;

    Get.dialog(
      Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: kIsWeb
                  ? Image.network(imageUrl, fit: BoxFit.contain)
                  : (previewImagePath.value.isNotEmpty
                      ? Image.file(File(imageUrl), fit: BoxFit.contain)
                      : Image.network(imageUrl, fit: BoxFit.contain)),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
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
      } else if (removeExistingImage.value) {
        user.profilePic = '';
        removeExistingImage.value = false;
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
