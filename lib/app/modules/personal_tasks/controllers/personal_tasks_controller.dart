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

  final activeTab = 'ALL'.obs;
  final sortBy = 'DATE'.obs;
  final sortAscending = true.obs;

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

  double get dailyProgress =>
      tasks.isEmpty ? 0 : (completedCount / totalTasks * 100);

  int get estimatedFocusMinutes =>
      tasks.where((t) => t.status != 'COMPLETED').length * 25;

  List<PersonalTaskModel> get upcomingTasks {
    final upcoming = tasks
        .where((t) =>
            (t.isOverdue || t.isDueSoon) &&
            t.status != 'COMPLETED')
        .toList()
      ..sort((a, b) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    return upcoming.take(5).toList();
  }

  Map<String, int> get tasksByCategory {
    final map = <String, int>{};
    for (final t in tasks) {
      final cat = t.category ?? 'GENERAL';
      map[cat] = (map[cat] ?? 0) + 1;
    }
    return map;
  }

  List<String> get aiRecommendations {
    final recs = <String>[];
    if (overdueCount > 0) {
      final overdueTask = tasks.firstWhere(
        (t) => t.isOverdue,
        orElse: () => tasks.first,
      );
      recs.add('Finish "${overdueTask.title}"');
    }
    final pending = tasks.where((t) => t.status == 'PENDING').toList();
    if (pending.isNotEmpty) {
      recs.add('Work on "${pending.first.title}"');
    }
    if (recs.isEmpty) {
      recs.add('All caught up! Great work.');
    }
    return recs;
  }

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

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
      final q = searchQuery.value.toLowerCase();
      result = result
          .where((t) =>
              (t.title ?? '').toLowerCase().contains(q) ||
              (t.description ?? '').toLowerCase().contains(q) ||
              (t.notes ?? '').toLowerCase().contains(q))
          .toList();
    }

    switch (activeTab.value) {
      case 'HIGH':
        result = result.where((t) => t.priority == 'HIGH').toList();
        break;
      case 'PENDING':
        result = result.where((t) => t.status == 'PENDING').toList();
        break;
      case 'COMPLETED':
        result = result.where((t) => t.status == 'COMPLETED').toList();
        break;
      case 'OVERDUE':
        result = result.where((t) => t.isOverdue).toList();
        break;
    }

    if (selectedCategory.value != 'ALL') {
      result = result
          .where((t) => t.category == selectedCategory.value)
          .toList();
    }

    switch (sortBy.value) {
      case 'DATE':
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return sortAscending.value
              ? a.dueDate!.compareTo(b.dueDate!)
              : b.dueDate!.compareTo(a.dueDate!);
        });
        break;
      case 'PRIORITY':
        final order = {'HIGH': 0, 'MEDIUM': 1, 'LOW': 2};
        result.sort((a, b) {
          final ai = order[a.priority] ?? 1;
          final bi = order[b.priority] ?? 1;
          return sortAscending.value
              ? ai.compareTo(bi)
              : bi.compareTo(ai);
        });
        break;
      case 'NAME':
        result.sort((a, b) {
          final cmp = (a.title ?? '').compareTo(b.title ?? '');
          return sortAscending.value ? cmp : -cmp;
        });
        break;
    }

    final pinned = result.where((t) => t.isPinned == true).toList();
    final unpinned = result.where((t) => t.isPinned != true).toList();
    result = [...pinned, ...unpinned];

    filteredTasks.value = result;
  }

  void setActiveTab(String tab) {
    activeTab.value = tab;
    _applyFilters();
  }

  void cycleSort() {
    final modes = ['DATE', 'PRIORITY', 'NAME'];
    final idx = modes.indexOf(sortBy.value);
    if (idx < modes.length - 1) {
      sortBy.value = modes[idx + 1];
    } else {
      sortBy.value = modes[0];
      sortAscending.value = !sortAscending.value;
    }
    _applyFilters();
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
                  color: Colors.white.withValues(alpha: 0.6),
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
