// lib/app/modules/my_devices/controllers/my_devices_controller.dart
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/utils/category_firestore_utils.dart';
import 'package:maheksync/app/utils/device_firestore_utils.dart';
import 'package:maheksync/app/utils/payment_method_firestore_utils.dart';

import '../../add_new_devices/controllers/add_new_devices_controller.dart';
import '../../add_new_devices/views/add_new_devices_view.dart';

class MyDevicesController extends GetxController {
  final devices = <DeviceModel>[].obs;
  final filteredDevices = <DeviceModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  // Filters
  final categories = <CategoryModel>[].obs;
  final paymentMethods = <PaymentMethodModel>[].obs;
  final selectedCategory = Rxn<CategoryModel>();
  final selectedPaymentMethod = Rxn<PaymentMethodModel>();

  // View toggle
  final isGridView = true.obs;

  String? get ownerId => MahekConstant.ownerModel?.id;

  // Computed stats
  double get totalPrice => filteredDevices.fold(0.0, (sum, device) => sum + (device.price ?? 0.0));

  int get totalItems => filteredDevices.length;

  Map<String, int> get categoryItemCount {
    final Map<String, int> counts = {};
    for (var device in filteredDevices) {
      final category = device.category ?? 'Uncategorized';
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadPaymentMethods();
    loadDevices();
  }

  void loadCategories() {
    CategoryFirestoreUtils.getCategories().listen((cats) {
      categories.value = cats;
    });
  }

  void loadPaymentMethods() {
    PaymentMethodFirestoreUtils.getPaymentMethods().listen((methods) {
      paymentMethods.value = methods;
    });
  }

  void loadDevices() {
    if (ownerId == null) return;

    DeviceFirestoreUtils.getUserDevices(ownerId!).listen((deviceList) {
      devices.value = deviceList;
      _applyFilters();
      isLoading.value = false;
    });
  }

  void _applyFilters() {
    var result = devices.toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      result = result.where((device) {
        return (device.deviceName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (device.brandName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (device.storeName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (device.category ?? '').toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (selectedCategory.value != null) {
      result = result.where((device) => device.category == selectedCategory.value!.name).toList();
    }

    // Apply payment method filter
    if (selectedPaymentMethod.value != null) {
      result = result.where((device) => device.paymentMethod == selectedPaymentMethod.value!.pName).toList();
    }

    filteredDevices.value = result;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByCategory(CategoryModel? category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void filterByPaymentMethod(PaymentMethodModel? method) {
    selectedPaymentMethod.value = method;
    _applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = null;
    selectedPaymentMethod.value = null;
    _applyFilters();
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

  void toggleView() {
    isGridView.value = !isGridView.value;
  }
}