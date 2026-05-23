import 'package:flutter/material.dart';
import 'package:maheksync/app/utils/app_colors.dart';

class DashboardMetricModel {
  final String id;
  final String title;
  final int value;
  final int? maxValue;
  final IconData icon;
  final Color accentColor;
  final Color dimColor;
  final String subtitle;
  final double trend;
  final List<double> sparkline;
  final String route;

  const DashboardMetricModel({
    required this.id,
    required this.title,
    this.value = 0,
    this.maxValue,
    required this.icon,
    required this.accentColor,
    required this.dimColor,
    this.subtitle = '',
    this.trend = 0,
    this.sparkline = const [],
    this.route = '',
  });
}

class DashboardActivityModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final DateTime timestamp;
  final String category;

  const DashboardActivityModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.icon,
    required this.accentColor,
    required this.timestamp,
    this.category = 'general',
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class DashboardChartModel {
  final String id;
  final String title;
  final ChartType type;
  final List<ChartDataPoint> data;
  final Color accentColor;
  final Color dimColor;

  const DashboardChartModel({
    required this.id,
    required this.title,
    required this.type,
    this.data = const [],
    required this.accentColor,
    required this.dimColor,
  });
}

enum ChartType { line, area, donut, bar, radial }

class ChartDataPoint {
  final String label;
  final double value;
  final Color? color;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.color,
  });
}

class AIInsightModel {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final IconData icon;
  final Color accentColor;
  final String actionLabel;
  final String route;

  const AIInsightModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.type,
    required this.icon,
    required this.accentColor,
    this.actionLabel = 'View',
    this.route = '',
  });
}

enum InsightType { reminder, overdue, suggestion, alert, score, task }

class QuickActionModel {
  final String id;
  final String title;
  final IconData icon;
  final Color accentColor;
  final String route;

  const QuickActionModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.accentColor,
    this.route = '',
  });
}

class ProfileSystemModel {
  final String userName;
  final String email;
  final String? avatarUrl;
  final int totalDevices;
  final int storageUsedMB;
  final int storageTotalMB;
  final int aiScore;
  final int activeSessions;
  final List<ConnectedService> services;

  const ProfileSystemModel({
    this.userName = 'Admin',
    this.email = '',
    this.avatarUrl,
    this.totalDevices = 0,
    this.storageUsedMB = 0,
    this.storageTotalMB = 5120,
    this.aiScore = 0,
    this.activeSessions = 1,
    this.services = const [],
  });

  double get storagePercent => storageTotalMB > 0 ? storageUsedMB / storageTotalMB : 0;
}

class ConnectedService {
  final String name;
  final IconData icon;
  final Color color;
  final bool isConnected;

  const ConnectedService({
    required this.name,
    required this.icon,
    required this.color,
    this.isConnected = false,
  });
}

List<DashboardMetricModel> defaultMetrics = [
  DashboardMetricModel(
    id: 'tasks',
    title: 'Total Tasks',
    icon: Icons.task_alt_rounded,
    accentColor: AppThemeData.neonPurple,
    dimColor: AppThemeData.neonPurpleDim,
    subtitle: 'Active tasks',
    sparkline: [3, 5, 4, 7, 6, 8, 7],
    route: '/dashboard/personal-tasks',
  ),
  DashboardMetricModel(
    id: 'reminders',
    title: 'Reminders',
    icon: Icons.alarm_rounded,
    accentColor: AppThemeData.neonOrange,
    dimColor: AppThemeData.neonOrangeDim,
    subtitle: 'Upcoming',
    sparkline: [2, 4, 3, 5, 6, 4, 5],
    route: '/dashboard/reminders',
  ),
  DashboardMetricModel(
    id: 'devices',
    title: 'Devices',
    icon: Icons.devices_rounded,
    accentColor: AppThemeData.neonTeal,
    dimColor: AppThemeData.neonTealDim,
    subtitle: 'Connected',
    sparkline: [1, 1, 2, 2, 3, 3, 4],
    route: '/dashboard/my-devices',
  ),
  DashboardMetricModel(
    id: 'purchases',
    title: 'Purchases',
    icon: Icons.shopping_bag_rounded,
    accentColor: AppThemeData.neonMint,
    dimColor: AppThemeData.neonMintDim,
    subtitle: 'This month',
    sparkline: [5, 8, 6, 9, 7, 10, 8],
    route: '/dashboard/my-purchases',
  ),
  DashboardMetricModel(
    id: 'dues',
    title: 'Dues Tracker',
    icon: Icons.account_balance_wallet_rounded,
    accentColor: AppThemeData.neonPink,
    dimColor: AppThemeData.neonPinkDim,
    subtitle: 'Pending',
    sparkline: [4, 3, 5, 2, 4, 3, 2],
    route: '/dues-tracker',
  ),
  DashboardMetricModel(
    id: 'notifications',
    title: 'Notifications',
    icon: Icons.notifications_rounded,
    accentColor: AppThemeData.neonYellow,
    dimColor: AppThemeData.neonOrangeDim,
    subtitle: 'Unread',
    sparkline: [2, 5, 3, 7, 4, 6, 3],
  ),
  DashboardMetricModel(
    id: 'vault',
    title: 'Memory Vault',
    icon: Icons.shield_rounded,
    accentColor: AppThemeData.neonLavender,
    dimColor: AppThemeData.neonPurpleDim,
    subtitle: 'Encrypted items',
    sparkline: [6, 7, 8, 9, 10, 11, 12],
  ),
  DashboardMetricModel(
    id: 'ai_memory',
    title: 'AI Memory',
    icon: Icons.psychology_rounded,
    accentColor: AppThemeData.neonBlue,
    dimColor: AppThemeData.neonBlueDim,
    subtitle: 'Active entries',
    sparkline: [1, 3, 5, 7, 9, 11, 14],
  ),
];

List<QuickActionModel> defaultQuickActions = [
  QuickActionModel(id: 'add_task', title: 'Add Task', icon: Icons.add_task_rounded, accentColor: AppThemeData.neonPurple),
  QuickActionModel(id: 'add_reminder', title: 'Add Reminder', icon: Icons.alarm_add_rounded, accentColor: AppThemeData.neonOrange),
  QuickActionModel(id: 'add_device', title: 'Add Device', icon: Icons.add_circle_rounded, accentColor: AppThemeData.neonTeal),
  QuickActionModel(id: 'add_purchase', title: 'Add Purchase', icon: Icons.add_shopping_cart_rounded, accentColor: AppThemeData.neonMint),
  QuickActionModel(id: 'create_note', title: 'Create Note', icon: Icons.note_add_rounded, accentColor: AppThemeData.neonLavender),
  QuickActionModel(id: 'scan_memory', title: 'Scan Memory', icon: Icons.document_scanner_rounded, accentColor: AppThemeData.neonBlue),
];
