import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/firestore_utills/policy_settings_firestore_utils.dart';

class PolicySettingsController extends GetxController {
  final termsController = TextEditingController();
  final privacyController = TextEditingController();
  final aboutController = TextEditingController();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final isExpanded = [true, false, false].obs;

  @override
  void onInit() {
    super.onInit();
    loadPolicies();
  }

  Future<void> loadPolicies() async {
    isLoading.value = true;
    final policies = await PolicySettingsFirestoreUtils.getPolicies();
    termsController.text = policies['termsAndConditions'] ?? '';
    privacyController.text = policies['privacyPolicy'] ?? '';
    aboutController.text = policies['aboutApp'] ?? '';
    isLoading.value = false;
  }

  void toggleSection(int index) {
    isExpanded[index] = !isExpanded[index];
  }

  Future<void> savePolicies() async {
    isSaving.value = true;
    final success = await PolicySettingsFirestoreUtils.savePolicies(
      termsAndConditions: termsController.text.trim(),
      privacyPolicy: privacyController.text.trim(),
      aboutApp: aboutController.text.trim(),
    );
    isSaving.value = false;

    if (success) {
      ShowToastDialog.showSuccess('Policies saved successfully!');
    } else {
      ShowToastDialog.showError('Failed to save policies');
    }
  }

  @override
  void onClose() {
    termsController.dispose();
    privacyController.dispose();
    aboutController.dispose();
    super.onClose();
  }
}
