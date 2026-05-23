import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/models/sentinel_model.dart';
import 'package:maheksync/app/utils/sentinel_firestore_utils.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:solar_icons/solar_icons.dart';

class SentinelController extends GetxController {
  final isLoading = true.obs;
  final isPasswordSet = false.obs;
  final isVerified = false.obs;
  final isLocked = false.obs;
  final failedAttempts = 0.obs;
  final remainingLockTime = Rxn<Duration>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final currentPasswordController = TextEditingController();

  SentinelModel? _sentinelData;

  String? get ownerId => MahekConstant.ownerModel?.id;

  @override
  void onInit() {
    super.onInit();
    loadSentinelStatus();
  }

  void loadSentinelStatus() async {
    if (ownerId == null) {
      isLoading.value = false;
      return;
    }
    try {
      _sentinelData = await SentinelFirestoreUtils.getCurrentSentinelAccess(ownerId!);
      if (_sentinelData != null) {
        isPasswordSet.value = _sentinelData!.isPasswordSet ?? false;
        failedAttempts.value = _sentinelData!.failedAttempts ?? 0;
        isLocked.value = _sentinelData!.isLocked;
        remainingLockTime.value = _sentinelData!.remainingLockTime;
      }
    } catch (e) {
      debugPrint('Error loading sentinel status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new master password
  Future<void> createMasterPassword() async {
    if (ownerId == null) return;

    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (password.isEmpty || password.length < 6) {
      ShowToastDialog.showError('Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      ShowToastDialog.showError('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      final success = await SentinelFirestoreUtils.createMasterPassword(
        ownerId!,
        password,
      );
      if (success) {
        isPasswordSet.value = true;
        isVerified.value = true;
        ShowToastDialog.showSuccess('Master password created!');
        passwordController.clear();
        confirmPasswordController.clear();
      } else {
        ShowToastDialog.showError('Failed to create master password');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify master password for access
  Future<bool> verifyMasterPassword() async {
    if (ownerId == null) return false;
    if (isLocked.value) {
      ShowToastDialog.showError('Access locked. Please wait.');
      return false;
    }

    final password = currentPasswordController.text.trim();
    if (password.isEmpty) {
      ShowToastDialog.showError('Enter your master password');
      return false;
    }

    try {
      final verified = await SentinelFirestoreUtils.verifyMasterPassword(ownerId!, password);
      if (verified) {
        isVerified.value = true;
        failedAttempts.value = 0;
        await SentinelFirestoreUtils.updateFailedAttempts(ownerId!, 0);
        currentPasswordController.clear();
        return true;
      } else {
        failedAttempts.value++;
        await SentinelFirestoreUtils.updateFailedAttempts(ownerId!, failedAttempts.value);

        if (failedAttempts.value >= 5) {
          await SentinelFirestoreUtils.lockAccess(ownerId!, const Duration(minutes: 5));
          isLocked.value = true;
          remainingLockTime.value = const Duration(minutes: 5);
          ShowToastDialog.showError('Too many failed attempts. Locked for 5 minutes.');
        } else {
          ShowToastDialog.showError('Incorrect password. ${5 - failedAttempts.value} attempts remaining.');
        }
        return false;
      }
    } catch (e) {
      ShowToastDialog.showError('Verification failed');
      return false;
    }
  }

  /// Re-verify for sensitive actions (like revealing vault passwords)
  Future<bool> reVerifyForSensitiveAction() async {
    if (!isPasswordSet.value) {
      // No master password set, allow access
      return true;
    }
    if (isVerified.value) {
      // Already verified in this session
      return true;
    }

    // Show verification dialog
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppThemeData.grey10,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(SolarIconsBold.shieldKeyhole, color: AppThemeData.primary50, size: 28),
              ),
              spaceH(height: 16),
              const TextCustom(title: 'Verify Identity', fontSize: 18, fontFamily: FontFamily.bold, color: Colors.white),
              spaceH(height: 8),
              TextCustom(
                title: 'Enter your master password to continue',
                fontSize: 13,
                fontFamily: FontFamily.regular,
                color: Colors.white.withValues(alpha: 0.6),
                textAlign: TextAlign.center,
              ),
              spaceH(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppThemeData.grey9,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppThemeData.grey8, width: 0.5),
                ),
                child: TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Master password',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppThemeData.primary50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(SolarIconsOutline.lockKeyhole, color: AppThemeData.primary50, size: 18),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  onSubmitted: (_) => Get.back(result: true),
                ),
              ),
              spaceH(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const TextCustom(title: 'Cancel', fontSize: 14, fontFamily: FontFamily.medium, color: Colors.white70),
                    ),
                  ),
                  spaceW(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeData.primary50,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const TextCustom(title: 'Verify', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (result == true) {
      return await verifyMasterPassword();
    }
    return false;
  }

  /// Update existing master password
  Future<void> updateMasterPassword() async {
    if (ownerId == null) return;

    final currentPwd = currentPasswordController.text.trim();
    final newPwd = passwordController.text.trim();
    final confirmPwd = confirmPasswordController.text.trim();

    if (newPwd.isEmpty || newPwd.length < 6) {
      ShowToastDialog.showError('New password must be at least 6 characters');
      return;
    }
    if (newPwd != confirmPwd) {
      ShowToastDialog.showError('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      // Verify current password first
      final isCurrentValid = await SentinelFirestoreUtils.verifyMasterPassword(ownerId!, currentPwd);
      if (!isCurrentValid) {
        ShowToastDialog.showError('Current password is incorrect');
        return;
      }

      final success = await SentinelFirestoreUtils.updateMasterPassword(ownerId!, newPwd);
      if (success) {
        ShowToastDialog.showSuccess('Master password updated!');
        currentPasswordController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
      } else {
        ShowToastDialog.showError('Failed to update password');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset master password (after confirming identity)
  Future<void> resetMasterPassword() async {
    if (ownerId == null) return;

    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppThemeData.grey10,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppThemeData.danger300.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(SolarIconsOutline.dangerTriangle, color: AppThemeData.danger300, size: 28),
              ),
              spaceH(height: 16),
              const TextCustom(title: 'Reset Password', fontSize: 18, fontFamily: FontFamily.bold, color: Colors.white),
              spaceH(height: 8),
              TextCustom(
                title: 'This will remove your master password. You\'ll need to set a new one.',
                fontSize: 13,
                fontFamily: FontFamily.regular,
                color: Colors.white.withValues(alpha: 0.6),
                textAlign: TextAlign.center,
              ),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const TextCustom(title: 'Cancel', fontSize: 14, fontFamily: FontFamily.medium, color: Colors.white70),
                    ),
                  ),
                  spaceW(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeData.danger300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const TextCustom(title: 'Reset', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      isLoading.value = true;
      try {
        final success = await SentinelFirestoreUtils.requestPasswordReset(ownerId!);
        if (success) {
          isPasswordSet.value = false;
          isVerified.value = false;
          ShowToastDialog.showSuccess('Password reset. Please set a new one.');
        } else {
          ShowToastDialog.showError('Failed to reset password');
        }
      } catch (e) {
        ShowToastDialog.showError('Error: ${e.toString()}');
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    currentPasswordController.dispose();
    super.onClose();
  }
}
