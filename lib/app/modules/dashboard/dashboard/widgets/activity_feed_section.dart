import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class ActivityFeedSection extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final VoidCallback? onViewAll;

  const ActivityFeedSection({
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
                        colors: [AppThemeData.neonPurple, AppThemeData.neonBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.history_rounded,
                        size: 18, color: AppThemeData.primaryWhite),
                  ),
                  spaceW(width: 14),
                  TextCustom(
                    title: 'Recent Activity',
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
                    child: TextCustom(
                      title: 'View All',
                      fontSize: 11,
                      fontFamily: FontFamily.medium,
                      color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
                    ),
                  ),
                ),
            ],
          ),
          spaceH(height: 18),

          if (activities.isEmpty)
            _EmptyActivity(isDark: isDark)
          else
            ...activities.take(6).map((a) => _ActivityCard(activity: a, isDark: isDark)),
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
        category: 'New Device',
        imageUrl: imgUrl,
        statusIcon: Icons.arrow_forward_rounded,
        statusColor: AppThemeData.grey5,
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
        category: 'Purchased',
        imageUrl: imgUrl,
        statusIcon: null,
        statusColor: AppThemeData.danger300,
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
        category: 'Reminder',
        imageUrl: null,
        statusIcon: Icons.check_circle_rounded,
        statusColor: AppThemeData.success400,
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
        category: 'Task Completed',
        imageUrl: null,
        statusIcon: Icons.check_circle_rounded,
        statusColor: AppThemeData.success400,
      ));
      i++;
    }

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities;
  }
}

class _ActivityWithImage {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final DateTime timestamp;
  final String category;
  final String? imageUrl;
  final IconData? statusIcon;
  final Color statusColor;

  _ActivityWithImage({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.timestamp,
    required this.category,
    this.imageUrl,
    this.statusIcon,
    required this.statusColor,
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

class _ActivityCard extends StatefulWidget {
  final _ActivityWithImage activity;
  final bool isDark;

  const _ActivityCard({required this.activity, required this.isDark});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _hovered = false;

  void _onHover(bool v) {
    if (_hovered == v) return;
    _hovered = v;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(12),
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
                  ? a.accentColor.withValues(alpha: 0.15)
                  : widget.isDark
                      ? AppThemeData.surfaceBorder.withValues(alpha: 0.10)
                      : AppThemeData.grey3.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Image or icon
              if (a.imageUrl != null && a.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: a.imageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _iconContainer(a),
                    errorWidget: (_, _, _) => _iconContainer(a),
                  ),
                )
              else
                _iconContainer(a),

              spaceW(width: 12),

              // Title + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      title: a.title,
                      fontSize: 12,
                      fontFamily: FontFamily.semiBold,
                      color: widget.isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      maxLine: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    spaceH(height: 3),
                    TextCustom(
                      title: '${a.category} \u00B7 ${a.timeAgo}',
                      fontSize: 10,
                      fontFamily: FontFamily.regular,
                      color: widget.isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      maxLine: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status indicator
              if (a.statusIcon != null)
                Icon(a.statusIcon, size: 18, color: a.statusColor)
              else if (a.id.startsWith('pur_'))
                TextCustom(
                  title: a.description,
                  fontSize: 11,
                  fontFamily: FontFamily.semiBold,
                  color: a.statusColor,
                )
              else
                Icon(Icons.arrow_forward_rounded,
                    size: 16,
                    color: widget.isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconContainer(_ActivityWithImage a) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            a.accentColor.withValues(alpha: 0.15),
            a.accentColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(a.icon, size: 18, color: a.accentColor),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  final bool isDark;
  const _EmptyActivity({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history_rounded,
                size: 32,
                color: isDark ? AppThemeData.grey7 : AppThemeData.grey5),
            spaceH(height: 8),
            TextCustom(
              title: 'No recent activity',
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
