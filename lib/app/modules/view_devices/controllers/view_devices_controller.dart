// lib/app/modules/view_devices/controllers/view_devices_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/utils/device_firestore_utils.dart';
import '../../../constant/show_toast.dart';

class ViewDevicesController extends GetxController {
  DeviceModel? device;
  final isLoading = false.obs;
  final currentImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Safely get arguments
    if (Get.arguments != null) {
      device = Get.arguments as DeviceModel;
    }
  }

  void changeImage(int index) {
    currentImageIndex.value = index;
  }

  Future<void> deleteDevice() async {
    if (device?.id == null) {
      ShowToastDialog.showError('Invalid device');
      return;
    }

    isLoading.value = true;
    try {
      final success = await DeviceFirestoreUtils.deleteDevice(device!.id!);
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
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Device'),
        content: Text('Are you sure you want to delete "${device?.deviceName}"?'),
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
    // Navigate to edit screen with device data
    Get.back();
    Get.toNamed('/add-new-devices', arguments: device);
  }

  String get paymentMethodDisplay {
    if (device?.paymentMethod == null || device!.paymentMethod!.isEmpty) {
      return 'Not specified';
    }
    return device!.paymentMethod!;
  }

  int get daysRemaining {
    if (device?.warrantyEndDate == null) return 0;
    return device!.warrantyEndDate!.difference(DateTime.now()).inDays;
  }

  String get warrantyStatus {
    if (device?.warrantyEndDate == null) return 'No Warranty';
    return device!.isWarrantyExpired ? 'Expired' : 'Active';
  }

  Color get warrantyStatusColor {
    if (device?.warrantyEndDate == null) return Colors.grey;
    return device!.isWarrantyExpired ? const Color(0xFFEF4444) : const Color(0xFF10B981);
  }

  // Get all image URLs
  List<String> get allImages {
    return device?.deviceImageUrls ?? [];
  }

  // Check if device has images
  bool get hasImages {
    return device?.deviceImageUrls != null && device!.deviceImageUrls!.isNotEmpty;
  }

  // Get current image URL
  String get currentImageUrl {
    if (!hasImages) return '';
    return device!.deviceImageUrls![currentImageIndex.value];
  }
}