// lib/app/modules/dashboard/widgets/activity_feed_section.dart
// ──────────────────────────────────────────────────────────────
//  Totally redesigned Recent Activity feed
//  Shows images when available (devices, purchases)
//  Modern glass card rows with image/avatar support
// ──────────────────────────────────────────────────────────────
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class ActivityFeedSection extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const ActivityFeedSection({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activities = _buildActivities();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.neonPurple.withOpacity(0.03),
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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppThemeData.neonPurple, AppThemeData.neonBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: AppThemeData.neonGlow(AppThemeData.neonPurple,
                      blur: 10, opacity: 0.12),
                ),
                child: const Icon(Icons.history_rounded,
                    size: 17, color: Colors.white),
              ),
              const SizedBox(width: 12),
              TextCustom(
                title: 'Recent Activity',
                fontSize: 17,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (activities.isEmpty)
            _EmptyActivity(isDark: isDark)
          else
            ...activities
                .take(6)
                .map((a) => _ActivityCard(activity: a, isDark: isDark)),
        ],
      ),
    );
  }

  List<_ActivityWithImage> _buildActivities() {
    final activities = <_ActivityWithImage>[];
    var i = 0;

    for (final d in controller.latestDevices) {
      String? imgUrl;
      if (d.deviceImageUrls != null && d.deviceImageUrls!.isNotEmpty) {
        imgUrl = d.deviceImageUrls!.first;
      }
      activities.add(_ActivityWithImage(
        id: 'dev_$i',
        title: d.deviceName ?? 'New Device',
        description: '${d.brandName ?? ''} ${d.category ?? ''}'.trim(),
        icon: Icons.devices_rounded,
        accentColor: AppThemeData.neonTeal,
        timestamp: d.createdAt?.toDate() ?? DateTime.now(),
        category: 'device',
        imageUrl: imgUrl,
      ));
      i++;
    }

    for (final p in controller.latestPurchases) {
      String? imgUrl;
      if (p.imageUrls != null && p.imageUrls!.isNotEmpty) {
        imgUrl = p.imageUrls!.first;
      }
      activities.add(_ActivityWithImage(
        id: 'pur_$i',
        title: p.assetName ?? 'New Purchase',
        description: p.formattedPrice,
        icon: Icons.shopping_bag_rounded,
        accentColor: AppThemeData.neonMint,
        timestamp: DateTime.now(),
        category: 'purchase',
        imageUrl: imgUrl,
      ));
      i++;
    }

    for (final r in controller.latestReminders) {
      activities.add(_ActivityWithImage(
        id: 'rem_$i',
        title: r.name ?? 'Reminder',
        description: r.importance ?? 'Normal',
        icon: Icons.alarm_rounded,
        accentColor: AppThemeData.neonOrange,
        timestamp: r.expiryDate ?? DateTime.now(),
        category: 'reminder',
        imageUrl: null,
      ));
      i++;
    }

    for (final t in controller.latestTasks) {
      activities.add(_ActivityWithImage(
        id: 'task_$i',
        title: t.title ?? 'Task',
        description: t.priorityLabel,
        icon: Icons.task_alt_rounded,
        accentColor: AppThemeData.neonPurple,
        timestamp: t.dueDate ?? DateTime.now(),
        category: 'task',
        imageUrl: null,
      ));
      i++;
    }

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities;
  }
}

// ─── Activity Model with Image ──────────────────────────────
class _ActivityWithImage {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final DateTime timestamp;
  final String category;
  final String? imageUrl;

  _ActivityWithImage({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.timestamp,
    required this.category,
    this.imageUrl,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

// ─── Activity Card (with image support) ─────────────────────
class _ActivityCard extends StatelessWidget {
  final _ActivityWithImage activity;
  final bool isDark;

  const _ActivityCard({required this.activity, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? AppThemeData.surfaceElevated.withOpacity(0.3)
              : AppThemeData.grey2.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: activity.accentColor.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Image or Icon
            if (activity.imageUrl != null &&
                activity.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: activity.imageUrl!,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: activity.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(activity.icon,
                        size: 18, color: activity.accentColor),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: activity.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(activity.icon,
                        size: 18, color: activity.accentColor),
                  ),
                ),
              )
            else
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activity.accentColor.withOpacity(0.15),
                      activity.accentColor.withOpacity(0.05)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(activity.icon,
                    size: 18, color: activity.accentColor),
              ),

            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontFamily: FontFamily.semiBold,
                      fontSize: 12,
                      color:
                          isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontFamily: FontFamily.regular,
                      fontSize: 10,
                      color:
                          isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Category badge + Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: activity.accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    activity.category,
                    style: TextStyle(
                      fontFamily: FontFamily.medium,
                      fontSize: 8,
                      color: activity.accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.timeAgo,
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 9,
                    color:
                        isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty ──────────────────────────────────────────────────
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
            Icon(Icons.history_rounded,
                size: 28,
                color: isDark ? AppThemeData.grey7 : AppThemeData.grey5),
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
