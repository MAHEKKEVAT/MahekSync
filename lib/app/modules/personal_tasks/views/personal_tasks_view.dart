import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../models/personal_task_model.dart';
import '../controllers/personal_tasks_controller.dart';

class PersonalTasksView extends GetView<PersonalTasksController> {
  const PersonalTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveWidget.isMobile(context);

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: MahekLoader(
              showBackgroundOverlay: true,
              message: 'Loading Tasks...',
            ),
          );
        }
        return _buildContent(context, isDark, isMobile);
      }),
      floatingActionButton: _buildFloatingButton(isDark),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          spaceH(height: 18),
          _buildStats(isDark),
          spaceH(height: 18),
          _buildSearchBar(isDark),
          spaceH(height: 14),
          _buildFilters(isDark),
          spaceH(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.filteredTasks.isEmpty) return _buildEmptyState(isDark);
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: controller.filteredTasks.length,
                separatorBuilder: (_, _) => spaceH(height: 10),
                itemBuilder: (ctx, index) =>
                    _buildTaskCard(controller.filteredTasks[index], isDark),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemeData.primary50, AppThemeData.primary4],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppThemeData.primary50.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                SolarIconsBold.checklist,
                color: Colors.white,
                size: 26,
              ),
            ),
            spaceW(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: 'Personal Tasks',
                  fontSize: 24,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                TextCustom(
                  title: 'Organize your day',
                  fontSize: 13,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: controller.goToAdd,
          icon: Icon(SolarIconsOutline.addCircle, size: 18),
          label: const TextCustom(
            title: 'Add Task',
            fontSize: 13,
            fontFamily: FontFamily.semiBold,
            color: Colors.white,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeData.primary50,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(bool isDark) {
    return Obx(() {
      final total = controller.totalTasks;
      final completed = controller.completedCount;
      final overdue = controller.overdueCount;
      final rate = controller.completionRate;

      return Row(
        children: [
          Expanded(
            child: _buildProgressCard(
              completed,
              total,
              rate,
              isDark,
            ),
          ),
          spaceW(width: 12),
          _buildOverdueCard(overdue, isDark),
        ],
      );
    });
  }

  Widget _buildProgressCard(int completed, int total, double rate, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppThemeData.success400.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  SolarIconsBold.checkCircle,
                  color: AppThemeData.success400,
                  size: 18,
                ),
              ),
              spaceW(width: 10),
              TextCustom(
                title: '$completed / $total tasks',
                fontSize: 15,
                fontFamily: FontFamily.semiBold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              const Spacer(),
              TextCustom(
                title: '${rate.round()}%',
                fontSize: 20,
                fontFamily: FontFamily.bold,
                color: AppThemeData.success400,
              ),
            ],
          ),
          spaceH(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              minHeight: 6,
              backgroundColor: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppThemeData.success400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueCard(int overdue, bool isDark) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: overdue > 0
              ? AppThemeData.danger300.withValues(alpha: 0.3)
              : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
          width: overdue > 0 ? 1 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppThemeData.danger300.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              SolarIconsBold.dangerTriangle,
              color: AppThemeData.danger300,
              size: 18,
            ),
          ),
          spaceH(height: 10),
          TextCustom(
            title: '$overdue',
            fontSize: 24,
            fontFamily: FontFamily.bold,
            color: overdue > 0
                ? AppThemeData.danger300
                : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ),
          TextCustom(
            title: 'Overdue',
            fontSize: 12,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          width: 0.5,
        ),
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        style: TextStyle(
          fontFamily: FontFamily.medium,
          fontSize: 14,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 14,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemeData.primary50.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              SolarIconsOutline.minimalisticMagnifier,
              color: AppThemeData.primary50,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
        () => Row(
          children: [
            _buildFilterChip(
              'Priority',
              controller.selectedPriority.value,
              controller.priorities,
              controller.filterByPriority,
              isDark,
            ),
            spaceW(width: 8),
            _buildFilterChip(
              'Status',
              controller.selectedStatus.value,
              controller.statuses,
              controller.filterByStatus,
              isDark,
            ),
            spaceW(width: 8),
            _buildFilterChip(
              'Category',
              controller.selectedCategory.value,
              controller.categories,
              controller.filterByCategory,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String selected,
    List<String> items,
    Function(String) onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => _showFilterSheet(label, selected, items, onTap, isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected != 'ALL'
              ? AppThemeData.primary50.withValues(alpha: 0.12)
              : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected != 'ALL'
                ? AppThemeData.primary50.withValues(alpha: 0.3)
                : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextCustom(
              title: selected == 'ALL' ? label : selected,
              fontSize: 12,
              fontFamily: FontFamily.medium,
              color: selected != 'ALL'
                  ? AppThemeData.primary50
                  : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ),
            spaceW(width: 4),
            Icon(
              SolarIconsOutline.altArrowDown,
              size: 16,
              color: selected != 'ALL'
                  ? AppThemeData.primary50
                  : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(
    String label,
    String selected,
    List<String> items,
    Function(String) onTap,
    bool isDark,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: 'Filter by $label',
              fontSize: 16,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            spaceH(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (item) => GestureDetector(
                      onTap: () {
                        onTap(item);
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected == item
                              ? AppThemeData.primary50.withValues(alpha: 0.15)
                              : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected == item
                                ? AppThemeData.primary50
                                : (isDark
                                    ? AppThemeData.grey8
                                    : AppThemeData.grey3),
                          ),
                        ),
                        child: TextCustom(
                          title: item,
                          fontSize: 13,
                          fontFamily: FontFamily.medium,
                          color: selected == item
                              ? AppThemeData.primary50
                              : (isDark
                                  ? AppThemeData.grey4
                                  : AppThemeData.grey7),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(PersonalTaskModel task, bool isDark) {
    final priorityColor = task.priorityColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: task.isCompleted == true
            ? (isDark ? AppThemeData.grey9 : AppThemeData.grey1)
                .withValues(alpha: 0.6)
            : (isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.isPinned == true
              ? AppThemeData.primary50.withValues(alpha: 0.4)
              : (isDark ? AppThemeData.grey8 : AppThemeData.grey3)
                  .withValues(alpha: 0.5),
          width: task.isPinned == true ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => controller.goToEdit(task),
          child: Row(
            children: [
              Container(
                width: 5,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => controller.toggleTask(task),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: task.isCompleted == true
                                    ? AppThemeData.success400
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: task.isCompleted == true
                                    ? null
                                    : Border.all(
                                        color: isDark
                                            ? AppThemeData.grey6
                                            : AppThemeData.grey5,
                                        width: 1.5,
                                      ),
                              ),
                              child: task.isCompleted == true
                                  ? const Icon(
                                      SolarIconsBold.checkCircle,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ),
                          spaceW(width: 12),
                          Expanded(
                            child: TextCustom(
                              title: task.title ?? '',
                              fontSize: 16,
                              fontFamily: FontFamily.semiBold,
                              color: task.isCompleted == true
                                  ? (isDark
                                      ? AppThemeData.grey6
                                      : AppThemeData.grey5)
                                  : (isDark
                                      ? AppThemeData.grey1
                                      : AppThemeData.grey10),
                              maxLine: 1,
                            ),
                          ),
                          if (task.isPinned == true)
                            Icon(
                              SolarIconsBold.pin,
                              size: 16,
                              color: AppThemeData.primary50,
                            ),
                          spaceW(width: 8),
                          _buildCardMenu(task, isDark),
                        ],
                      ),
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        spaceH(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 36),
                          child: TextCustom(
                            title: task.description ?? '',
                            fontSize: 13,
                            fontFamily: FontFamily.regular,
                            color: isDark
                                ? AppThemeData.grey5
                                : AppThemeData.grey6,
                            maxLine: 2,
                          ),
                        ),
                      ],
                      spaceH(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Row(
                          children: [
                            _buildBadge(
                              task.priorityLabel,
                              task.priorityColor,
                              isDark,
                            ),
                            spaceW(width: 6),
                            _buildBadge(
                              task.statusLabel,
                              task.statusColor,
                              isDark,
                            ),
                            const Spacer(),
                            if (task.isOverdue)
                              _buildBadge('Overdue', AppThemeData.danger300, isDark)
                            else if (task.isDueSoon)
                              _buildBadge(
                                '${task.daysUntilDue}d left',
                                AppThemeData.pending400,
                                isDark,
                              )
                            else if (task.dueDate != null)
                              Row(
                                children: [
                                  Icon(
                                    SolarIconsOutline.calendar,
                                    size: 14,
                                    color: isDark
                                        ? AppThemeData.grey6
                                        : AppThemeData.grey5,
                                  ),
                                  spaceW(width: 4),
                                  TextCustom(
                                    title: task.formattedDueDate,
                                    fontSize: 11,
                                    fontFamily: FontFamily.medium,
                                    color: isDark
                                        ? AppThemeData.grey5
                                        : AppThemeData.grey6,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (task.tags != null && task.tags!.isNotEmpty) ...[
                        spaceH(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 36),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: task.tags!
                                .take(3)
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppThemeData.primary50
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: TextCustom(
                                      title: '#$tag',
                                      fontSize: 10,
                                      fontFamily: FontFamily.medium,
                                      color: AppThemeData.primary50,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardMenu(PersonalTaskModel task, bool isDark) {
    return GestureDetector(
      onTap: () => _showTaskMenu(task, isDark),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: (isDark ? AppThemeData.grey9 : AppThemeData.grey1)
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          SolarIconsOutline.menuDots,
          size: 16,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
      ),
    );
  }

  void _showTaskMenu(PersonalTaskModel task, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            spaceH(height: 16),
            TextCustom(
              title: task.title ?? '',
              fontSize: 16,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              maxLine: 1,
            ),
            spaceH(height: 16),
            _buildMenuItem(
              SolarIconsOutline.penNewRound,
              'Edit',
              () {
                Get.back();
                controller.goToEdit(task);
              },
              isDark,
            ),
            _buildMenuItem(
              task.isCompleted == true
                  ? SolarIconsOutline.undoLeftRound
                  : SolarIconsBold.checkCircle,
              task.isCompleted == true ? 'Reopen' : 'Mark Complete',
              () {
                Get.back();
                controller.toggleTask(task);
              },
              isDark,
              color: AppThemeData.success400,
            ),
            _buildMenuItem(
              task.isPinned == true ? SolarIconsOutline.pin : SolarIconsBold.pin,
              task.isPinned == true ? 'Unpin' : 'Pin',
              () {
                Get.back();
                controller.pinTask(task);
              },
              isDark,
              color: AppThemeData.primary50,
            ),
            _buildMenuItem(
              SolarIconsOutline.trashBin2,
              'Delete',
              () {
                Get.back();
                controller.deleteTask(task);
              },
              isDark,
              color: AppThemeData.danger300,
            ),
            spaceH(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap,
    bool isDark, {
    Color? color,
  }) {
    final itemColor = color ?? (isDark ? AppThemeData.grey3 : AppThemeData.grey7);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: (isDark ? AppThemeData.grey9 : AppThemeData.grey1)
              .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: itemColor),
            spaceW(width: 12),
            TextCustom(
              title: title,
              fontSize: 14,
              fontFamily: FontFamily.medium,
              color: itemColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextCustom(
        title: label,
        fontSize: 10,
        fontFamily: FontFamily.bold,
        color: color,
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                SolarIconsOutline.checklist,
                size: 40,
                color: AppThemeData.primary50.withValues(alpha: 0.5),
              ),
            ),
            spaceH(height: 20),
            TextCustom(
              title: 'No tasks found',
              fontSize: 18,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
            ),
            spaceH(height: 8),
            TextCustom(
              title: 'Create your first task to get started',
              fontSize: 14,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              textAlign: TextAlign.center,
            ),
            spaceH(height: 24),
            ElevatedButton.icon(
              onPressed: controller.goToAdd,
              icon: const Icon(SolarIconsOutline.addCircle, size: 18),
              label: const TextCustom(
                title: 'Create Task',
                fontSize: 14,
                fontFamily: FontFamily.semiBold,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton(bool isDark) {
    return FloatingActionButton(
      onPressed: controller.goToAdd,
      backgroundColor: AppThemeData.primary50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Icon(SolarIconsOutline.addCircle, color: Colors.white, size: 28),
    );
  }
}
