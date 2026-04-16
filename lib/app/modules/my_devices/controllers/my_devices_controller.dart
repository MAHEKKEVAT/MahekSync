// lib/app/modules/my_devices/controllers/my_devices_controller.dart
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/services/device_service.dart';

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

    DeviceService.getUserDevices(ownerId!).listen((deviceList) {
      devices.value = deviceList;
      isLoading.value = false;
    });
  }

  List<DeviceModel> get filteredDevices {
    if (searchQuery.isEmpty) return devices;
    return devices.where((device) {
      return device.deviceName!.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          device.storeName!.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          device.category!.toLowerCase().contains(searchQuery.value.toLowerCase());
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

  void navigateToAddDevice() async {
    final result = await Get.toNamed('/add-new-devices');
    if (result == true) {
      refreshDevices();
    }
  }
}