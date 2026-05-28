import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:solar_icons/solar_icons.dart';
import 'dashboard_models.dart';

class _S {
  static const double maxContentWidth = 1440;
  static const double mobileBreak = 600;
  static const double tabletBreak = 900;
  static const double laptopBreak = 1200;
  static const double desktopBreak = 1440;

  static bool isMobile(BuildContext c) => MediaQuery.of(c).size.width < mobileBreak;
  static bool isTablet(BuildContext c) => MediaQuery.of(c).size.width >= mobileBreak && MediaQuery.of(c).size.width < laptopBreak;
  static bool isDesktop(BuildContext c) => MediaQuery.of(c).size.width >= laptopBreak;

  static double contentMaxW(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1920) return 1600;
    if (w >= desktopBreak) return 1440;
    if (w >= laptopBreak) return w - 40;
    return w;
  }

  static int analyticsCols(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1440) return 4;
    if (w >= 1100) return 4;
    if (w >= 600) return 2;
    return 1;
  }

  static double hPad(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1600) return 48;
    if (w >= 1200) return 32;
    if (w >= 600) return 24;
    return 16;
  }

  static double cardRadius(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    return w >= 1200 ? 18 : 14;
  }
}

class DashboardBackground extends StatelessWidget {
  final AnimationController glowCtrl;
  const DashboardBackground({super.key, required this.glowCtrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppThemeData.surfaceVoid,
                AppThemeData.surfaceObsidian,
                AppThemeData.surfaceDeep,
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter()),
        ),
        AnimatedBuilder(
          animation: glowCtrl,
          builder: (_, __) {
            return Stack(
              children: [
                Positioned(
                  top: -200,
                  right: -150,
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppThemeData.neonPurple.withOpacity(glowCtrl.value * 0.12),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -200,
                  left: -100,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppThemeData.neonTeal.withOpacity((1 - glowCtrl.value) * 0.08),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  left: MediaQuery.of(context).size.width * 0.6,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppThemeData.neonPink.withOpacity(glowCtrl.value * 0.06),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppThemeData.neonBlue.withOpacity(0.03)
      ..strokeWidth = 0.5;
    const spacing = 60.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeData.surfaceElevated.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeData.surfaceBorder.withOpacity(0.3)),
      ),
    );
  }
}


class _AnimatedCounter extends StatelessWidget {
  final int value;
  final Color color;
  const _AnimatedCounter({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) {
        return Text(
          value >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toInt().toString(),
          style: TextStyle(
            fontFamily: FontFamily.bold,
            fontSize: 26,
            color: color,
            height: 1.0,
          ),
        );
      },
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  const _Sparkline({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    return CustomPaint(
      size: const Size(60, 24),
      painter: _SparklinePainter(data: data, color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final range = maxVal - minVal;
    if (range == 0) return;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final fillPath = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.15), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.data != data;
}

class _LineAreaChart extends StatelessWidget {
  final DashboardChartModel chart;
  const _LineAreaChart({required this.chart});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _LineAreaPainter(chart: chart),
    );
  }
}

class _LineAreaPainter extends CustomPainter {
  final DashboardChartModel chart;
  _LineAreaPainter({required this.chart});

  @override
  void paint(Canvas canvas, Size size) {
    if (chart.data.isEmpty) return;
    final maxVal = chart.data.map((d) => d.value).reduce(max);
    if (maxVal == 0) return;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < chart.data.length; i++) {
      final x = (i / (chart.data.length - 1)) * size.width;
      final y = size.height - (chart.data[i].value / maxVal) * (size.height - 20);
      points.add(Offset(x, y));
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [chart.accentColor.withOpacity(0.15), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = chart.accentColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (final p in points) {
      canvas.drawCircle(p, 3, Paint()..color = chart.accentColor);
      canvas.drawCircle(p, 2, Paint()..color = AppThemeData.surfaceDeep);
    }
  }

  @override
  bool shouldRepaint(covariant _LineAreaPainter old) => old.chart != chart;
}

class _DonutChart extends StatelessWidget {
  final DashboardChartModel chart;
  const _DonutChart({required this.chart});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _DonutPainter(chart: chart),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final DashboardChartModel chart;
  _DonutPainter({required this.chart});

  @override
  void paint(Canvas canvas, Size size) {
    if (chart.data.isEmpty) return;
    final total = chart.data.fold(0.0, (sum, d) => sum + d.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    final strokeWidth = radius * 0.35;

    var startAngle = -pi / 2;
    for (final d in chart.data) {
      final sweepAngle = (d.value / total) * 2 * pi;
      final paint = Paint()
        ..color = d.color ?? chart.accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle + 0.02,
        sweepAngle - 0.04,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    final tp = TextPainter(
      text: TextSpan(
        text: chart.data.first.label,
        style: TextStyle(
          fontFamily: FontFamily.semiBold,
          fontSize: 12,
          color: AppThemeData.textNeonBlue.withOpacity(0.6),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.chart != chart;
}

class _RadialChart extends StatelessWidget {
  final DashboardChartModel chart;
  const _RadialChart({required this.chart});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _RadialPainter(chart: chart),
    );
  }
}

class _RadialPainter extends CustomPainter {
  final DashboardChartModel chart;
  _RadialPainter({required this.chart});

  @override
  void paint(Canvas canvas, Size size) {
    if (chart.data.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    final strokeWidth = radius * 0.2;
    final score = chart.data.first.value;

    canvas.drawCircle(
      center,
      radius - strokeWidth / 2,
      Paint()
        ..color = AppThemeData.surfaceBorder.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final sweepAngle = (score / 100) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: -pi / 2 + sweepAngle,
          colors: [chart.accentColor, chart.accentColor.withOpacity(0.6)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '${score.toInt()}%',
        style: TextStyle(
          fontFamily: FontFamily.bold,
          fontSize: 28,
          color: chart.accentColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RadialPainter old) => old.chart != chart;
}


class _ActivityItem extends StatelessWidget {
  final DashboardActivityModel activity;
  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppThemeData.surfaceElevated.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppThemeData.surfaceBorder.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: activity.accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(activity.icon, color: activity.accentColor, size: 14),
          ),
          spaceW(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 12,
                    color: AppThemeData.primaryWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (activity.description.isNotEmpty)
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontFamily: FontFamily.regular,
                      fontSize: 11,
                      color: AppThemeData.textNeonBlue.withOpacity(0.4),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            activity.timeAgo,
            style: TextStyle(
              fontFamily: FontFamily.regular,
              fontSize: 10,
              color: AppThemeData.textNeonBlue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}


class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontFamily: FontFamily.bold, fontSize: 16, color: color, height: 1)),
            spaceH(height: 2),
            Text(label, style: TextStyle(fontFamily: FontFamily.regular, fontSize: 9, color: color.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        spaceW(width: 10),
        Text(
          title,
          style: TextStyle(
            fontFamily: FontFamily.semiBold,
            fontSize: 16,
            color: AppThemeData.primaryWhite,
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),
        Container(
          width: 32,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.4), Colors.transparent]),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

class FuturisticLoader extends StatelessWidget {
  final Color color;
  const FuturisticLoader({super.key, this.color = AppThemeData.neonPurple});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          spaceH(height: 16),
          Text(
            'Loading Dashboard...',
            style: TextStyle(
              fontFamily: FontFamily.medium,
              fontSize: 13,
              color: AppThemeData.textNeonBlue.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

