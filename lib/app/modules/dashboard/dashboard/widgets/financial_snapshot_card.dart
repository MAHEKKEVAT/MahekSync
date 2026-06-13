import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:maheksync/app/modules/dashboard/controllers/dashboard_home_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:solar_icons/solar_icons.dart';

class FinancialSnapshotCard extends StatelessWidget {
  final DashboardHomeController controller;
  final bool isDark;
  final VoidCallback? onDuesTap;
  final VoidCallback? onViewAll;

  const FinancialSnapshotCard({
    super.key,
    required this.controller,
    required this.isDark,
    this.onDuesTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final totalPurchases = controller.monthlyPurchaseTotal;
    final iOwe = controller.totalOweAmount;
    final owedToMe = controller.totalOwedToMe;

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
                        colors: [AppThemeData.neonMint, AppThemeData.neonTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(SolarIconsBold.wallet,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  TextCustom(
                    title: 'Financial Snapshot',
                    fontSize: 17,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'This Month',
                      style: TextStyle(
                        fontFamily: FontFamily.medium,
                        fontSize: 11,
                        color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: isDark ? AppThemeData.grey4 : AppThemeData.grey6),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Mini line chart
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark
                  ? AppThemeData.surfaceMid.withValues(alpha: 0.2)
                  : AppThemeData.grey2.withValues(alpha: 0.4),
            ),
            child: CustomPaint(
              painter: _MiniChartPainter(
                color: AppThemeData.neonMint,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3 stat columns
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: SolarIconsBold.cart,
                  label: 'Total Purchases',
                  value: totalPurchases,
                  color: AppThemeData.neonMint,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: SolarIconsBold.arrowUp,
                  label: 'I Owe',
                  value: '₹${_formatAmount(iOwe)}',
                  color: AppThemeData.danger300,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: SolarIconsBold.arrowDown,
                  label: 'Owed To Me',
                  value: '₹${_formatAmount(owedToMe)}',
                  color: AppThemeData.neonPurple,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.surfaceMid.withValues(alpha: 0.3)
            : AppThemeData.grey2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppThemeData.surfaceBorder.withValues(alpha: 0.10)
              : AppThemeData.grey3.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: FontFamily.bold,
              fontSize: 17,
              color: color,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.medium,
              fontSize: 10,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  _MiniChartPainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.15, size.height * 0.3),
      Offset(size.width * 0.3, size.height * 0.45),
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.65, size.height * 0.35),
      Offset(size.width * 0.8, size.height * 0.15),
      Offset(size.width, size.height * 0.25),
    ];

    // Line
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      final cp1 = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        points[i - 1].dy,
      );
      final cp2 = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        points[i].dy,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Fill gradient under line
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.0),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // Dots at data points
    final dotPaint = Paint()..color = color;
    for (final p in points) {
      canvas.drawCircle(p, 3, dotPaint);
      canvas.drawCircle(p, 5, Paint()..color = color.withValues(alpha: 0.2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
