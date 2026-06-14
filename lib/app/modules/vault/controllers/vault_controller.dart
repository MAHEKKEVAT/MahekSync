import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/firestore_utills/vault_firestore_utils.dart' hide debugPrint;
import 'package:maheksync/app/models/vault_model.dart';
import 'package:maheksync/app/modules/sentinel/controllers/sentinel_controller.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:solar_icons/solar_icons.dart';

class VaultController extends GetxController {
  final items = <VaultModel>[].obs;
  final filteredItems = <VaultModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'ALL'.obs;
  final isGridView = true.obs;
  final revealedFields = <String>{}.obs;

  final categories = ['ALL', 'PASSWORD', 'API_KEY', 'WIFI', 'BANK', 'EMAIL', 'SUBSCRIPTION', 'LICENSE', 'NOTE', 'VEHICLE', 'SERVER', 'DEVICE'];

  String? get ownerId => MahekConstant.ownerModel?.id;

  int get totalItems => items.length;
  int get favoriteCount => items.where((i) => i.isFavorite == true).length;
  int get pinnedCount => items.where((i) => i.isPinned == true).length;
  int get hiddenCount => items.where((i) => i.isHidden == true).length;

  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (final item in items) {
      final cat = item.category ?? 'OTHER';
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts;
  }

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  void loadItems() {
    if (ownerId == null) {
      isLoading.value = false;
      return;
    }
    VaultFirestoreUtils.getVaultItems(ownerId!).listen((list) {
      items.value = list;
      _applyFilters();
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('Error loading vault: $e');
      isLoading.value = false;
    });
  }

  void _applyFilters() {
    var result = items.toList();
    if (searchQuery.isNotEmpty) {
      result = result.where((i) =>
          (i.title ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (i.username ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (i.email ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (i.website ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (i.notes ?? '').toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    if (selectedCategory.value != 'ALL') {
      result = result.where((i) => i.category == selectedCategory.value).toList();
    }
    filteredItems.value = result;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  Future<void> toggleFavorite(VaultModel item) async {
    await VaultFirestoreUtils.toggleFavorite(item);
  }

  Future<void> togglePin(VaultModel item) async {
    await VaultFirestoreUtils.togglePin(item);
  }

  Future<void> toggleHidden(VaultModel item) async {
    await VaultFirestoreUtils.toggleHidden(item);
  }

  Future<void> deleteItem(VaultModel item) async {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: AppThemeData.danger300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(SolarIconsOutline.trashBin2, color: AppThemeData.danger300, size: 28),
              ),
              spaceH(height: 16),
              Text('Delete Item', style: TextStyle(color: isDark ? Colors.white : AppThemeData.grey10, fontSize: 18, fontWeight: FontWeight.w700)),
              spaceH(height: 8),
              Text('Delete "${item.title}"?', style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : AppThemeData.grey6, fontSize: 14)),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(result: false), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : AppThemeData.grey6)))),
                  spaceW(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () => Get.back(result: true), style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.danger300, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && item.id != null) {
      await VaultFirestoreUtils.deleteVaultItem(item.id!);
    }
  }

  void copyToClipboard(String value, {String label = 'Value'}) {
    Clipboard.setData(ClipboardData(text: value));
    ShowToastDialog.showSuccess('$label copied!');
  }

  Future<void> revealField(String fieldId) async {
    if (revealedFields.contains(fieldId)) {
      revealedFields.remove(fieldId);
      return;
    }
    if (Get.isRegistered<SentinelController>()) {
      try {
        final sentinelCtrl = Get.find<SentinelController>();
        final verified = await sentinelCtrl.reVerifyForSensitiveAction();
        if (verified) {
          revealedFields.add(fieldId);
        } else {
          ShowToastDialog.showError('Verification failed');
        }
      } catch (e) {
        // If SentinelController fails, allow reveal anyway
        debugPrint('Sentinel verification error: $e');
        revealedFields.add(fieldId);
      }
    } else {
      // No SentinelController registered, allow without verification
      revealedFields.add(fieldId);
    }
  }

  void goToAdd() => Get.toNamed(Routes.VAULT_CRUD);
  void goToEdit(VaultModel item) => Get.toNamed(Routes.VAULT_CRUD, arguments: item);
}
