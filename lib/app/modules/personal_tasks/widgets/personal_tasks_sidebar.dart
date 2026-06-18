import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/models/personal_task_model.dart';

class PersonalTasksSidebar extends StatelessWidget {
  final List<PersonalTaskModel> upcomingTasks;
  final Map<String, int> tasksByCategory;
  final List<String> aiRecommendations;
  final int overdueCount;
  final int estimatedFocusMinutes;
  final bool isDark;
  final VoidCallback? onViewCalendar;
  final VoidCallback? onViewAllCategories;

  const PersonalTasksSidebar({
    super.key,
    required this.upcomingTasks,
    required this.tasksByCategory,
    required this.aiRecommendations,
    required this.overdueCount,
    required this.estimatedFocusMinutes,
    required this.isDark,
    this.onViewCalendar,
    this.onViewAllCategories,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          children: [
            _UpcomingSection(
              tasks: upcomingTasks,
              isDark: isDark,
              onViewAll: onViewCalendar,
            ),
            spaceH(height: 16),
            _AIAssistantCard(
              overdueCount: overdueCount,
              recommendations: aiRecommendations,
              estimatedMinutes: estimatedFocusMinutes,
              isDark: isDark,
            ),
            spaceH(height: 16),
            _CategoriesSection(
              tasksByCategory: tasksByCategory,
              isDark: isDark,
              onViewAll: onViewAllCategories,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  final List<PersonalTaskModel> tasks;
  final bool isDark;
  final VoidCallback? onViewAll;

  const _UpcomingSection({
    required this.tasks,
    required this.isDark,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return _SidebarCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(
                title: 'Upcoming',
                fontSize: 16,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              GestureDetector(
                onTap: onViewAll,
                child: TextCustom(
                  title: 'View Calendar →',
                  fontSize: 12,
                  fontFamily: FontFamily.medium,
                  color: AppThemeData.primary50,
                ),
              ),
            ],
          ),
          spaceH(height: 14),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: TextCustom(
                title: 'No upcoming tasks',
                fontSize: 13,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            )
          else
            ...tasks.map((task) => _UpcomingTaskItem(
                  task: task,
                  isDark: isDark,
                )),
        ],
      ),
    );
  }
}

class _UpcomingTaskItem extends StatelessWidget {
  final PersonalTaskModel task;
  final bool isDark;

  const _UpcomingTaskItem({
    required this.task,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isOverdue
                  ? AppThemeData.danger300.withValues(alpha: 0.1)
                  : AppThemeData.pending400.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              SolarIconsOutline.clockCircle,
              size: 16,
              color: isOverdue
                  ? AppThemeData.danger300
                  : AppThemeData.pending400,
            ),
          ),
          spaceW(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: task.title ?? '',
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey2 : AppThemeData.grey9,
                  maxLine: 1,
                ),
                TextCustom(
                  title: task.formattedDueDate,
                  fontSize: 11,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isOverdue
                  ? AppThemeData.danger300.withValues(alpha: 0.1)
                  : AppThemeData.pending400.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextCustom(
              title: isOverdue ? 'Overdue' : 'Soon',
              fontSize: 10,
              fontFamily: FontFamily.bold,
              color: isOverdue
                  ? AppThemeData.danger300
                  : AppThemeData.pending400,
            ),
          ),
        ],
      ),
    );
  }
}

class _AIAssistantCard extends StatelessWidget {
  final int overdueCount;
  final List<String> recommendations;
  final int estimatedMinutes;
  final bool isDark;

  const _AIAssistantCard({
    required this.overdueCount,
    required this.recommendations,
    required this.estimatedMinutes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeData.neonPurple.withValues(alpha: 0.15),
            AppThemeData.neonBlue.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppThemeData.neonPurple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                SolarIconsBold.star,
                size: 18,
                color: AppThemeData.neonPurple,
              ),
              spaceW(width: 8),
              TextCustom(
                title: 'AI Assistant',
                fontSize: 15,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              spaceW(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppThemeData.neonPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextCustom(
                  title: 'Beta',
                  fontSize: 10,
                  fontFamily: FontFamily.bold,
                  color: AppThemeData.neonPurple,
                ),
              ),
            ],
          ),
          spaceH(height: 14),
          if (overdueCount > 0)
            Text.rich(
              TextSpan(
                text: 'You have ',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: FontFamily.regular,
                  color: isDark
                      ? AppThemeData.grey3
                      : AppThemeData.grey8,
                ),
                children: [
                  TextSpan(
                    text: '$overdueCount overdue',
                    style: const TextStyle(
                      fontFamily: FontFamily.bold,
                      color: AppThemeData.danger300,
                    ),
                  ),
                  TextSpan(
                    text: overdueCount == 1 ? ' task.' : ' tasks.',
                  ),
                ],
              ),
            )
          else
            TextCustom(
              title: 'No overdue tasks. Great job!',
              fontSize: 13,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
            ),
          spaceH(height: 12),
          TextCustom(
            title: 'Recommended for today:',
            fontSize: 12,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
          ),
          spaceH(height: 6),
          ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: AppThemeData.neonPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    spaceW(width: 8),
                    Expanded(
                      child: TextCustom(
                        title: rec,
                        fontSize: 12,
                        fontFamily: FontFamily.regular,
                        color: isDark
                            ? AppThemeData.grey3
                            : AppThemeData.grey8,
                        maxLine: 2,
                      ),
                    ),
                  ],
                ),
              )),
          spaceH(height: 14),
          Divider(
            color: isDark
                ? AppThemeData.grey8.withValues(alpha: 0.3)
                : AppThemeData.grey3.withValues(alpha: 0.5),
            height: 1,
          ),
          spaceH(height: 12),
          Row(
            children: [
              Icon(
                SolarIconsOutline.chartSquare,
                size: 14,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              spaceW(width: 6),
              TextCustom(
                title: 'Estimated focus time',
                fontSize: 12,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
          spaceH(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              TextCustom(
                title: '$estimatedMinutes min',
                fontSize: 22,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              spaceW(width: 6),
              TextCustom(
                title: 'For your pending tasks',
                fontSize: 11,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final Map<String, int> tasksByCategory;
  final bool isDark;
  final VoidCallback? onViewAll;

  const _CategoriesSection({
    required this.tasksByCategory,
    required this.isDark,
    this.onViewAll,
  });

  static const _categoryIcons = {
    'WORK': Icons.work_outline_rounded,
    'PERSONAL': Icons.person_outline_rounded,
    'HEALTH': Icons.favorite_outline,
    'FINANCE': Icons.account_balance_wallet_outlined,
    'EDUCATION': Icons.school_outlined,
    'GENERAL': Icons.folder_outlined,
    'OTHER': Icons.more_horiz_rounded,
  };

  static const _categoryColors = {
    'WORK': AppThemeData.neonBlue,
    'PERSONAL': AppThemeData.neonPurple,
    'HEALTH': AppThemeData.danger300,
    'FINANCE': AppThemeData.neonMint,
    'EDUCATION': AppThemeData.pending400,
    'GENERAL': AppThemeData.grey5,
    'OTHER': AppThemeData.grey6,
  };

  @override
  Widget build(BuildContext context) {
    final sortedEntries = tasksByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _SidebarCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(
                title: 'Categories',
                fontSize: 16,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              GestureDetector(
                onTap: onViewAll,
                child: TextCustom(
                  title: 'View all',
                  fontSize: 12,
                  fontFamily: FontFamily.medium,
                  color: AppThemeData.primary50,
                ),
              ),
            ],
          ),
          spaceH(height: 14),
          if (sortedEntries.isEmpty)
            TextCustom(
              title: 'No categories yet',
              fontSize: 13,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            )
          else
            ...sortedEntries.map((entry) {
              final icon = _categoryIcons[entry.key] ?? Icons.folder_outlined;
              final color =
                  _categoryColors[entry.key] ?? AppThemeData.grey5;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 16, color: color),
                    ),
                    spaceW(width: 10),
                    Expanded(
                      child: TextCustom(
                        title: entry.key.replaceAll('_', ' '),
                        fontSize: 13,
                        fontFamily: FontFamily.medium,
                        color:
                            isDark ? AppThemeData.grey2 : AppThemeData.grey9,
                      ),
                    ),
                    TextCustom(
                      title: '${entry.value}',
                      fontSize: 13,
                      fontFamily: FontFamily.bold,
                      color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SidebarCard extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _SidebarCard({
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }
}
