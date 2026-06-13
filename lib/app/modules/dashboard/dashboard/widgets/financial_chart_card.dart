// lib/app/modules/dashboard/widgets/financial_chart_card.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

class FinancialChartCard extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;

  const FinancialChartCard({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final purchaseTotal = _calcPurchaseTotal();
    final duesOwe = _calcDuesOwe();
    final duesTake = _calcDuesTake();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.12 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.bar_chart_rounded,
              size: 100,
              color: AppThemeData.neonPurple.withOpacity(0.04),
            ),
          ),

          Column(
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
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: AppThemeData.neonPurpleBlueGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bar_chart_rounded, size: 15, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Financial Overview',
                        style: TextStyle(
                          fontFamily: FontFamily.bold,
                          fontSize: 16,
                          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                        ),
                      ),
                    ],
                  ),
                  // Legend
                  Row(
                    children: [
                      _LegendDot(color: AppThemeData.neonMint, label: 'Purchases', isDark: isDark),
                      const SizedBox(width: 12),
                      _LegendDot(color: AppThemeData.neonPink, label: 'I Owe', isDark: isDark),
                      const SizedBox(width: 12),
                      _LegendDot(color: AppThemeData.neonTeal, label: 'Owed to Me', isDark: isDark),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Summary Cards Row
              Row(
                children: [
                  _SummaryChip(
                    label: 'Total Purchases',
                    value: _formatAmount(purchaseTotal),
                    icon: Icons.shopping_bag_rounded,
                    color: AppThemeData.neonMint,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _SummaryChip(
                    label: 'I Owe',
                    value: _formatAmount(duesOwe),
                    icon: Icons.arrow_upward_rounded,
                    color: AppThemeData.neonPink,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _SummaryChip(
                    label: 'Owed to Me',
                    value: _formatAmount(duesTake),
                    icon: Icons.arrow_downward_rounded,
                    color: AppThemeData.neonTeal,
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Chart
              SizedBox(
                height: 200,
                child: _FinancialBarChart(
                  controller: controller,
                  isDark: isDark,
                  purchaseTotal: purchaseTotal,
                  duesOwe: duesOwe,
                  duesTake: duesTake,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calcPurchaseTotal() {
    double total = 0;
    for (final p in controller.latestPurchases) {
      if (p.price != null) total += p.price!;
    }
    return total;
  }

  double _calcDuesOwe() {
    double total = 0;
    for (final d in controller.latestDues) {
      if (d.dueType == 'owe' && d.amount != null) total += d.amount!;
    }
    return total;
  }

  double _calcDuesTake() {
    double total = 0;
    for (final d in controller.latestDues) {
      if (d.dueType == 'take' && d.amount != null) total += d.amount!;
    }
    return total;
  }

  String _formatAmount(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

// ─── Bar Chart ────────────────────────────────────────────────
class _FinancialBarChart extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final double purchaseTotal;
  final double duesOwe;
  final double duesTake;

  const _FinancialBarChart({
    required this.controller,
    required this.isDark,
    required this.purchaseTotal,
    required this.duesOwe,
    required this.duesTake,
  });

  @override
  Widget build(BuildContext context) {
    final barGroups = _buildBarGroups();
    final maxY = _calcMaxY();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark
                ? AppThemeData.surfaceBorder.withOpacity(0.15)
                : AppThemeData.grey3.withOpacity(0.3),
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatAmount(value.toDouble()),
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 9,
                    color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['Purchases', 'I Owe', 'Owed Me', 'Subs'];
                final idx = value.toInt();
                if (idx >= 0 && idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[idx],
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 10,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
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
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                _formatAmount(rod.toY),
                TextStyle(
                  fontFamily: FontFamily.bold,
                  fontSize: 11,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final subCount = controller.subscriptionCount.value.toDouble();
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: purchaseTotal,
            color: AppThemeData.neonMint,
            width: 28,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: duesOwe,
            color: AppThemeData.neonPink,
            width: 28,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: duesTake,
            color: AppThemeData.neonTeal,
            width: 28,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: subCount * 100, // scale subscriptions for visibility
            color: AppThemeData.neonPurple,
            width: 28,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ),
    ];
  }

  double _calcMaxY() {
    final values = [purchaseTotal, duesOwe, duesTake, controller.subscriptionCount.value * 100.0];
    final maxVal = values.fold(0.0, (a, b) => a > b ? a : b);
    return maxVal <= 0 ? 100 : maxVal * 1.2;
  }

  String _formatAmount(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

// ─── Legend Dot ───────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;
  const _LegendDot({required this.color, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 10,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
      ],
    );
  }
}

// ─── Summary Chip ─────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 14,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: 9,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
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
