// lib/app/modules/my_devices/controllers/my_devices_controller.dart
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/utils/device_firestore_utils.dart';

import '../../add_new_devices/controllers/add_new_devices_controller.dart';
import '../../add_new_devices/views/add_new_devices_view.dart';

class MyDevicesController extends GetxController {
  final devices = <DeviceModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;


  String? get ownerId => MahekConstant.ownerModel?.id;

  @override
  void onInit() {
    super.onInit();
    loadDevices();
  }

  void loadDevices() {
    if (ownerId == null) return;

    // Use DeviceFirestoreUtils instead of DeviceService
    DeviceFirestoreUtils.getUserDevices(ownerId!).listen((deviceList) {
      devices.value = deviceList;
      isLoading.value = false;
    });
  }

  List<DeviceModel> get filteredDevices {
    if (searchQuery.isEmpty) return devices;
    return devices.where((device) {
      return (device.deviceName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (device.brandName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (device.storeName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (device.category ?? '').toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> refreshDevices() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    loadDevices();
  }

  void openAddDevicePanel() async {
    Get.put(AddNewDevicesController());

    final result = await Get.to(() => const AddNewDevicesView());
    if (result == true) {
      refreshDevices();
    }
  }


  void onDeviceAdded() {
    refreshDevices();
  }
}