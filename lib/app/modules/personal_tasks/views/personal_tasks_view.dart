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
          return Center(child: MahekLoader(showBackgroundOverlay: true, message: 'Loading Tasks...'));
        }
        return isMobile ? _buildMobileLayout(isDark) : _buildDesktopLayout(isDark);
      }),
      floatingActionButton: isMobile ? _buildFloatingButton(isDark) : null,
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildLeftPanel(isDark)),
        Container(width: 1, color: isDark ? AppThemeData.grey8.withValues(alpha: 0.2) : AppThemeData.grey3.withValues(alpha: 0.3)),
        Expanded(flex: 4, child: _buildRightPanel(isDark)),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          spaceH(height: 14),
          _buildStats(isDark),
          spaceH(height: 14),
          _buildSearchBar(isDark),
          spaceH(height: 10),
          _buildFilters(isDark),
          spaceH(height: 14),
          Expanded(child: _buildTaskList(isDark)),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          spaceH(height: 16),
          _buildStats(isDark),
          spaceH(height: 16),
          _buildSearchBar(isDark),
          spaceH(height: 10),
          _buildFilters(isDark),
          spaceH(height: 14),
          Expanded(child: _buildTaskList(isDark)),
        ],
      ),
    );
  }

  Widget _buildRightPanel(bool isDark) {
    return Obx(() {
      if (controller.filteredTasks.isEmpty) return _buildEditorPlaceholder(isDark);
      return _buildEditorPanel(isDark);
    });
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
                gradient: LinearGradient(colors: [AppThemeData.primary50, AppThemeData.primary4]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Icon(SolarIconsBold.checklist, color: Colors.white, size: 26),
            ),
            spaceW(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(title: 'Personal Tasks', fontSize: 24, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                TextCustom(title: 'Organize your day', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              ],
            ),
          ],
        ),
        if (!ResponsiveWidget.isMobile(Get.context!))
          ElevatedButton.icon(
            onPressed: controller.goToAdd,
            icon: Icon(SolarIconsOutline.addCircle, size: 18),
            label: const TextCustom(title: 'Add Task', fontSize: 13, fontFamily: FontFamily.semiBold, color: Colors.white),
            style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
      ],
    );
  }

  Widget _buildStats(bool isDark) {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatChip('Total', '${controller.totalTasks}', AppThemeData.primary50, isDark),
          spaceW(width: 8),
          _buildStatChip('Done', '${controller.completedCount}', AppThemeData.success400, isDark),
          spaceW(width: 8),
          _buildStatChip('Pending', '${controller.pendingCount}', AppThemeData.pending400, isDark),
          spaceW(width: 8),
          _buildStatChip('Overdue', '${controller.overdueCount}', AppThemeData.danger300, isDark),
          spaceW(width: 8),
          _buildStatChip('Pinned', '${controller.pinnedCount}', AppThemeData.primary4, isDark),
        ],
      ),
    ));
  }

  Widget _buildStatChip(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextCustom(title: value, fontSize: 16, fontFamily: FontFamily.bold, color: color),
          spaceW(width: 6),
          TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(SolarIconsOutline.minimalisticMagnifier, color: AppThemeData.primary50, size: 20),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
        children: [
          _buildFilterChip('Priority', controller.selectedPriority.value, controller.priorities, controller.filterByPriority, isDark),
          spaceW(width: 8),
          _buildFilterChip('Status', controller.selectedStatus.value, controller.statuses, controller.filterByStatus, isDark),
          spaceW(width: 8),
          _buildFilterChip('Category', controller.selectedCategory.value, controller.categories, controller.filterByCategory, isDark),
          spaceW(width: 8),
          _buildViewToggle(SolarIconsOutline.list, controller.isGridView.value, () => controller.isGridView.value = true, isDark),
          _buildViewToggle(SolarIconsOutline.filter, !controller.isGridView.value, () => controller.isGridView.value = false, isDark),
        ],
      )),
    );
  }

  Widget _buildFilterChip(String label, String selected, List<String> items, Function(String) onTap, bool isDark) {
    return GestureDetector(
      onTap: () => _showFilterSheet(label, selected, items, onTap, isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected != 'ALL' ? AppThemeData.primary50.withValues(alpha: 0.12) : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected != 'ALL' ? AppThemeData.primary50.withValues(alpha: 0.3) : (isDark ? AppThemeData.grey8 : AppThemeData.grey3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextCustom(title: selected == 'ALL' ? label : selected, fontSize: 12, fontFamily: FontFamily.medium, color: selected != 'ALL' ? AppThemeData.primary50 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
            spaceW(width: 4),
            Icon(SolarIconsOutline.altArrowDown, size: 16, color: selected != 'ALL' ? AppThemeData.primary50 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(String label, String selected, List<String> items, Function(String) onTap, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(title: 'Filter by $label', fontSize: 16, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            spaceH(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) => GestureDetector(
                onTap: () { onTap(item); Get.back(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected == item ? AppThemeData.primary50.withValues(alpha: 0.15) : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected == item ? AppThemeData.primary50 : (isDark ? AppThemeData.grey8 : AppThemeData.grey3)),
                  ),
                  child: TextCustom(title: item, fontSize: 13, fontFamily: FontFamily.medium, color: selected == item ? AppThemeData.primary50 : (isDark ? AppThemeData.grey4 : AppThemeData.grey7)),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [AppThemeData.primary50, AppThemeData.primary4]) : null,
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? null : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
        ),
        child: Icon(icon, size: 18, color: isSelected ? Colors.white : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
      ),
    );
  }

  Widget _buildTaskList(bool isDark) {
    return Obx(() {
      if (controller.filteredTasks.isEmpty) return _buildEmptyState(isDark);
      return controller.isGridView.value ? _buildGridView(isDark) : _buildListView(isDark);
    });
  }

  Widget _buildGridView(bool isDark) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 340, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.7),
      itemCount: controller.filteredTasks.length,
      itemBuilder: (context, index) => _buildTaskCard(controller.filteredTasks[index], isDark),
    );
  }

  Widget _buildListView(bool isDark) {
    return ListView.separated(
      itemCount: controller.filteredTasks.length,
      separatorBuilder: (_, __) => spaceH(height: 8),
      itemBuilder: (context, index) => _buildTaskCard(controller.filteredTasks[index], isDark),
    );
  }

  Widget _buildTaskCard(PersonalTaskModel task, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: task.isCompleted == true
            ? (isDark ? AppThemeData.grey9 : AppThemeData.grey1).withValues(alpha: 0.6)
            : (isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: task.isPinned == true ? AppThemeData.primary50.withValues(alpha: 0.4) : (isDark ? AppThemeData.grey8 : AppThemeData.grey3).withValues(alpha: 0.5), width: task.isPinned == true ? 1.5 : 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => controller.goToEdit(task),
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
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: task.isCompleted == true ? AppThemeData.success400 : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          border: task.isCompleted == true ? null : Border.all(color: isDark ? AppThemeData.grey6 : AppThemeData.grey5, width: 1.5),
                        ),
                        child: task.isCompleted == true ? Icon(SolarIconsBold.checkCircle, color: Colors.white, size: 14) : null,
                      ),
                    ),
                    spaceW(width: 10),
                    Expanded(
                      child: TextCustom(
                        title: task.title ?? '',
                        fontSize: 15,
                        fontFamily: FontFamily.semiBold,
                        color: task.isCompleted == true
                            ? (isDark ? AppThemeData.grey6 : AppThemeData.grey5)
                            : (isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                        maxLine: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.pinTask(task),
                      child: Icon(task.isPinned == true ? SolarIconsBold.pin : SolarIconsOutline.pin, size: 18, color: task.isPinned == true ? AppThemeData.primary50 : (isDark ? AppThemeData.grey6 : AppThemeData.grey5)),
                    ),
                  ],
                ),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  spaceH(height: 8),
                  TextCustom(
                    title: task.description ?? '',
                    fontSize: 12,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    maxLine: 2,
                  ),
                ],
                spaceH(height: 12),
                Row(
                  children: [
                    _buildBadge(task.priorityLabel, task.priorityColor, isDark),
                    spaceW(width: 6),
                    _buildBadge(task.statusLabel, task.statusColor, isDark),
                    const Spacer(),
                    if (task.isOverdue)
                      _buildBadge('Overdue', AppThemeData.danger300, isDark)
                    else if (task.isDueSoon)
                      _buildBadge('${task.daysUntilDue}d left', AppThemeData.pending400, isDark)
                    else if (task.dueDate != null)
                        Icon(SolarIconsOutline.calendar, size: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                  ],
                ),
                if (task.tags != null && task.tags!.isNotEmpty) ...[
                  spaceH(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: task.tags!.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                      child: TextCustom(title: '#$tag', fontSize: 10, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: TextCustom(title: label, fontSize: 10, fontFamily: FontFamily.bold, color: color),
    );
  }

  Widget _buildEditorPlaceholder(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(SolarIconsOutline.checklist, size: 64, color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
          spaceH(height: 16),
          TextCustom(title: 'Select a task to view details', fontSize: 16, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ],
      ),
    );
  }

  Widget _buildEditorPanel(bool isDark) {
    final task = controller.filteredTasks.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: task.priorityColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(task.priorityIcon, color: task.priorityColor, size: 22),
              ),
              spaceW(width: 12),
              Expanded(
                child: TextCustom(title: task.title ?? '', fontSize: 20, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 2),
              ),
            ],
          ),
          spaceH(height: 20),
          _buildEditorSection('Status', SolarIconsOutline.flag, [
            Row(children: [
              _buildBadge(task.statusLabel, task.statusColor, isDark),
              spaceW(width: 8),
              _buildBadge(task.priorityLabel, task.priorityColor, isDark),
              if (task.isPinned == true) ...[spaceW(width: 8), _buildBadge('Pinned', AppThemeData.primary50, isDark)],
            ]),
          ], isDark),
          spaceH(height: 16),
          if (task.description != null && task.description!.isNotEmpty)
            _buildEditorSection('Description', SolarIconsOutline.notes, [
              TextCustom(title: task.description ?? '', fontSize: 14, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey3 : AppThemeData.grey7),
            ], isDark),
          if (task.dueDate != null) ...[
            spaceH(height: 16),
            _buildEditorSection('Due Date', SolarIconsOutline.calendar, [
              Row(children: [
                TextCustom(title: task.formattedDueDate, fontSize: 14, fontFamily: FontFamily.medium, color: task.isOverdue ? AppThemeData.danger300 : (isDark ? AppThemeData.grey3 : AppThemeData.grey7)),
                if (task.isOverdue) ...[spaceW(width: 8), _buildBadge('Overdue', AppThemeData.danger300, isDark)],
                if (task.isDueSoon) ...[spaceW(width: 8), _buildBadge('${task.daysUntilDue}d left', AppThemeData.pending400, isDark)],
              ]),
            ], isDark),
          ],
          if (task.notes != null && task.notes!.isNotEmpty) ...[
            spaceH(height: 16),
            _buildEditorSection('Notes', SolarIconsOutline.notes, [
              TextCustom(title: task.notes ?? '', fontSize: 14, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey3 : AppThemeData.grey7),
            ], isDark),
          ],
          if (task.tags != null && task.tags!.isNotEmpty) ...[
            spaceH(height: 16),
            _buildEditorSection('Tags', SolarIconsOutline.tag, [
              Wrap(spacing: 6, runSpacing: 6, children: task.tags!.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: TextCustom(title: '#$tag', fontSize: 12, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
              )).toList()),
            ], isDark),
          ],
          spaceH(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.goToEdit(task),
                  icon: Icon(SolarIconsOutline.penNewRound, size: 16),
                  label: const TextCustom(title: 'Edit', fontSize: 13, fontFamily: FontFamily.semiBold, color: Colors.white),
                  style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              spaceW(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.toggleTask(task),
                  icon: Icon(task.isCompleted == true ? SolarIconsOutline.undoLeftRound : SolarIconsBold.checkCircle, size: 16),
                  label: TextCustom(title: task.isCompleted == true ? 'Reopen' : 'Complete', fontSize: 13, fontFamily: FontFamily.semiBold, color: AppThemeData.success400),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppThemeData.success400)),
                ),
              ),
            ],
          ),
          spaceH(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => controller.deleteTask(task),
              icon: Icon(SolarIconsOutline.trashBin2, size: 16, color: AppThemeData.danger300),
              label: const TextCustom(title: 'Delete', fontSize: 13, fontFamily: FontFamily.semiBold, color: AppThemeData.danger300),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppThemeData.danger300)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorSection(String title, IconData icon, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(width: 26, height: 26, decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(7)), child: Icon(icon, color: AppThemeData.primary50, size: 14)),
          spaceW(width: 8),
          TextCustom(title: title, fontSize: 12, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
        ]),
        spaceH(height: 8),
        ...children,
      ],
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
              decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
              child: Icon(SolarIconsOutline.checklist, size: 40, color: AppThemeData.primary50.withValues(alpha: 0.5)),
            ),
            spaceH(height: 20),
            TextCustom(title: 'No tasks found', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey7),
            spaceH(height: 8),
            TextCustom(title: 'Create your first task to get started', fontSize: 14, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5, textAlign: TextAlign.center),
            spaceH(height: 24),
            ElevatedButton.icon(
              onPressed: controller.goToAdd,
              icon: Icon(SolarIconsOutline.addCircle, size: 18),
              label: const TextCustom(title: 'Create Task', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
              style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
