import 'package:flutter/material.dart';
import 'package:maheksync/app/models/dues_tracker_model.dart';
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemeData.neonOrange, const Color(0xFFF97316)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.schedule_rounded,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  TextCustom(
                    title: 'Upcoming Timeline',
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
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppThemeData.surfaceElevated.withValues(alpha: 0.5)
                          : AppThemeData.grey2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AppThemeData.surfaceBorder.withValues(alpha: 0.2)
                            : AppThemeData.grey3.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'View Calendar',
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 11,
                        color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          if (items.isEmpty)
            _EmptyTimeline(isDark: isDark)
          else
            ...items.take(6).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isLast = idx >= 5 || idx == items.length - 1;
              return _TimelineCard(item: item, isDark: isDark, isLast: isLast);
            }),

          // View full timeline
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Full Timeline',
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
        ],
      ),
    );
  }

  List<_TimelineItem> _buildTimeline() {
    final items = <_TimelineItem>[];

    for (final r in controller.latestReminders) {
      items.add(_TimelineItem(
        title: r.name ?? 'Reminder',
        subtitle: r.importance ?? 'Normal',
        date: r.formattedExpiryDate,
        time: _formatTime(r.expiryDate),
        dateLabel: _formatDateLabel(r.expiryDate),
        color: AppThemeData.neonOrange,
        icon: Icons.alarm_rounded,
      ));
    }

    for (final d in controller.latestDues) {
      items.add(_TimelineItem(
        title: d.customerName ?? 'Payment',
        subtitle: d.shortFormattedAmount,
        date: d.shortOweDate,
        time: '--:--',
        dateLabel: d.shortOweDate,
        color: DueType.isOwe(d.dueType)
            ? AppThemeData.neonPink
            : AppThemeData.neonMint,
        icon: Icons.payment_rounded,
      ));
    }

    for (final t in controller.latestTasks) {
      items.add(_TimelineItem(
        title: t.title ?? 'Task',
        subtitle: t.priorityLabel,
        date: t.formattedDueDate,
        time: _formatTime(t.dueDate),
        dateLabel: _formatDateLabel(t.dueDate),
        color: AppThemeData.neonPurple,
        icon: Icons.task_alt_rounded,
      ));
    }

    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '--:--';
    final h = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final m = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
  }

  String _formatDateLabel(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 7) return '${date.day} ${_monthName(date.month)}';
    return '${date.day} ${_monthName(date.month)}';
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _TimelineCard extends StatefulWidget {
  final _TimelineItem item;
  final bool isDark;
  final bool isLast;

  const _TimelineCard({
    required this.item,
    required this.isDark,
    this.isLast = false,
  });

  @override
  State<_TimelineCard> createState() => _TimelineCardState();
}

class _TimelineCardState extends State<_TimelineCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered
                ? (widget.isDark
                    ? AppThemeData.surfaceElevated
                    : AppThemeData.grey2)
                : (widget.isDark
                    ? AppThemeData.surfaceMid.withValues(alpha: 0.35)
                    : AppThemeData.grey2.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? item.color.withValues(alpha: 0.2)
                  : widget.isDark
                      ? AppThemeData.surfaceBorder.withValues(alpha: 0.10)
                      : AppThemeData.grey3.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Date column
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.dateLabel,
                      style: TextStyle(
                        fontFamily: FontFamily.semiBold,
                        fontSize: 11,
                        color: widget.isDark ? AppThemeData.grey3 : AppThemeData.grey8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.date,
                      style: TextStyle(
                        fontFamily: FontFamily.regular,
                        fontSize: 10,
                        color: widget.isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                      ),
                    ),
                  ],
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
                      color: item.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  if (!widget.isLast)
                    Container(
                      width: 2,
                      height: 30,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
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
                      item.title,
                      style: TextStyle(
                        fontFamily: FontFamily.semiBold,
                        fontSize: 13,
                        color: widget.isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontFamily: FontFamily.regular,
                        fontSize: 11,
                        color: widget.isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Time
              Text(
                item.time,
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 11,
                  color: widget.isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  final bool isDark;
  const _EmptyTimeline({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_available_rounded,
                size: 36,
                color: isDark ? AppThemeData.grey7 : AppThemeData.grey5),
            const SizedBox(height: 10),
            TextCustom(
              title: 'Nothing upcoming',
              fontSize: 13,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem {
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String dateLabel;
  final Color color;
  final IconData icon;

  _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.dateLabel,
    required this.color,
    required this.icon,
  });
}
