// lib/app/modules/dashboard/widgets/reminder_timeline_card.dart
import 'package:flutter/material.dart';
import 'package:maheksync/app/models/dues_tracker_model.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class ReminderTimelineCard extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final VoidCallback? onViewAll;

  const ReminderTimelineCard({
    super.key,
    required this.controller,
    required this.isDark,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final timelineItems = _buildTimelineItems();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.15)
              : AppThemeData.grey3.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.neonOrange.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Stack(
        children: [
          // ── Blurry Watermark Icon ────────────────
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.event_note_rounded,
              size: 90,
              color: AppThemeData.neonOrange.withValues(alpha: 0.04),
            ),
          ),

          // ── Content ──────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppThemeData.neonOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.event_note_rounded,
                          size: 14,
                          color: AppThemeData.neonOrange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextCustom(
                        title: 'Upcoming Reminders & Dues',
                        fontSize: 15,
                        fontFamily: FontFamily.bold,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                    ],
                  ),
                  if (onViewAll != null)
                    GestureDetector(
                      onTap: onViewAll,
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: FontFamily.medium,
                          fontSize: 11,
                          color: AppThemeData.neonPurple,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Timeline ────────────────────────────
              if (timelineItems.isEmpty)
                _EmptyState(isDark: isDark)
              else
                ...timelineItems.take(5).map((item) => _TimelineItem(
                      item: item,
                      isDark: isDark,
                      isLast: timelineItems.indexOf(item) ==
                          timelineItems.take(5).length - 1,
                    )),
            ],
          ),
        ],
      ),
    );
  }

  List<_TimelineEntry> _buildTimelineItems() {
    final items = <_TimelineEntry>[];

    for (final r in controller.latestReminders) {
      items.add(_TimelineEntry(
        title: r.name ?? 'Reminder',
        category: 'Reminder',
        chipColor: AppThemeData.neonOrange,
        date: r.formattedExpiryDate,
        amount: null,
      ));
    }

    for (final d in controller.latestDues) {
      items.add(_TimelineEntry(
        title: d.customerName ?? 'Due',
        category: d.dueTypeLabel,
        chipColor: DueType.isOwe(d.dueType)
            ? AppThemeData.neonPink
            : AppThemeData.neonMint,
        date: d.shortOweDate,
        amount: d.shortFormattedAmount,
      ));
    }

    for (final t in controller.latestTasks) {
      items.add(_TimelineEntry(
        title: t.title ?? 'Task',
        category: 'Task',
        chipColor: AppThemeData.neonPurple,
        date: t.dueDate?.toString().substring(0, 10) ?? '',
        amount: null,
      ));
    }

    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }
}

// ─── Timeline Item ────────────────────────────────────────────
class _TimelineItem extends StatelessWidget {
  final _TimelineEntry item;
  final bool isDark;
  final bool isLast;

  const _TimelineItem({
    required this.item,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Vertical Connector ─────────────────
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.chipColor,
                    shape: BoxShape.circle,
                    boxShadow: AppThemeData.neonGlow(
                      item.chipColor,
                      blur: 8,
                      opacity: 0.25,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            item.chipColor.withValues(alpha: 0.3),
                            isDark
                                ? AppThemeData.surfaceBorder.withValues(alpha: 0.1)
                                : AppThemeData.grey4.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // ── Content ───────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.surfaceElevated.withValues(alpha: 0.35)
                      : AppThemeData.grey2.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: FontFamily.medium,
                              fontSize: 12,
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
                              _CategoryChip(
                                label: item.category,
                                color: item.chipColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.date,
                                style: TextStyle(
                                  fontFamily: FontFamily.regular,
                                  fontSize: 9,
                                  color: isDark
                                      ? AppThemeData.grey5
                                      : AppThemeData.grey6,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (item.amount != null)
                      Text(
                        item.amount!,
                        style: TextStyle(
                          fontFamily: FontFamily.bold,
                          fontSize: 12,
                          color: item.chipColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Chip ────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: FontFamily.medium,
          fontSize: 8,
          color: color,
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 32,
              color: isDark ? AppThemeData.grey7 : AppThemeData.grey5,
            ),
            const SizedBox(height: 6),
            TextCustom(
              title: 'No upcoming reminders or dues',
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

// ─── Data Model ───────────────────────────────────────────────
class _TimelineEntry {
  final String title;
  final String category;
  final Color chipColor;
  final String date;
  final String? amount;

  _TimelineEntry({
    required this.title,
    required this.category,
    required this.chipColor,
    required this.date,
    this.amount,
  });
}
