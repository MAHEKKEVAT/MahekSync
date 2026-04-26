// lib/app/modules/subscription/controllers/subscription_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/subscription_model.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/subscription_firestore_utils.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import '../../../routes/app_pages.dart';

class SubscriptionController extends GetxController {
  final subscriptions = <SubscriptionModel>[].obs;
  final filteredSubscriptions = <SubscriptionModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final isGridView = true.obs;
  final selectedCategory = 'ALL'.obs;
  final selectedCategories = <String>[].obs;

  final categories = ['ALL', 'ENTERTAINMENT', 'UTILITIES', 'PRODUCTIVITY', 'CLOUD', 'MUSIC', 'VIDEO', 'OTHER'];

  String? get ownerId => MahekConstant.ownerModel?.id;

  double get totalMonthlyCost => subscriptions.where((s) => s.status == 'ACTIVE').fold(0.0, (sum, s) => sum + (s.price ?? 0));
  double get yearlyProjectedCost => totalMonthlyCost * 12;
  int get activeCount => subscriptions.where((s) => s.status == 'ACTIVE').length;
  int get expiringSoonCount => subscriptions.where((s) => s.isExpiringSoon && s.status == 'ACTIVE').length;

  @override
  void onInit() {
    super.onInit();
    loadSubscriptions();
  }

  void loadSubscriptions() {
    if (ownerId == null) return;
    SubscriptionFirestoreUtils.getUserSubscriptions(ownerId!).listen((list) {
      subscriptions.value = list;
      _applyFilters();
      isLoading.value = false;
    });
  }

  void _applyFilters() {
    var result = subscriptions.toList();
    if (searchQuery.isNotEmpty) {
      result = result.where((s) => (s.name ?? '').toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    if (selectedCategories.isNotEmpty) {
      result = result.where((s) => selectedCategories.contains(s.category)).toList();
    }
    filteredSubscriptions.value = result;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    _applyFilters();
  }

  Future<void> deleteSubscription(SubscriptionModel sub) async {
    final confirmed = await _showDeleteDialog(sub);
    if (confirmed == true && sub.id != null) {
      await SubscriptionFirestoreUtils.deleteSubscription(sub.id!);
      Get.snackbar('Success', 'Subscription deleted', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppThemeData.success400, colorText: Colors.white, margin: const EdgeInsets.all(16), borderRadius: 12);
    }
  }

  Future<bool> renewSubscriptionWithDate(SubscriptionModel sub, DateTime newExpiryDate) async {
    return await SubscriptionFirestoreUtils.renewSubscriptionWithDate(sub, newExpiryDate);
  }

  Future<bool?> _showDeleteDialog(SubscriptionModel sub) {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1C1F26),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: AppThemeData.danger300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete_outline, color: AppThemeData.danger300, size: 28)),
              spaceH(height: 16),
              const Text('Delete Subscription', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              spaceH(height: 8),
              Text('Are you sure you want to delete "${sub.name}"?', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14), textAlign: TextAlign.center),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(result: false), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: Colors.white.withValues(alpha: 0.2))), child: const Text('Cancel', style: TextStyle(color: Colors.white70)))),
                  spaceW(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () => Get.back(result: true), style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.danger300, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void goToAdd() => Get.toNamed(Routes.SUBSCRIPTION_CRUD);
  void goToEdit(SubscriptionModel sub) => Get.toNamed(Routes.SUBSCRIPTION_CRUD, arguments: sub);
  void goToDetails(SubscriptionModel sub) => Get.toNamed(Routes.SUBSCRIPTION_DETAILS, arguments: sub);
}