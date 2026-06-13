// lib/app/modules/dashboard/widgets/dashboard_graphs_section.dart
// ──────────────────────────────────────────────────────────────
//  8 Graph/Chart widgets using fl_chart
//  All data from DashboardHomeController — no dummy values
// ──────────────────────────────────────────────────────────────
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:maheksync/app/models/dues_tracker_model.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class DashboardGraphsSection extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const DashboardGraphsSection({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                gradient: AppThemeData.neonPurpleBlueGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.analytics_rounded,
                size: 16, color: AppThemeData.neonCyan.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text(
              'Analytics & Graphs',
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 15,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Graph Grid (2 columns)
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                // 1. This Month Purchases
                SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 14) / 2
                      : constraints.maxWidth,
                  child: _MiniGraphCard(
                    title: 'This Month Purchases',
                    value: _monthPurchaseCount(),
                    subtitle: _monthPurchaseTotal(),
                    icon: Icons.shopping_cart_rounded,
                    accentColor: AppThemeData.neonMint,
                    isDark: isDark,
                    chart: _PurchaseBarChart(
                        controller: controller, isDark: isDark),
                  ),
                ),
                // 2. This Month Dues
                SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 14) / 2
                      : constraints.maxWidth,
                  child: _MiniGraphCard(
                    title: 'This Month Dues',
                    value: _monthDueCount(),
                    subtitle: _monthDueTotal(),
                    icon: Icons.account_balance_wallet_rounded,
                    accentColor: AppThemeData.neonPink,
                    isDark: isDark,
                    chart: _DuesBarChart(
                        controller: controller, isDark: isDark),
                  ),
                ),
                // 3. Device Categories
                SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 14) / 2
                      : constraints.maxWidth,
                  child: _MiniGraphCard(
                    title: 'Device Categories',
                    value: controller.deviceCount.value.toString(),
                    subtitle: 'Total devices',
                    icon: Icons.devices_rounded,
                    accentColor: AppThemeData.neonTeal,
                    isDark: isDark,
                    chart: _CategoryDonutChart(
                        controller: controller, isDark: isDark),
                  ),
                ),
                // 4. Task Priority
                SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 14) / 2
                      : constraints.maxWidth,
                  child: _MiniGraphCard(
                    title: 'Task Priority',
                    value: controller.taskCount.value.toString(),
                    subtitle: 'Total tasks',
                    icon: Icons.task_alt_rounded,
                    accentColor: AppThemeData.neonPurple,
                    isDark: isDark,
                    chart: _TaskPriorityChart(
                        controller: controller, isDark: isDark),
                  ),
                ),
                // 5. Dues Breakdown
                SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 14) / 2
                      : constraints.maxWidth,
                  child: _MiniGraphCard(
                    title: 'Dues Breakdown',
                    value: controller.duesCount.value.toString(),
                    subtitle: 'Total dues',
                    icon: Icons.compare_arrows_rounded,
                    accentColor: AppThemeData.neonOrange,
                    isDark: isDark,
                    chart: _DueTypeChart(
                        controller: controller, isDark: isDark),
                  ),
                ),
                // 6. Reminders by Importance
                SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 14) / 2
                      : constraints.maxWidth,
                  child: _MiniGraphCard(
                    title: 'Reminders by Importance',
                    value: controller.reminderCount.value.toString(),
                    subtitle: 'Total reminders',
                    icon: Icons.alarm_rounded,
                    accentColor: AppThemeData.neonOrange,
                    isDark: isDark,
                    chart: _ReminderImportanceChart(
                        controller: controller, isDark: isDark),
                  ),
                ),
                // 7. Subscriptions
                SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 14) / 2
                      : constraints.maxWidth,
                  child: _MiniGraphCard(
                    title: 'Subscriptions',
                    value: controller.subscriptionCount.value.toString(),
                    subtitle: 'Active services',
                    icon: Icons.subscriptions_rounded,
                    accentColor: AppThemeData.neonBlue,
                    isDark: isDark,
                    chart: _SubscriptionRadialChart(
                        controller: controller, isDark: isDark),
                  ),
                ),
                // 8. Security Score
                SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 14) / 2
                      : constraints.maxWidth,
                  child: _MiniGraphCard(
                    title: 'Security Score',
                    value: _securityScore().toString(),
                    subtitle: _securityScore() >= 80
                        ? 'Protected'
                        : 'Needs attention',
                    icon: Icons.shield_rounded,
                    accentColor: _securityScore() >= 80
                        ? AppThemeData.neonMint
                        : AppThemeData.neonOrange,
                    isDark: isDark,
                    chart: _SecurityGaugeChart(
                        score: _securityScore(), isDark: isDark),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Data helpers ───────────────────────────────────────────
  String _monthPurchaseCount() {
    final now = DateTime.now();
    int count = 0;
    for (final p in controller.latestPurchases) {
      if (p.createdAt != null &&
          p.createdAt!.toDate().month == now.month &&
          p.createdAt!.toDate().year == now.year) {
        count++;
      }
    }
    return count.toString();
  }

  String _monthPurchaseTotal() {
    final now = DateTime.now();
    double total = 0;
    for (final p in controller.latestPurchases) {
      if (p.createdAt != null &&
          p.createdAt!.toDate().month == now.month &&
          p.createdAt!.toDate().year == now.year &&
          p.price != null) {
        total += p.price!;
      }
    }
    if (total >= 100000) return '${(total / 100000).toStringAsFixed(1)}L';
    if (total >= 1000) return '${(total / 1000).toStringAsFixed(1)}K';
    return total.toStringAsFixed(0);
  }

  String _monthDueCount() {
    final now = DateTime.now();
    int count = 0;
    for (final d in controller.latestDues) {
      if (d.oweDate != null &&
          d.oweDate!.month == now.month &&
          d.oweDate!.year == now.year) {
        count++;
      }
    }
    return count.toString();
  }

  String _monthDueTotal() {
    final now = DateTime.now();
    double total = 0;
    for (final d in controller.latestDues) {
      if (d.oweDate != null &&
          d.oweDate!.month == now.month &&
          d.oweDate!.year == now.year &&
          d.amount != null) {
        total += d.amount!;
      }
    }
    if (total >= 100000) return '${(total / 100000).toStringAsFixed(1)}L';
    if (total >= 1000) return '${(total / 1000).toStringAsFixed(1)}K';
    return total.toStringAsFixed(0);
  }

  int _securityScore() {
    int score = 0;
    if (controller.sentinelPasswordSet.value) score += 40;
    if (!controller.sentinelLocked.value) score += 20;
    if (controller.deviceCount.value > 0) score += 15;
    if (controller.vaultCount.value > 0) score += 15;
    if (controller.contactCount.value > 0) score += 10;
    return score.clamp(0, 100);
  }
}

// ─── Mini Graph Card ────────────────────────────────────────
class _MiniGraphCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final Widget chart;

  const _MiniGraphCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            color: accentColor.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(icon, size: 70, color: accentColor.withValues(alpha: 0.04)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 15, color: accentColor),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: FontFamily.semiBold,
                          fontSize: 13,
                          color: isDark
                              ? AppThemeData.grey2
                              : AppThemeData.grey9,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontFamily: FontFamily.bold,
                          fontSize: 18,
                          color: isDark
                              ? AppThemeData.grey1
                              : AppThemeData.grey10,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: FontFamily.regular,
                          fontSize: 9,
                          color: isDark
                              ? AppThemeData.grey6
                              : AppThemeData.grey5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Chart
              SizedBox(
                height: 160,
                child: chart,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHART 1: This Month Purchases Bar Chart
// ═══════════════════════════════════════════════════════════════
class _PurchaseBarChart extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const _PurchaseBarChart(
      {required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekData = List.filled(4, 0.0);
    for (final p in controller.latestPurchases) {
      if (p.createdAt != null &&
          p.createdAt!.toDate().month == now.month &&
          p.createdAt!.toDate().year == now.year &&
          p.price != null) {
        final week =
            ((p.createdAt!.toDate().day - 1) / 7).floor().clamp(0, 3);
        weekData[week] += p.price!;
      }
    }
    final maxY =
        weekData.fold<double>(0.0, (a, b) => a > b ? a : b) * 1.3;
    final safeMaxY = maxY <= 0 ? 100.0 : maxY;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: safeMaxY,
        barGroups: weekData.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: AppThemeData.neonMint,
                width: 24,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: safeMaxY,
                  color: isDark
                      ? AppThemeData.surfaceMid
                      : AppThemeData.grey3,
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['W1', 'W2', 'W3', 'W4'];
                final idx = value.toInt();
                if (idx >= 0 && idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[idx],
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 9,
                        color: isDark
                            ? AppThemeData.grey6
                            : AppThemeData.grey5,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHART 2: This Month Dues Bar Chart
// ═══════════════════════════════════════════════════════════════
class _DuesBarChart extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const _DuesBarChart({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekData = List.filled(4, 0.0);
    for (final d in controller.latestDues) {
      if (d.oweDate != null &&
          d.oweDate!.month == now.month &&
          d.oweDate!.year == now.year &&
          d.amount != null) {
        final week = ((d.oweDate!.day - 1) / 7).floor().clamp(0, 3);
        weekData[week] += d.amount!;
      }
    }
    final maxY =
        weekData.fold<double>(0.0, (a, b) => a > b ? a : b) * 1.3;
    final safeMaxY = maxY <= 0 ? 100.0 : maxY;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: safeMaxY,
        barGroups: weekData.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: AppThemeData.neonPink,
                width: 24,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: safeMaxY,
                  color: isDark
                      ? AppThemeData.surfaceMid
                      : AppThemeData.grey3,
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['W1', 'W2', 'W3', 'W4'];
                final idx = value.toInt();
                if (idx >= 0 && idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[idx],
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 9,
                        color: isDark
                            ? AppThemeData.grey6
                            : AppThemeData.grey5,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHART 3: Device Categories Donut Chart
// ═══════════════════════════════════════════════════════════════
class _CategoryDonutChart extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const _CategoryDonutChart(
      {required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final categoryCount = <String, int>{};
    for (final d in controller.latestDevices) {
      final cat = d.category ?? 'Other';
      categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
    }

    if (categoryCount.isEmpty) {
      return Center(
        child: Text(
          'No devices',
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 11,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        ),
      );
    }

    final colors = [
      AppThemeData.neonTeal,
      AppThemeData.neonPurple,
      AppThemeData.neonOrange,
      AppThemeData.neonPink,
      AppThemeData.neonBlue,
      AppThemeData.neonMint,
    ];

    final sections =
        categoryCount.entries.toList().asMap().entries.map((e) {
      final color = colors[e.key % colors.length];
      return PieChartSectionData(
        value: e.value.value.toDouble(),
        color: color,
        radius: 40,
        title: '${e.value.value}',
        titleStyle: TextStyle(
          fontFamily: FontFamily.bold,
          fontSize: 10,
          color: Colors.white,
        ),
        borderSide: BorderSide(
          color: isDark
              ? AppThemeData.surfaceDeep
              : AppThemeData.grey1,
          width: 2,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHART 4: Task Priority Pie Chart
// ═══════════════════════════════════════════════════════════════
class _TaskPriorityChart extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const _TaskPriorityChart(
      {required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final priorityCount = <String, int>{};
    for (final t in controller.latestTasks) {
      final p = t.priorityLabel;
      priorityCount[p] = (priorityCount[p] ?? 0) + 1;
    }

    if (priorityCount.isEmpty) {
      return Center(
        child: Text(
          'No tasks',
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 11,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        ),
      );
    }

    final colors = [
      AppThemeData.neonPurple,
      AppThemeData.neonOrange,
      AppThemeData.neonMint,
      AppThemeData.neonPink,
      AppThemeData.neonBlue,
    ];

    final sections =
        priorityCount.entries.toList().asMap().entries.map((e) {
      final color = colors[e.key % colors.length];
      return PieChartSectionData(
        value: e.value.value.toDouble(),
        color: color,
        radius: 40,
        title: '${e.value.value}',
        titleStyle: TextStyle(
          fontFamily: FontFamily.bold,
          fontSize: 10,
          color: Colors.white,
        ),
        borderSide: BorderSide(
          color: isDark
              ? AppThemeData.surfaceDeep
              : AppThemeData.grey1,
          width: 2,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHART 5: Due Type Breakdown (Owe vs Take)
// ═══════════════════════════════════════════════════════════════
class _DueTypeChart extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const _DueTypeChart({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    int oweCount = 0;
    int takeCount = 0;
    for (final d in controller.latestDues) {
      if (DueType.isOwe(d.dueType)) {
        oweCount++;
      } else {
        takeCount++;
      }
    }

    if (oweCount == 0 && takeCount == 0) {
      return Center(
        child: Text(
          'No dues',
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 11,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: oweCount.toDouble(),
            color: AppThemeData.neonPink,
            radius: 44,
            title: 'I Owe\n$oweCount',
            titleStyle: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 9,
              color: Colors.white,
            ),
            borderSide: BorderSide(
              color: isDark
                  ? AppThemeData.surfaceDeep
                  : AppThemeData.grey1,
              width: 2,
            ),
          ),
          PieChartSectionData(
            value: takeCount.toDouble(),
            color: AppThemeData.neonMint,
            radius: 44,
            title: 'Owed Me\n$takeCount',
            titleStyle: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 9,
              color: Colors.white,
            ),
            borderSide: BorderSide(
              color: isDark
                  ? AppThemeData.surfaceDeep
                  : AppThemeData.grey1,
              width: 2,
            ),
          ),
        ],
        centerSpaceRadius: 25,
        sectionsSpace: 3,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHART 6: Reminders by Importance Bar Chart
// ═══════════════════════════════════════════════════════════════
class _ReminderImportanceChart extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const _ReminderImportanceChart(
      {required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final impCount = <String, int>{};
    for (final r in controller.latestReminders) {
      final imp = r.importance ?? 'Normal';
      impCount[imp] = (impCount[imp] ?? 0) + 1;
    }

    if (impCount.isEmpty) {
      return Center(
        child: Text(
          'No reminders',
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 11,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        ),
      );
    }

    final entries = impCount.entries.toList();
    final colors = [
      AppThemeData.neonOrange,
      AppThemeData.neonPink,
      AppThemeData.neonPurple,
      AppThemeData.neonTeal,
      AppThemeData.neonBlue,
    ];
    final maxVal = entries
        .fold<double>(0.0, (a, b) => a > b.value.toDouble() ? a : b.value.toDouble());
    final safeMaxY = maxVal * 1.4 + 1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: safeMaxY,
        barGroups: entries.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                color: colors[e.key % colors.length],
                width: 24,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: safeMaxY,
                  color: isDark
                      ? AppThemeData.surfaceMid
                      : AppThemeData.grey3,
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < entries.length) {
                  final label = entries[idx].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label.length > 6
                          ? '${label.substring(0, 6)}..'
                          : label,
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 8,
                        color: isDark
                            ? AppThemeData.grey6
                            : AppThemeData.grey5,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHART 7: Subscription Radial Chart
// ═══════════════════════════════════════════════════════════════
class _SubscriptionRadialChart extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const _SubscriptionRadialChart(
      {required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final subs = controller.subscriptionCount.value;
    const maxSubs = 10.0;
    final percent = (subs / maxSubs).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: -90,
            sections: [
              PieChartSectionData(
                value: percent,
                color: AppThemeData.neonBlue,
                radius: 36,
                title: '',
                borderSide: BorderSide.none,
              ),
              PieChartSectionData(
                value: 1 - percent,
                color: isDark
                    ? AppThemeData.surfaceMid
                    : AppThemeData.grey3,
                radius: 36,
                title: '',
                borderSide: BorderSide.none,
              ),
            ],
            centerSpaceRadius: 28,
            sectionsSpace: 0,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subs.toString(),
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 20,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ),
            Text(
              'Active',
              style: TextStyle(
                fontFamily: FontFamily.regular,
                fontSize: 9,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHART 8: Security Score Gauge
// ═══════════════════════════════════════════════════════════════
class _SecurityGaugeChart extends StatelessWidget {
  final int score;
  final bool isDark;

  const _SecurityGaugeChart(
      {required this.score, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final percent = (score / 100).clamp(0.0, 1.0);
    final color = score >= 80
        ? AppThemeData.neonMint
        : score >= 50
            ? AppThemeData.neonOrange
            : AppThemeData.neonRed;

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: -90,
            sections: [
              PieChartSectionData(
                value: percent,
                color: color,
                radius: 40,
                title: '',
                borderSide: BorderSide.none,
              ),
              PieChartSectionData(
                value: 1 - percent,
                color: isDark
                    ? AppThemeData.surfaceMid
                    : AppThemeData.grey3,
                radius: 40,
                title: '',
                borderSide: BorderSide.none,
              ),
            ],
            centerSpaceRadius: 30,
            sectionsSpace: 0,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$score',
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 22,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
            ),
            Text(
              score >= 80
                  ? 'Secure'
                  : score >= 50
                      ? 'Attention'
                      : 'At Risk',
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 9,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
