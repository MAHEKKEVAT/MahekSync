import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/personal_task_model.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/firestore_utills/personal_task_firestore_utils.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:solar_icons/solar_icons.dart';

class PersonalTasksController extends GetxController {
  final tasks = <PersonalTaskModel>[].obs;
  final filteredTasks = <PersonalTaskModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final selectedPriority = 'ALL'.obs;
  final selectedStatus = 'ALL'.obs;
  final selectedCategory = 'ALL'.obs;
  final isGridView = true.obs;

  final priorities = ['ALL', 'HIGH', 'MEDIUM', 'LOW'];
  final statuses = ['ALL', 'PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'];
  final categories = [
    'ALL',
    'GENERAL',
    'WORK',
    'PERSONAL',
    'HEALTH',
    'FINANCE',
    'EDUCATION',
    'OTHER',
  ];

  String? get ownerId => MahekConstant.ownerModel?.id;

  int get totalTasks => tasks.length;

  int get completedCount => tasks.where((t) => t.isCompleted == true).length;

  int get pendingCount => tasks.where((t) => t.status == 'PENDING').length;

  int get inProgressCount =>
      tasks.where((t) => t.status == 'IN_PROGRESS').length;

  int get overdueCount => tasks.where((t) => t.isOverdue).length;

  int get pinnedCount => tasks.where((t) => t.isPinned == true).length;

  double get completionRate =>
      tasks.isEmpty ? 0 : (completedCount / totalTasks * 100);

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  // ✅ AFTER:
  void loadTasks() {
    if (ownerId == null) {
      isLoading.value = false;
      return;
    }
    PersonalTaskFirestoreUtils.getUserTasks(ownerId!).listen(
      (list) {
        tasks.value = list;
        _applyFilters();
        isLoading.value = false;
      },
      onError: (e) {
        debugPrint('Error loading tasks: $e');
        isLoading.value = false;
      },
    );
  }

  void _applyFilters() {
    var result = tasks.toList();
    if (searchQuery.isNotEmpty) {
      result = result
          .where(
            (t) =>
                (t.title ?? '').toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                (t.description ?? '').toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                (t.notes ?? '').toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
          )
          .toList();
    }
    if (selectedPriority.value != 'ALL') {
      result = result
          .where((t) => t.priority == selectedPriority.value)
          .toList();
    }
    if (selectedStatus.value != 'ALL') {
      result = result.where((t) => t.status == selectedStatus.value).toList();
    }
    if (selectedCategory.value != 'ALL') {
      result = result
          .where((t) => t.category == selectedCategory.value)
          .toList();
    }
    filteredTasks.value = result;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByPriority(String priority) {
    selectedPriority.value = priority;
    _applyFilters();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  Future<void> toggleTask(PersonalTaskModel task) async {
    await PersonalTaskFirestoreUtils.toggleTask(task);
  }

  Future<void> pinTask(PersonalTaskModel task) async {
    await PersonalTaskFirestoreUtils.pinTask(task);
  }

  Future<void> deleteTask(PersonalTaskModel task) async {
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppThemeData.danger300.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  SolarIconsOutline.trashBin2,
                  color: AppThemeData.danger300,
                  size: 28,
                ),
              ),
              spaceH(height: 16),
              const Text(
                'Delete Task',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              spaceH(height: 8),
              Text(
                'Delete "${task.title}"?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              spaceH(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  spaceW(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeData.danger300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && task.id != null) {
      await PersonalTaskFirestoreUtils.deleteTask(task.id!);
    }
  }

  void goToAdd() => Get.toNamed(Routes.PERSONAL_TASK_CRUD);

  void goToEdit(PersonalTaskModel task) =>
      Get.toNamed(Routes.PERSONAL_TASK_CRUD, arguments: task);
}
