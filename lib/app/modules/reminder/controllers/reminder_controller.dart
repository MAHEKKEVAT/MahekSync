// lib/app/modules/reminder/controllers/reminder_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import 'package:maheksync/app/firestore_utills/reminder_firestore_utils.dart';
import 'package:maheksync/app/models/reminder_model.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class ReminderController extends GetxController {
  final reminders = <ReminderModel>[].obs;
  final filteredReminders = <ReminderModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final isGridView = true.obs;
  final selectedImportance = 'ALL'.obs;
  final selectedSortOption = 'Expiry: Soonest'.obs;
  final searchController = TextEditingController();

  final importances = ['ALL', 'HIGH', 'MEDIUM', 'LOW'];
  final sortOptions = ['Expiry: Soonest', 'Expiry: Latest', 'Importance: High', 'Importance: Low', 'Name: A to Z', 'Recently Added'];

  String? get ownerId => MahekConstant.ownerModel?.id;

  int get activeCount => reminders.where((r) => r.isActive == true).length;
  int get highCount => reminders.where((r) => r.importance == 'HIGH' && r.isActive == true).length;
  int get expiredCount => reminders.where((r) => r.isExpired).length;

  @override
  void onInit() {
    super.onInit();
    loadReminders();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void loadReminders() {
    if (ownerId == null) return;
    ReminderFirestoreUtils.getUserReminders(ownerId!).listen((list) {
      reminders.value = list;
      _applyFilters();
      isLoading.value = false;
    });
  }

  void _applyFilters() {
    var result = reminders.toList();
    if (searchQuery.isNotEmpty) {
      result = result.where((r) =>
      (r.name ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (r.description ?? '').toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    if (selectedImportance.value != 'ALL') {
      result = result.where((r) => r.importance == selectedImportance.value).toList();
    }
    filteredReminders.value = result;
    _applySort();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByImportance(String importance) {
    selectedImportance.value = importance;
    _applyFilters();
  }

  void sortBy(String option) {
    selectedSortOption.value = option;
    _applySort();
  }

  void _applySort() {
    final list = filteredReminders.toList();
    switch (selectedSortOption.value) {
      case 'Expiry: Soonest':
        list.sort((a, b) {
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
      case 'Expiry: Latest':
        list.sort((a, b) {
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return b.expiryDate!.compareTo(a.expiryDate!);
        });
        break;
      case 'Importance: High':
        final order = {'HIGH': 0, 'MEDIUM': 1, 'LOW': 2};
        list.sort((a, b) => (order[a.importance] ?? 3).compareTo(order[b.importance] ?? 3));
        break;
      case 'Importance: Low':
        final order = {'LOW': 0, 'MEDIUM': 1, 'HIGH': 2};
        list.sort((a, b) => (order[a.importance] ?? 3).compareTo(order[b.importance] ?? 3));
        break;
      case 'Name: A to Z':
        list.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
      case 'Recently Added':
        list.sort((a, b) => (b.createdAt?.toDate() ?? DateTime(0)).compareTo(a.createdAt?.toDate() ?? DateTime(0)));
        break;
    }
    filteredReminders.value = list;
  }

  Future<void> deleteReminder(ReminderModel reminder) async {
    final confirmed = await Get.dialog<bool>(
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
                decoration: BoxDecoration(color: AppThemeData.danger300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.delete_outline, color: AppThemeData.danger300, size: 28),
              ),
              spaceH(height: 16),
              TextCustom(title: 'Delete Reminder', fontSize: 18, fontFamily: FontFamily.bold, color: AppThemeData.primaryWhite),
              spaceH(height: 8),
              TextCustom(title: 'Delete "${reminder.name}"?', fontSize: 14, color: AppThemeData.primaryWhite.withValues(alpha: 0.6)),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(child: RoundShapeButton(title: 'Cancel', buttonColor: AppThemeData.grey10, buttonTextColor: AppThemeData.grey4, borderColor: AppThemeData.grey7, onTap: () => Get.back(result: false), height: 48, borderRadius: 12)),
                  spaceW(width: 12),
                  Expanded(child: RoundShapeButton(title: 'Delete', buttonColor: AppThemeData.danger300, buttonTextColor: AppThemeData.primaryWhite, onTap: () => Get.back(result: true), height: 48, borderRadius: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && reminder.id != null) {
      await ReminderFirestoreUtils.deleteReminder(reminder.id!);
    }
  }

  Future<void> toggleReminder(ReminderModel reminder) async {
    await ReminderFirestoreUtils.toggleReminder(reminder);
  }

  void goToAdd() => Get.toNamed(Routes.REMINDER_CRUD);
  void goToEdit(ReminderModel reminder) => Get.toNamed(Routes.REMINDER_CRUD, arguments: reminder);
}