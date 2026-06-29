import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../controllers/personal_tasks_controller.dart';
import '../widgets/personal_task_card.dart';
import '../widgets/personal_tasks_sidebar.dart';

class PersonalTasksView extends GetView<PersonalTasksController> {
  const PersonalTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MahekResponsive.compatIsMobile(context);
    final isDesktop = MahekResponsive.compatIsDesktop(context);

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
        return isDesktop
            ? _buildDesktopLayout(context, isDark)
            : _buildMobileLayout(context, isDark, isMobile);
      }),
      floatingActionButton: isMobile ? _buildFAB(isDark) : null,
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildMainContent(context, isDark, false)),
        _buildDivider(isDark),
        PersonalTasksSidebar(
          upcomingTasks: controller.upcomingTasks,
          tasksByCategory: controller.tasksByCategory,
          aiRecommendations: controller.aiRecommendations,
          overdueCount: controller.overdueCount,
          estimatedFocusMinutes: controller.estimatedFocusMinutes,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, bool isDark, bool isMobile) {
    return _buildMainContent(context, isDark, isMobile);
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: double.infinity,
      color: isDark
          ? AppThemeData.grey8.withValues(alpha: 0.25)
          : AppThemeData.grey3.withValues(alpha: 0.4),
    );
  }

  Widget _buildMainContent(
      BuildContext context, bool isDark, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark, isMobile),
          spaceH(height: 18),
          _buildStats(isDark, isMobile),
          spaceH(height: 18),
          _buildSearchBar(isDark),
          spaceH(height: 14),
          _buildFilterTabs(isDark, isMobile),
          spaceH(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.filteredTasks.isEmpty) {
                return _buildEmptyState(isDark);
              }
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: controller.filteredTasks.length,
                separatorBuilder: (_, _) => spaceH(height: 10),
                itemBuilder: (ctx, index) {
                  final task = controller.filteredTasks[index];
                  return PersonalTaskCard(
                    task: task,
                    isDark: isDark,
                    onTap: () => controller.goToEdit(task),
                    onToggle: () => controller.toggleTask(task),
                    onEdit: () => controller.goToEdit(task),
                    onPin: () => controller.pinTask(task),
                    onDelete: () => controller.deleteTask(task),
                  );
                },
              );
            }),
          ),
          _buildEndFooter(isDark),
          spaceH(height: 8),
          _buildQuoteBar(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isMobile) {
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
              child: const Icon(
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
                  title: 'Organize your day, achieve your goals.',
                  fontSize: 13,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ],
        ),
        if (!isMobile)
          ElevatedButton.icon(
            onPressed: controller.goToAdd,
            icon: const Icon(SolarIconsOutline.addCircle, size: 18),
            label: const TextCustom(
              title: 'Add Task',
              fontSize: 13,
              fontFamily: FontFamily.semiBold,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeData.primary50,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStats(bool isDark, bool isMobile) {
    return Obx(() {
      final total = controller.totalTasks;
      final completed = controller.completedCount;
      final pending = controller.pendingCount;
      final overdue = controller.overdueCount;
      final rate = controller.completionRate;

      if (isMobile) {
        return SizedBox(
          height: 170,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                width: 220,
                child: _buildDailyProgressCard(completed, total, rate, isDark),
              ),
              spaceW(width: 10),
              SizedBox(
                width: 150,
                child: _buildStatMiniCard(
                  icon: SolarIconsBold.document,
                  value: '$total',
                  label: 'Total Tasks',
                  subtitle: 'View all tasks →',
                  color: AppThemeData.neonBlue,
                  isDark: isDark,
                ),
              ),
              spaceW(width: 10),
              SizedBox(
                width: 150,
                child: _buildStatMiniCard(
                  icon: SolarIconsBold.checkCircle,
                  value: '$completed',
                  label: 'Completed',
                  subtitle: completed > 0 ? 'Great job!' : 'Get started',
                  color: AppThemeData.success400,
                  isDark: isDark,
                ),
              ),
              spaceW(width: 10),
              SizedBox(
                width: 150,
                child: _buildStatMiniCard(
                  icon: SolarIconsOutline.clockCircle,
                  value: '$pending',
                  label: 'Pending',
                  subtitle: pending > 0 ? 'Keep going' : 'All clear',
                  color: AppThemeData.pending400,
                  isDark: isDark,
                ),
              ),
              spaceW(width: 10),
              SizedBox(
                width: 150,
                child: _buildStatMiniCard(
                  icon: SolarIconsBold.dangerTriangle,
                  value: '$overdue',
                  label: 'Overdue',
                  subtitle: overdue > 0 ? 'Needs attention' : 'None',
                  color: AppThemeData.danger300,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        );
      }

      return Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildDailyProgressCard(completed, total, rate, isDark),
          ),
          spaceW(width: 12),
          Expanded(
            child: _buildStatMiniCard(
              icon: SolarIconsBold.document,
              value: '$total',
              label: 'Total Tasks',
              subtitle: 'View all tasks →',
              color: AppThemeData.neonBlue,
              isDark: isDark,
            ),
          ),
          spaceW(width: 12),
          Expanded(
            child: _buildStatMiniCard(
              icon: SolarIconsBold.checkCircle,
              value: '$completed',
              label: 'Completed',
              subtitle: completed > 0 ? 'Great job!' : 'Get started',
              color: AppThemeData.success400,
              isDark: isDark,
            ),
          ),
          spaceW(width: 12),
          Expanded(
            child: _buildStatMiniCard(
              icon: SolarIconsOutline.clockCircle,
              value: '$pending',
              label: 'Pending',
              subtitle: pending > 0 ? 'Keep going' : 'All clear',
              color: AppThemeData.pending400,
              isDark: isDark,
            ),
          ),
          spaceW(width: 12),
          Expanded(
            child: _buildStatMiniCard(
              icon: SolarIconsBold.dangerTriangle,
              value: '$overdue',
              label: 'Overdue',
              subtitle: overdue > 0 ? 'Needs attention' : 'None',
              color: AppThemeData.danger300,
              isDark: isDark,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDailyProgressCard(
      int completed, int total, double rate, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
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
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    strokeWidth: 8,
                    backgroundColor:
                        isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppThemeData.neonPurple,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                TextCustom(
                  title: '${rate.round()}%',
                  fontSize: 22,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
              ],
            ),
          ),
          spaceW(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextCustom(
                  title: 'Daily Progress',
                  fontSize: 14,
                  fontFamily: FontFamily.semiBold,
                  color: isDark ? AppThemeData.grey2 : AppThemeData.grey9,
                ),
                spaceH(height: 2),
                TextCustom(
                  title: '$completed of $total tasks completed',
                  fontSize: 12,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
                spaceH(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    minHeight: 6,
                    backgroundColor:
                        isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppThemeData.neonPurple),
                  ),
                ),
                spaceH(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _buildProgressDot(AppThemeData.success400, 'Completed $completed'),
                    _buildProgressDot(AppThemeData.pending400, 'Pending ${controller.pendingCount}'),
                    _buildProgressDot(AppThemeData.danger300, 'Overdue ${controller.overdueCount}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        spaceW(width: 4),
        TextCustom(
          title: label,
          fontSize: 10,
          fontFamily: FontFamily.medium,
          color: AppThemeData.grey5,
        ),
      ],
    );
  }

  Widget _buildStatMiniCard({
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          spaceH(height: 14),
          TextCustom(
            title: value,
            fontSize: 28,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          spaceH(height: 2),
          TextCustom(
            title: label,
            fontSize: 12,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
          ),
          spaceH(height: 2),
          TextCustom(
            title: subtitle,
            fontSize: 11,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
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
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextCustom(
              title: '⌘K',
              fontSize: 11,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark, bool isMobile) {
    final tabs = [
      ('ALL', 'All Tasks'),
      ('HIGH', 'High Priority'),
      ('PENDING', 'Pending'),
      ('COMPLETED', 'Completed'),
      ('OVERDUE', 'Overdue'),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length + 2,
        separatorBuilder: (_, _) => spaceW(width: 8),
        itemBuilder: (ctx, index) {
          if (index < tabs.length) {
            final (key, label) = tabs[index];
            return Obx(() {
              final isSelected = controller.activeTab.value == key;
              return GestureDetector(
                onTap: () => controller.setActiveTab(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppThemeData.primary50
                        : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppThemeData.primary50
                          : (isDark
                              ? AppThemeData.grey8
                              : AppThemeData.grey3),
                      width: isSelected ? 1 : 0.5,
                    ),
                  ),
                  child: TextCustom(
                    title: label,
                    fontSize: 12,
                    fontFamily:
                        isSelected ? FontFamily.bold : FontFamily.medium,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppThemeData.grey4
                            : AppThemeData.grey7),
                  ),
                ),
              );
            });
          }

          if (index == tabs.length) {
            return _buildSortButton(isDark);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSortButton(bool isDark) {
    return Obx(() {
      final sortLabel = {
        'DATE': 'Date',
        'PRIORITY': 'Priority',
        'NAME': 'Name',
      }[controller.sortBy.value] ?? 'Date';

      return GestureDetector(
        onTap: controller.cycleSort,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sort_rounded,
                size: 16,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              spaceW(width: 6),
              TextCustom(
                title: 'Sort: $sortLabel',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEndFooter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            SolarIconsOutline.star,
            size: 14,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
          spaceW(width: 8),
          TextCustom(
            title: "You've reached the end",
            fontSize: 12,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
          spaceW(width: 8),
          Icon(
            SolarIconsOutline.star,
            size: 14,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextCustom(
              title:
                  'Discipline is the bridge between goals and accomplishment.',
              fontSize: 12,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ),
          Icon(
            SolarIconsBold.heart,
            size: 16,
            color: AppThemeData.primary50.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(bool isDark) {
    return GestureDetector(
      onTap: controller.goToAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppThemeData.primary50, AppThemeData.primary4],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppThemeData.primary50.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(SolarIconsOutline.addCircle,
                color: Colors.white, size: 20),
            spaceW(width: 8),
            const TextCustom(
              title: 'Add New Task',
              fontSize: 14,
              fontFamily: FontFamily.semiBold,
              color: Colors.white,
            ),
          ],
        ),
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
}
