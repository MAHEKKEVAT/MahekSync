// lib/app/modules/view_devices/controllers/view_devices_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import 'package:maheksync/app/firestore_utills/device_firestore_utils.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../constant/show_toast.dart';

class ViewDevicesController extends GetxController {
  final isLoading = false.obs;
  final currentImageIndex = 0.obs;
  final device = Rxn<DeviceModel>();

  @override
  void onInit() {
    super.onInit();
    device.value = Get.arguments as DeviceModel?;

    // If no device was passed, go back
    if (device.value == null) {
      Future.delayed(Duration.zero, () {
        ShowToastDialog.showError('Device not found');
        Get.offNamed(Routes.MY_DEVICES);
      });
    }
  }

  void changeImage(int index) {
    final deviceValue = device.value;
    if (deviceValue != null &&
        index >= 0 &&
        index < (deviceValue.deviceImageUrls?.length ?? 0)) {
      currentImageIndex.value = index;
    }
  }

  Future<void> deleteDevice() async {
    final deviceValue = device.value;
    if (deviceValue?.id == null) {
      ShowToastDialog.showError('Invalid device');
      return;
    }

    isLoading.value = true;
    try {
      final success = await DeviceFirestoreUtils.deleteDevice(deviceValue!);
      if (success) {
        ShowToastDialog.showSuccess('Device deleted successfully!');
        Get.back(result: true);
      } else {
        ShowToastDialog.showError('Failed to delete device');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void confirmDelete() {
    final deviceValue = device.value;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppThemeData.primaryBlack,
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
                child: const Icon(Icons.delete_outline, color: AppThemeData.danger300, size: 28),
              ),
              spaceH(height: 16),
              TextCustom(
                title: 'Delete Device',
                fontSize: 18,
                fontFamily: FontFamily.bold,
                color: AppThemeData.primaryWhite,
              ),
              spaceH(height: 8),
              TextCustom(
                title: 'Delete "${deviceValue?.deviceName}"?',
                fontSize: 14,
                color: AppThemeData.primaryWhite.withValues(alpha: 0.6),
              ),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(
                    child: RoundShapeButton(
                      title: 'Cancel',
                      buttonColor: AppThemeData.grey10,
                      buttonTextColor: AppThemeData.grey4,
                      borderColor: AppThemeData.grey7,
                      onTap: () => Get.back(),
                      height: 48,
                      borderRadius: 12,
                    ),
                  ),
                  spaceW(width: 12),
                  Expanded(
                    child: RoundShapeButton(
                      title: 'Delete',
                      buttonColor: AppThemeData.danger300,
                      buttonTextColor: AppThemeData.primaryWhite,
                      onTap: () {
                        Get.back();
                        deleteDevice();
                      },
                      height: 48,
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToEdit() {
    Get.back();
    Get.toNamed('/add-new-devices', arguments: device.value);
  }

  String get paymentMethodDisplay {
    final deviceValue = device.value;
    if (deviceValue?.paymentMethod == null || deviceValue!.paymentMethod!.isEmpty) {
      return 'Not specified';
    }
    return deviceValue.paymentMethod!;
  }

  int get daysRemaining {
    final deviceValue = device.value;
    if (deviceValue?.warrantyEndDate == null) return 0;
    return deviceValue!.warrantyEndDate!.difference(DateTime.now()).inDays;
  }

  String get warrantyStatus {
    final deviceValue = device.value;
    if (deviceValue?.warrantyEndDate == null) return 'No Warranty';
    return deviceValue!.isWarrantyExpired ? 'Expired' : 'Active';
  }

  Color get warrantyStatusColor {
    final deviceValue = device.value;
    if (deviceValue?.warrantyEndDate == null) return AppThemeData.grey5;
    return deviceValue!.isWarrantyExpired ? AppThemeData.danger300 : AppThemeData.success400;
  }

  List<String> get allImages {
    return device.value?.deviceImageUrls ?? [];
  }

  bool get hasImages {
    final deviceValue = device.value;
    return deviceValue?.deviceImageUrls != null && deviceValue!.deviceImageUrls!.isNotEmpty;
  }

  String get currentImageUrl {
    if (!hasImages) return '';
    return device.value!.deviceImageUrls![currentImageIndex.value];
  }
}