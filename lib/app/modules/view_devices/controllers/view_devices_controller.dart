// lib/app/modules/view_devices/controllers/view_devices_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/device_firestore_utils.dart';
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
      final success = await DeviceFirestoreUtils.deleteDevice(deviceValue!.id!);
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
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Device'),
        content: Text('Are you sure you want to delete "${deviceValue?.deviceName}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteDevice();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
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
    if (deviceValue?.warrantyEndDate == null) return Colors.grey;
    return deviceValue!.isWarrantyExpired ? const Color(0xFFEF4444) : const Color(0xFF10B981);
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