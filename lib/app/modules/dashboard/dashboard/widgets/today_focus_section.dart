import 'package:flutter/material.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:solar_icons/solar_icons.dart';

class TodayFocusSection extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final VoidCallback? onTaskTap;
  final VoidCallback? onDueTap;
  final VoidCallback? onReminderTap;
  final VoidCallback? onViewAll;

  const TodayFocusSection({
    super.key,
    required this.controller,
    required this.isDark,
    this.onTaskTap,
    this.onDueTap,
    this.onReminderTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.hasTodayFocus) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.12)
              : AppThemeData.grey3.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppThemeData.danger300, AppThemeData.neonOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(SolarIconsBold.checklist,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 14),
              TextCustom(
                title: "Today's Focus",
                fontSize: 17,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Timeline items
          if (controller.overdueTasks.isNotEmpty)
            ...controller.overdueTasks.take(3).map((task) => _TimelineItem(
                  time: _formatTaskTime(task.dueDate),
                  title: task.title ?? 'Untitled Task',
                  subtitle: task.dueDate != null
                      ? 'Due ${task.formattedDueDate}'
                      : 'No due date',
                  dotColor: AppThemeData.danger300,
                  priorityLabel: task.priorityLabel,
                  priorityColor: task.priorityColor,
                  isDark: isDark,
                  onTap: onTaskTap,
                )),

          if (controller.expiringDues.isNotEmpty)
            ...controller.expiringDues.take(2).map((due) => _TimelineItem(
                  time: 'Due Today',
                  title: due.customerName ?? 'Payment',
                  subtitle:
                      '${due.dueTypeLabel} \u20B9${due.amount?.toStringAsFixed(0) ?? '0'}',
                  dotColor: AppThemeData.neonPink,
                  priorityLabel: due.statusLabel,
                  priorityColor: due.statusColor,
                  isDark: isDark,
                  onTap: onDueTap,
                )),

          if (controller.urgentReminders.isNotEmpty)
            ...controller.urgentReminders.take(2).map((reminder) => _TimelineItem(
                  time: _formatReminderTime(reminder),
                  title: reminder.name ?? 'Reminder',
                  subtitle: reminder.isExpired
                      ? 'Expired'
                      : '${reminder.importanceLabel} priority',
                  dotColor: AppThemeData.neonOrange,
                  priorityLabel: reminder.importanceLabel,
                  priorityColor: reminder.importanceColor,
                  isDark: isDark,
                  onTap: onReminderTap,
                )),

          // View All
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View All Tasks',
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 12,
                    color: AppThemeData.neonPurple,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded,
                    size: 14, color: AppThemeData.neonPurple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTaskTime(DateTime? date) {
    if (date == null) return '--:--';
    final h = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final m = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$m\n$period';
  }

  String _formatReminderTime(dynamic reminder) {
    try {
      final date = reminder.expiryDate;
      if (date == null) return '--:--';
      final h = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final m = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '${h.toString().padLeft(2, '0')}:$m\n$period';
    } catch (_) {
      return '--:--';
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.12)
              : AppThemeData.grey3.withValues(alpha: 0.4),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppThemeData.success400.withValues(alpha: 0.18),
                    AppThemeData.neonMint.withValues(alpha: 0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                SolarIconsBold.checkCircle,
                size: 26,
                color: AppThemeData.success400,
              ),
            ),
            const SizedBox(height: 14),
            TextCustom(
              title: 'All clear!',
              fontSize: 15,
              fontFamily: FontFamily.semiBold,
              color: isDark ? AppThemeData.grey2 : AppThemeData.grey9,
            ),
            const SizedBox(height: 4),
            TextCustom(
              title: 'No overdue tasks, pending dues, or urgent alerts.',
              fontSize: 12,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatefulWidget {
  final String time;
  final String title;
  final String subtitle;
  final Color dotColor;
  final String priorityLabel;
  final Color priorityColor;
  final bool isDark;
  final VoidCallback? onTap;

  const _TimelineItem({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.dotColor,
    required this.priorityLabel,
    required this.priorityColor,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _hovered
                  ? (widget.isDark
                      ? AppThemeData.surfaceElevated
                      : AppThemeData.grey2)
                  : (widget.isDark
                      ? AppThemeData.surfaceMid.withValues(alpha: 0.3)
                      : AppThemeData.grey2.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hovered
                    ? widget.dotColor.withValues(alpha: 0.2)
                    : widget.isDark
                        ? AppThemeData.surfaceBorder.withValues(alpha: 0.10)
                        : AppThemeData.grey3.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // Time column
                SizedBox(
                  width: 50,
                  child: Text(
                    widget.time,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontFamily.bold,
                      fontSize: 11,
                      color: widget.isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Dot + line
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: widget.dotColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.dotColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 28,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: widget.dotColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: FontFamily.semiBold,
                          fontSize: 13,
                          color: widget.isDark
                              ? AppThemeData.grey1
                              : AppThemeData.grey10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontFamily: FontFamily.regular,
                          fontSize: 11,
                          color: widget.isDark
                              ? AppThemeData.grey5
                              : AppThemeData.grey6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Priority badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.priorityLabel,
                    style: TextStyle(
                      fontFamily: FontFamily.semiBold,
                      fontSize: 10,
                      color: widget.priorityColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
