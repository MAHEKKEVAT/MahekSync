// lib/app/modules/dashboard/widgets/recent_activity_card.dart
import 'package:flutter/material.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/modules/dashboard/dashboard_models.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class RecentActivityCard extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final VoidCallback? onViewAll;

  const RecentActivityCard({
    super.key,
    required this.controller,
    required this.isDark,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final activities = _buildActivities();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.neonPurple.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
              Icons.history_rounded,
              size: 90,
              color: AppThemeData.neonPurple.withOpacity(0.04),
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
                          color: AppThemeData.neonPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          size: 14,
                          color: AppThemeData.neonPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextCustom(
                        title: 'Recent Activity',
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

              // ── Activity Feed ───────────────────────
              if (activities.isEmpty)
                _EmptyActivity(isDark: isDark)
              else
                ...activities.take(5).map((activity) => _ActivityItem(
                      activity: activity,
                      isDark: isDark,
                    )),
            ],
          ),
        ],
      ),
    );
  }

  List<DashboardActivityModel> _buildActivities() {
    final activities = <DashboardActivityModel>[];
    var i = 0;

    for (final d in controller.latestDevices) {
      activities.add(DashboardActivityModel(
        id: 'dev_$i',
        title: d.deviceName ?? 'New Device',
        description: '${d.brandName ?? ''} - ${d.category ?? ''}',
        icon: Icons.devices_rounded,
        accentColor: AppThemeData.neonTeal,
        timestamp: d.createdAt?.toDate() ?? DateTime.now(),
        category: 'device',
      ));
      i++;
    }

    for (final p in controller.latestPurchases) {
      activities.add(DashboardActivityModel(
        id: 'pur_$i',
        title: p.assetName ?? 'New Purchase',
        description: p.formattedPrice,
        icon: Icons.shopping_bag_rounded,
        accentColor: AppThemeData.neonMint,
        timestamp: DateTime.now(),
        category: 'purchase',
      ));
      i++;
    }

    for (final r in controller.latestReminders) {
      activities.add(DashboardActivityModel(
        id: 'rem_$i',
        title: r.name ?? 'Reminder',
        description: r.importance ?? 'Normal priority',
        icon: Icons.alarm_rounded,
        accentColor: AppThemeData.neonOrange,
        timestamp: r.expiryDate ?? DateTime.now(),
        category: 'reminder',
      ));
      i++;
    }

    for (final t in controller.latestTasks) {
      activities.add(DashboardActivityModel(
        id: 'task_$i',
        title: t.title ?? 'Task',
        description: t.priorityLabel,
        icon: Icons.task_alt_rounded,
        accentColor: AppThemeData.neonPurple,
        timestamp: t.dueDate ?? DateTime.now(),
        category: 'task',
      ));
      i++;
    }

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities;
  }
}

// ─── Activity Item ────────────────────────────────────────────
class _ActivityItem extends StatelessWidget {
  final DashboardActivityModel activity;
  final bool isDark;

  const _ActivityItem({
    required this.activity,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // ── Icon ───────────────────────────────
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: activity.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              activity.icon,
              size: 15,
              color: activity.accentColor,
            ),
          ),
          const SizedBox(width: 10),

          // ── Text ───────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 12,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 10,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── Timestamp ──────────────────────────
          Text(
            activity.timeAgo,
            style: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 9,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────
class _EmptyActivity extends StatelessWidget {
  final bool isDark;
  const _EmptyActivity({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 32,
              color: isDark ? AppThemeData.grey7 : AppThemeData.grey5,
            ),
            const SizedBox(height: 6),
            TextCustom(
              title: 'No recent activity',
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
