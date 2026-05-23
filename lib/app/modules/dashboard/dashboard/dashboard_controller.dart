import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'dashboard_models.dart';
import 'dashboard_utils.dart';

class DashboardHomeController extends GetxController with GetTickerProviderStateMixin {
  var metrics = <DashboardMetricModel>[].obs;
  var activities = <DashboardActivityModel>[].obs;
  var charts = <DashboardChartModel>[].obs;
  var insights = <AIInsightModel>[].obs;
  var profile = ProfileSystemModel().obs;
  var quickActions = defaultQuickActions.obs;

  var isLoading = true.obs;
  var isOrbPulsing = true.obs;
  var heroVisible = false.obs;

  late AnimationController orbCtrl;
  late AnimationController glowCtrl;
  late AnimationController shimmerCtrl;
  late AnimationController fadeCtrl;

  Stream? _metricsStream;
  StreamSubscription? _metricsSub;
  StreamSubscription? _activitySub;

  @override
  void onInit() {
    super.onInit();
    DashboardUtils.resetUid();

    orbCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(reverse: true);
    shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _loadData();
    _startStreams();

    Future.delayed(const Duration(milliseconds: 300), () {
      heroVisible.value = true;
      fadeCtrl.forward();
    });
  }

  void _loadData() {
    charts.value = DashboardUtils.generateChartModels();
    profile.value = DashboardUtils.generateProfile();
    isLoading.value = false;
  }

  void _startStreams() {
    _metricsSub = DashboardUtils.streamMetrics().listen((data) {
      metrics.value = data;
      _updateInsights();
    });

    _activitySub = DashboardUtils.streamActivity().listen((data) {
      activities.value = data;
    });
  }

  void _updateInsights() {
    int tasks = 0, dues = 0, reminders = 0;
    for (var m in metrics) {
      if (m.id == 'tasks') tasks = m.value;
      if (m.id == 'dues') dues = m.value;
      if (m.id == 'reminders') reminders = m.value;
    }
    insights.value = DashboardUtils.generateInsights(tasks, dues, reminders);
  }

  void onQuickAction(QuickActionModel action) {
    if (action.route.isNotEmpty) {
      Get.toNamed(action.route);
    }
  }

  void onMetricTap(DashboardMetricModel metric) {
    if (metric.route.isNotEmpty) {
      Get.toNamed(metric.route);
    }
  }

  void onInsightTap(AIInsightModel insight) {
    if (insight.route.isNotEmpty) {
      Get.toNamed(insight.route);
    }
  }

  @override
  void onClose() {
    orbCtrl.dispose();
    glowCtrl.dispose();
    shimmerCtrl.dispose();
    fadeCtrl.dispose();
    _metricsSub?.cancel();
    _activitySub?.cancel();
    super.onClose();
  }
}
