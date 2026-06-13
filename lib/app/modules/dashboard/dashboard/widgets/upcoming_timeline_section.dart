// lib/app/modules/dashboard/widgets/upcoming_timeline_section.dart
// ──────────────────────────────────────────────────────────────
//  Totally redesigned Upcoming Reminders & Dues timeline
//  Modern glass card style with gradient icons, bordered cards,
//  neon glow dots, and category chips
// ──────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:maheksync/app/models/dues_tracker_model.dart';
import 'package:maheksync/app/models/reminder_model.dart';
import 'package:maheksync/app/models/personal_task_model.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class UpcomingTimelineSection extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final VoidCallback? onViewAll;

  const UpcomingTimelineSection({
    super.key,
    required this.controller,
    required this.isDark,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final items = _buildTimeline();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.neonOrange.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppThemeData.neonOrange,
                          const Color(0xFFF97316)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: AppThemeData.neonGlow(
                          AppThemeData.neonOrange,
                          blur: 10,
                          opacity: 0.12),
                    ),
                    child: const Icon(Icons.schedule_rounded,
                        size: 17, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  TextCustom(
                    title: 'Upcoming',
                    fontSize: 17,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ],
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppThemeData.neonOrange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            fontFamily: FontFamily.medium,
                            fontSize: 11,
                            color: AppThemeData.neonOrange,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 14, color: AppThemeData.neonOrange),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (items.isEmpty)
            _EmptyTimeline(isDark: isDark)
          else
            ...items.take(6).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isLast = idx >= 5 || idx == items.length - 1;
              return _TimelineCard(
                item: item,
                isDark: isDark,
                isLast: isLast,
              );
            }),
        ],
      ),
    );
  }

  List<_TimelineItem> _buildTimeline() {
    final items = <_TimelineItem>[];

    for (final r in controller.latestReminders) {
      items.add(_TimelineItem(
        title: r.name ?? 'Reminder',
        category: 'Reminder',
        categoryColor: AppThemeData.neonOrange,
        date: r.formattedExpiryDate,
        detail: r.importance ?? '',
        icon: Icons.alarm_rounded,
      ));
    }

    for (final d in controller.latestDues) {
      items.add(_TimelineItem(
        title: d.customerName ?? 'Payment',
        category: d.dueTypeLabel,
        categoryColor: DueType.isOwe(d.dueType)
            ? AppThemeData.neonPink
            : AppThemeData.neonMint,
        date: d.shortOweDate,
        detail: d.shortFormattedAmount,
        icon: Icons.payment_rounded,
      ));
    }

    for (final t in controller.latestTasks) {
      items.add(_TimelineItem(
        title: t.title ?? 'Task',
        category: 'Task',
        categoryColor: AppThemeData.neonPurple,
        date: t.formattedDueDate,
        detail: t.priorityLabel,
        icon: Icons.task_alt_rounded,
      ));
    }

    for (final s in controller.latestSubscriptions) {
      items.add(_TimelineItem(
        title: s.name ?? 'Subscription',
        category: 'Subscription',
        categoryColor: AppThemeData.neonBlue,
        date: '',
        detail: 'Active',
        icon: Icons.subscriptions_rounded,
      ));
    }

    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }
}

// ─── Timeline Card (modern glass card style) ────────────────
class _TimelineCard extends StatelessWidget {
  final _TimelineItem item;
  final bool isDark;
  final bool isLast;

  const _TimelineCard({
    required this.item,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 44,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.categoryColor,
                    shape: BoxShape.circle,
                    boxShadow: AppThemeData.neonGlow(item.categoryColor,
                        blur: 8, opacity: 0.25),
                  ),
                ),
                // Connector
                if (!isLast)
                  Container(
                    width: 2,
                    height: 36,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          item.categoryColor.withOpacity(0.3),
                          isDark
                              ? AppThemeData.surfaceBorder.withOpacity(0.06)
                              : AppThemeData.grey3.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Content Card
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeData.surfaceElevated.withOpacity(0.4)
                    : AppThemeData.grey2.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: item.categoryColor.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          item.categoryColor.withOpacity(0.15),
                          item.categoryColor.withOpacity(0.05)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon,
                        size: 15, color: item.categoryColor),
                  ),
                  const SizedBox(width: 10),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontFamily: FontFamily.semiBold,
                            fontSize: 12.5,
                            color: isDark
                                ? AppThemeData.grey1
                                : AppThemeData.grey10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            // Category chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    item.categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                item.category,
                                style: TextStyle(
                                  fontFamily: FontFamily.semiBold,
                                  fontSize: 8,
                                  color: item.categoryColor,
                                ),
                              ),
                            ),
                            if (item.date.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.access_time_rounded,
                                  size: 10,
                                  color: isDark
                                      ? AppThemeData.grey6
                                      : AppThemeData.grey5),
                              const SizedBox(width: 3),
                              Text(
                                item.date,
                                style: TextStyle(
                                  fontFamily: FontFamily.regular,
                                  fontSize: 9,
                                  color: isDark
                                      ? AppThemeData.grey6
                                      : AppThemeData.grey5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Amount / priority
                  if (item.detail.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.categoryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.detail,
                        style: TextStyle(
                          fontFamily: FontFamily.bold,
                          fontSize: 11,
                          color: item.categoryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty ──────────────────────────────────────────────────
class _EmptyTimeline extends StatelessWidget {
  final bool isDark;
  const _EmptyTimeline({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_available_rounded,
                size: 32,
                color: isDark ? AppThemeData.grey7 : AppThemeData.grey5),
            const SizedBox(height: 8),
            TextCustom(
              title: 'Nothing upcoming',
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

// ─── Data Model ─────────────────────────────────────────────
class _TimelineItem {
  final String title;
  final String category;
  final Color categoryColor;
  final String date;
  final String detail;
  final IconData icon;

  _TimelineItem({
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.date,
    required this.detail,
    required this.icon,
  });
}
