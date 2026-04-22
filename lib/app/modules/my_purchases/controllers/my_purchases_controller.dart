// lib/app/modules/my_purchases/controllers/my_purchases_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/category_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/models/purchase_model.dart';
import 'package:maheksync/app/utils/category_firestore_utils.dart';
import 'package:maheksync/app/utils/payment_method_firestore_utils.dart';
import 'package:maheksync/app/utils/purchase_firestore_utils.dart';
import '../../../routes/app_pages.dart';

class MyPurchasesController extends GetxController {
  final purchases = <PurchaseModel>[].obs;
  final filteredPurchases = <PurchaseModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  final isGridView = true.obs;
  final selectedDateRange = Rxn<DateTimeRange>();


  // Filters
  final categories = <CategoryModel>[].obs;
  final paymentMethods = <PaymentMethodModel>[].obs;
  final selectedCategory = Rxn<CategoryModel>();
  final selectedPaymentMethod = Rxn<PaymentMethodModel>();
  final selectedStatus = 'ALL'.obs;

  final statusOptions = ['ALL', 'DELIVERED', 'IN TRANSIT', 'PRE-ORDER'];

  String? get ownerId => MahekConstant.ownerModel?.id;

  // Computed stats
  double get totalPortfolioValue => filteredPurchases.fold(0.0, (sum, p) => sum + (p.price ?? 0.0) * (p.units ?? 1));

  int get totalItems => filteredPurchases.fold(0, (sum, p) => sum + (p.units ?? 1));

  int get activeOrders => filteredPurchases.where((p) => p.status == 'IN TRANSIT').length;

  double get growthRate => 14.2; // Placeholder

  Map<String, int> get categoryItemCount {
    final Map<String, int> counts = {};
    for (var purchase in filteredPurchases) {
      final category = purchase.category ?? 'Uncategorized';
      counts[category] = (counts[category] ?? 0) + (purchase.units ?? 1);
    }
    return counts;
  }

  List<PurchaseModel> get latestPurchases {
    return filteredPurchases.take(4).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadPaymentMethods();
    loadPurchases();
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

  void loadPurchases() {
    if (ownerId == null) return;

    PurchaseFirestoreUtils.getUserPurchases(ownerId!).listen((purchaseList) {
      purchases.value = purchaseList;
      _applyFilters();
      isLoading.value = false;
    });
  }

  void _applyFilters() {
    var result = purchases.toList();

    if (searchQuery.isNotEmpty) {
      result = result.where((p) {
        return (p.assetName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (p.brand ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (p.category ?? '').toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    if (selectedCategory.value != null) {
      result = result.where((p) => p.category == selectedCategory.value!.name).toList();
    }

    if (selectedPaymentMethod.value != null) {
      result = result.where((p) => p.paymentMethod == selectedPaymentMethod.value!.pName).toList();
    }

    if (selectedStatus.value != 'ALL') {
      result = result.where((p) => p.status == selectedStatus.value).toList();
    }

    if (selectedDateRange.value != null) {
      result = result.where((p) {
        if (p.purchaseDate == null) return false;
        return p.purchaseDate!.isAfter(selectedDateRange.value!.start) &&
            p.purchaseDate!.isBefore(selectedDateRange.value!.end.add(const Duration(days: 1)));
      }).toList();
    }

    filteredPurchases.value = result;
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

  void filterByStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = null;
    selectedPaymentMethod.value = null;
    selectedStatus.value = 'ALL';
    selectedDateRange.value = null;
    _applyFilters();
  }

  Future<void> refreshPurchases() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    loadPurchases();
  }

  void goToAddPurchase() {
    Get.toNamed(Routes.ADD_EDIT_PURCHASE);
  }

  void goToEditPurchase(PurchaseModel purchase) {
    Get.toNamed(Routes.ADD_EDIT_PURCHASE, arguments: purchase);
  }

  Future<void> deletePurchase(PurchaseModel purchase) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Purchase'),
        content: Text('Are you sure you want to delete "${purchase.assetName}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (purchase.id == null) return;

    final success = await PurchaseFirestoreUtils.deletePurchase(purchase.id!);
    if (success) {
      Get.snackbar('Success', 'Purchase deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    }
  }
  void filterByDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
    _applyFilters();
  }

}