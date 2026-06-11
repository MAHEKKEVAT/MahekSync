import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'dashboard_models.dart';

class AnimatedBarChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final Color accentColor;
  final double height;

  const AnimatedBarChart({
    super.key,
    required this.data,
    required this.accentColor,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxVal = data.fold<double>(0, (m, d) => d.value > m ? d.value : m);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutQuart,
      builder: (_, anim, __) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _BarChartPainter(
            data: data,
            maxValue: maxVal,
            anim: anim,
            accentColor: accentColor,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double maxValue;
  final double anim;
  final Color accentColor;
  final bool isDark;

  _BarChartPainter({
    required this.data,
    required this.maxValue,
    required this.anim,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final n = data.length;
    final totalGap = 16.0;
    final availW = size.width - totalGap;
    final barW = availW / (n * 2.2);
    final gap = (availW - barW * n) / (n - 1);
    final bottom = size.height - 18;
    final chartH = size.height - 24;

    final gridPaint = Paint()
      ..color = (isDark ? AppThemeData.grey8 : AppThemeData.grey3).withOpacity(
        0.2,
      )
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 3; i++) {
      final y = bottom - (chartH * i / 3);
      canvas.drawLine(
        Offset(totalGap / 2, y),
        Offset(size.width - totalGap / 2, y),
        gridPaint,
      );
    }

    final defaultColors = [
      AppThemeData.neonTeal,
      AppThemeData.neonOrange,
      AppThemeData.neonPurple,
      AppThemeData.neonPink,
      AppThemeData.neonBlue,
      AppThemeData.neonMint,
    ];

    for (int i = 0; i < n; i++) {
      final dp = data[i];
      final barH = maxValue > 0 ? (dp.value / maxValue) * chartH * anim : 0.0;
      final x = totalGap / 2 + i * (barW + gap);
      final y = bottom - barH;
      final color = dp.color ?? defaultColors[i % defaultColors.length];

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      if (barH > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x, y, barW, barH),
            topLeft: const Radius.circular(4),
            topRight: const Radius.circular(4),
          ),
          paint,
        );
      }

      final tp = TextPainter(
        text: TextSpan(
          text: dp.label,
          style: TextStyle(
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: barW + gap);
      tp.paint(canvas, Offset(x + (barW - tp.width) / 2, bottom + 4));
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.anim != anim || old.data != data;
}

class AnimatedDonutChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final double size;
  final double strokeWidth;

  const AnimatedDonutChart({
    super.key,
    required this.data,
    this.size = 140,
    this.strokeWidth = 24,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (s, d) => s + d.value);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutQuart,
      builder: (_, anim, __) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _DonutChartPainter(
                data: data,
                total: total,
                anim: anim,
                strokeWidth: strokeWidth,
                isDark: isDark,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextCustom(
                  title: total.toInt().toString(),
                  fontSize: 22,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                TextCustom(
                  title: 'items',
                  fontSize: 10,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double total;
  final double anim;
  final double strokeWidth;
  final bool isDark;

  _DonutChartPainter({
    required this.data,
    required this.total,
    required this.anim,
    required this.strokeWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const gapAngle = 0.04;
    final defaultColors = [
      AppThemeData.neonTeal,
      AppThemeData.neonPurple,
      AppThemeData.neonOrange,
      AppThemeData.neonPink,
      AppThemeData.neonBlue,
      AppThemeData.neonMint,
    ];

    final bgPaint = Paint()
      ..color = (isDark ? AppThemeData.grey8 : AppThemeData.grey3).withOpacity(
        0.25,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.3;
    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -math.pi / 2;
    for (int i = 0; i < data.length; i++) {
      final dp = data[i];
      final sweep = total > 0 ? (dp.value / total) * 2 * math.pi * anim : 0.0;
      if (sweep <= 0.01) continue;

      final paint = Paint()
        ..color = dp.color ?? defaultColors[i % defaultColors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweep - gapAngle, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) =>
      old.anim != anim || old.data != data;
}
