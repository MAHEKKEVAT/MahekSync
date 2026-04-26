// lib/app/modules/reminder/controllers/reminder_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/reminder_model.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/reminder_firestore_utils.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';

class ReminderController extends GetxController {
  final reminders = <ReminderModel>[].obs;
  final filteredReminders = <ReminderModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final isGridView = true.obs;
  final selectedImportance = 'ALL'.obs;

  final importances = ['ALL', 'HIGH', 'MEDIUM', 'LOW'];

  String? get ownerId => MahekConstant.ownerModel?.id;

  int get activeCount => reminders.where((r) => r.isActive == true).length;
  int get highCount => reminders.where((r) => r.importance == 'HIGH' && r.isActive == true).length;
  int get expiredCount => reminders.where((r) => r.isExpired).length;

  @override
  void onInit() {
    super.onInit();
    loadReminders();
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
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByImportance(String importance) {
    selectedImportance.value = importance;
    _applyFilters();
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
              const Text('Delete Reminder', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              spaceH(height: 8),
              Text('Delete "${reminder.name}"?', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(result: false), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Cancel', style: TextStyle(color: Colors.white70)))),
                  spaceW(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () => Get.back(result: true), style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.danger300, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))),
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