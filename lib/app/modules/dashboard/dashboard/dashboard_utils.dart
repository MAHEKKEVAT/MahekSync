import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maheksync/app/constant/collection_name.dart';
import 'package:maheksync/app/utils/app_colors.dart';

import 'dashboard_models.dart';

class DashboardUtils {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static String? _uid;

  static String? get uid {
    _uid ??= FirebaseAuth.instance.currentUser?.uid;
    return _uid;
  }

  static void resetUid() {
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  static Stream<int> streamCount(String collection) {
    if (uid == null) return Stream.value(0);
    return _db
        .collection(collection)
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.length);
  }

  static Stream<int> streamDevicesCount() => streamCount('devices');

  static Stream<int> streamTasksCount() {
    if (uid == null) return Stream.value(0);
    return _db
        .collection('personal_tasks')
        .where('ownerId', isEqualTo: uid)
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  static Stream<int> streamRemindersCount() {
    if (uid == null) return Stream.value(0);
    return _db
        .collection('reminders')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.length);
  }

  static Stream<int> streamPurchasesCount() => streamCount('purchases');

  static Stream<int> streamDuesCount() {
    if (uid == null) return Stream.value(0);
    return _db
        .collection(CollectionName.duesTracker)
        .where('ownerId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.length);
  }

  static Stream<int> streamNotificationsCount() {
    if (uid == null) return Stream.value(0);
    return _db
        .collection(CollectionName.notification)
        .where('ownerId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length)
        .handleError((_) => 0);
  }

  static Stream<int> streamVaultCount() => streamCount('vault');

  static Stream<int> streamSentinelCount() {
    if (uid == null) return Stream.value(0);
    return _db
        .collection(CollectionName.sentinelAccess)
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.length);
  }

  static Stream<List<DashboardMetricModel>> streamMetrics() {
    final controller = StreamController<List<DashboardMetricModel>>();
    int tasks = 0, reminders = 0, devices = 0, purchases = 0, dues = 0, notifications = 0, vault = 0;

    void emit() {
      final base = defaultMetrics;
      controller.add([
        base[0].copyWith(value: tasks),
        base[1].copyWith(value: reminders),
        base[2].copyWith(value: devices),
        base[3].copyWith(value: purchases),
        base[4].copyWith(value: dues),
        base[5].copyWith(value: notifications),
        base[6].copyWith(value: vault),
        base[7].copyWith(value: vault + tasks),
      ]);
    }

    final subs = <StreamSubscription>[];
    subs.add(streamTasksCount().listen((v) { tasks = v; emit(); }));
    subs.add(streamRemindersCount().listen((v) { reminders = v; emit(); }));
    subs.add(streamDevicesCount().listen((v) { devices = v; emit(); }));
    subs.add(streamPurchasesCount().listen((v) { purchases = v; emit(); }));
    subs.add(streamDuesCount().listen((v) { dues = v; emit(); }));
    subs.add(streamNotificationsCount().listen((v) { notifications = v; emit(); }));
    subs.add(streamVaultCount().listen((v) { vault = v; emit(); }));

    controller.onCancel = () {
      for (final s in subs) { s.cancel(); }
    };

    return controller.stream;
  }

  static Stream<List<DashboardActivityModel>> streamActivity() {
    if (uid == null) return Stream.value([]);
    return _db
        .collection('personal_tasks')
        .where('ownerId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return DashboardActivityModel(
          id: doc.id,
          title: data['title'] ?? 'Task',
          description: data['description'] ?? '',
          icon: Icons.task_alt_rounded,
          accentColor: AppThemeData.neonPurple,
          timestamp: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          category: 'task',
        );
      }).toList();
    }).handleError((_) => <DashboardActivityModel>[]);
  }

  static List<DashboardChartModel> generateChartModels() {
    final random = Random(42);
    List<double> monthlyExpenses = List.generate(12, (_) => random.nextDouble() * 5000 + 500);
    List<double> monthlyTasks = List.generate(12, (_) => random.nextDouble() * 40 + 5);

    return [
      DashboardChartModel(
        id: 'expenses',
        title: 'Monthly Expenses',
        type: ChartType.area,
        data: List.generate(12, (i) => ChartDataPoint(
          label: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][i],
          value: monthlyExpenses[i],
        )),
        accentColor: AppThemeData.neonMint,
        dimColor: AppThemeData.neonMintDim,
      ),
      DashboardChartModel(
        id: 'tasks_completed',
        title: 'Tasks Completed',
        type: ChartType.line,
        data: List.generate(12, (i) => ChartDataPoint(
          label: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][i],
          value: monthlyTasks[i],
        )),
        accentColor: AppThemeData.neonPurple,
        dimColor: AppThemeData.neonPurpleDim,
      ),
      DashboardChartModel(
        id: 'category_breakdown',
        title: 'Category Breakdown',
        type: ChartType.donut,
        data: [
          ChartDataPoint(label: 'Tasks', value: 35, color: AppThemeData.neonPurple),
          ChartDataPoint(label: 'Reminders', value: 25, color: AppThemeData.neonOrange),
          ChartDataPoint(label: 'Purchases', value: 20, color: AppThemeData.neonMint),
          ChartDataPoint(label: 'Devices', value: 12, color: AppThemeData.neonTeal),
          ChartDataPoint(label: 'Vault', value: 8, color: AppThemeData.neonPink),
        ],
        accentColor: AppThemeData.neonPurple,
        dimColor: AppThemeData.neonPurpleDim,
      ),
      DashboardChartModel(
        id: 'productivity',
        title: 'Productivity Score',
        type: ChartType.radial,
        data: [
          ChartDataPoint(label: 'Score', value: 78),
        ],
        accentColor: AppThemeData.neonBlue,
        dimColor: AppThemeData.neonBlueDim,
      ),
    ];
  }

  static List<AIInsightModel> generateInsights(int tasksCount, int duesCount, int remindersCount) {
    return [
      AIInsightModel(
        id: 'overdue_dues',
        title: 'Overdue Dues',
        description: 'You have $duesCount pending dues that need attention.',
        type: InsightType.overdue,
        icon: Icons.warning_amber_rounded,
        accentColor: AppThemeData.neonPink,
        route: '/dues-tracker',
      ),
      AIInsightModel(
        id: 'pending_tasks',
        title: 'Pending Tasks',
        description: '$tasksCount tasks awaiting completion. Prioritize your top items.',
        type: InsightType.task,
        icon: Icons.task_alt_rounded,
        accentColor: AppThemeData.neonPurple,
        route: '/dashboard/personal-tasks',
      ),
      AIInsightModel(
        id: 'upcoming_reminders',
        title: 'Upcoming Reminders',
        description: '$remindersCount reminders scheduled. Stay on track.',
        type: InsightType.reminder,
        icon: Icons.alarm_rounded,
        accentColor: AppThemeData.neonOrange,
        route: '/dashboard/reminders',
      ),
      AIInsightModel(
        id: 'ai_suggestion',
        title: 'AI Suggestion',
        description: 'Consider archiving completed tasks older than 30 days for better performance.',
        type: InsightType.suggestion,
        icon: Icons.auto_awesome_rounded,
        accentColor: AppThemeData.neonBlue,
      ),
      AIInsightModel(
        id: 'productivity_score',
        title: 'Productivity Score',
        description: 'Your productivity is ${tasksCount > 5 ? "above" : "below"} average this week. ${tasksCount > 5 ? "Keep it up!" : "Try focusing on top priorities."}',
        type: InsightType.score,
        icon: Icons.trending_up_rounded,
        accentColor: AppThemeData.neonMint,
      ),
      AIInsightModel(
        id: 'vault_security',
        title: 'Vault Security',
        description: 'All vault entries are encrypted. Sentinel protection is active.',
        type: InsightType.alert,
        icon: Icons.shield_rounded,
        accentColor: AppThemeData.neonLavender,
      ),
    ];
  }

  static ProfileSystemModel generateProfile() {
    return const ProfileSystemModel(
      userName: 'Admin',
      email: 'admin@maheksync.ai',
      totalDevices: 0,
      storageUsedMB: 256,
      storageTotalMB: 5120,
      aiScore: 87,
      activeSessions: 1,
      services: [
        ConnectedService(name: 'Firebase', icon: Icons.cloud_rounded, color: AppThemeData.neonOrange, isConnected: true),
        ConnectedService(name: 'ImageKit', icon: Icons.image_rounded, color: AppThemeData.neonBlue, isConnected: true),
        ConnectedService(name: 'Sentinel', icon: Icons.security_rounded, color: AppThemeData.neonPurple, isConnected: true),
      ],
    );
  }
}

extension DashboardMetricModelCopy on DashboardMetricModel {
  DashboardMetricModel copyWith({
    String? id,
    String? title,
    int? value,
    int? maxValue,
    IconData? icon,
    Color? accentColor,
    Color? dimColor,
    String? subtitle,
    double? trend,
    List<double>? sparkline,
    String? route,
  }) {
    return DashboardMetricModel(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      maxValue: maxValue ?? this.maxValue,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
      dimColor: dimColor ?? this.dimColor,
      subtitle: subtitle ?? this.subtitle,
      trend: trend ?? this.trend,
      sparkline: sparkline ?? this.sparkline,
      route: route ?? this.route,
    );
  }
}
