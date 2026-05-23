import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:solar_icons/solar_icons.dart';

import 'dashboard_controller.dart';
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

class HeroSection extends StatelessWidget {
  final DashboardHomeController ctrl;
  const HeroSection({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedOpacity(
      opacity: ctrl.heroVisible.value ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      child: AnimatedSlide(
        offset: ctrl.heroVisible.value ? Offset.zero : const Offset(0, 0.05),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _S.hPad(context),
            vertical: _S.isDesktop(context) ? 32 : 20,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _OrbIcon(ctrl: ctrl),
                        spaceW(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (b) => AppThemeData.appleIntelligenceGradient.createShader(b),
                                child: Text(
                                  'Welcome back, ${ctrl.profile.value.userName}',
                                  style: TextStyle(
                                    fontFamily: FontFamily.bold,
                                    fontSize: _S.isDesktop(context) ? 28 : 22,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              spaceH(height: 4),
                              Row(
                                children: [
                                  _SyncDot(ctrl: ctrl),
                                  spaceW(width: 8),
                                  Text(
                                    'MahekSync AI Active',
                                    style: TextStyle(
                                      fontFamily: FontFamily.medium,
                                      fontSize: 13,
                                      color: AppThemeData.textNeonMint.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_S.isDesktop(context)) ...[
                const SizedBox(width: 24),
                _AIBadge(ctrl: ctrl),
              ],
            ],
          ),
        ),
      ),
    ));
  }
}

class _OrbIcon extends StatelessWidget {
  final DashboardHomeController ctrl;
  const _OrbIcon({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl.orbCtrl,
      builder: (_, __) {
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppThemeData.appleIntelligenceGradientCool,
            boxShadow: AppThemeData.neonGlow(
              AppThemeData.neonPurple,
              blur: 24,
              opacity: ctrl.orbCtrl.value * 0.5,
            ),
          ),
          child: const Icon(SolarIconsBold.bolt, color: Colors.white, size: 24),
        );
      },
    );
  }
}

class _SyncDot extends StatelessWidget {
  final DashboardHomeController ctrl;
  const _SyncDot({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl.orbCtrl,
      builder: (_, __) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppThemeData.neonMint,
            boxShadow: AppThemeData.neonGlow(
              AppThemeData.neonMint,
              blur: 8,
              opacity: ctrl.orbCtrl.value * 0.6,
            ),
          ),
        );
      },
    );
  }
}

class _AIBadge extends StatelessWidget {
  final DashboardHomeController ctrl;
  const _AIBadge({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl.glowCtrl,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppThemeData.surfaceElevated.withOpacity(0.6),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppThemeData.neonPurple.withOpacity(0.2 + ctrl.glowCtrl.value * 0.1),
            ),
            boxShadow: AppThemeData.neonGlow(AppThemeData.neonPurple, blur: 16, opacity: ctrl.glowCtrl.value * 0.08),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(SolarIconsBold.magicStick, color: AppThemeData.neonPurple, size: 16),
              spaceW(width: 8),
              Text(
                'AI Intelligence v4.2',
                style: TextStyle(
                  fontFamily: FontFamily.medium,
                  fontSize: 12,
                  color: AppThemeData.textNeonPurple.withOpacity(0.9),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnalyticsGrid extends StatelessWidget {
  final DashboardHomeController ctrl;
  const AnalyticsGrid({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cols = _S.analyticsCols(context);
    final hPad = _S.hPad(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Obx(() {
        final items = ctrl.metrics;
        if (items.isEmpty) return _buildShimmerGrid(cols);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: _S.isMobile(context) ? 1.4 : 1.6,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            return _AnalyticsCard(
              metric: items[i],
              ctrl: ctrl,
              index: i,
            );
          },
        );
      }),
    );
  }

  Widget _buildShimmerGrid(int cols) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.6,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => _ShimmerCard(),
    );
  }
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

class _AnalyticsCard extends StatefulWidget {
  final DashboardMetricModel metric;
  final DashboardHomeController ctrl;
  final int index;

  const _AnalyticsCard({
    required this.metric,
    required this.ctrl,
    required this.index,
  });

  @override
  State<_AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<_AnalyticsCard> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.metric;
    final r = _S.cardRadius(context);

    return FadeTransition(
      opacity: _animCtrl,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: () => widget.ctrl.onMetricTap(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: _hovered ? (Matrix4.identity()..translate(0, -2)) : Matrix4.identity(),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppThemeData.surfaceElevated.withOpacity(_hovered ? 0.9 : 0.6),
                borderRadius: BorderRadius.circular(r),
                border: Border.all(
                  color: m.accentColor.withOpacity(_hovered ? 0.3 : 0.12),
                ),
                boxShadow: _hovered
                    ? AppThemeData.neonGlow(m.accentColor, blur: 20, opacity: 0.1)
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: m.accentColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: m.accentColor.withOpacity(0.15)),
                        ),
                        child: Icon(m.icon, color: m.accentColor, size: 18),
                      ),
                      const Spacer(),
                      _Sparkline(data: m.sparkline, color: m.accentColor),
                    ],
                  ),
                  const Spacer(),
                  _AnimatedCounter(value: m.value, color: AppThemeData.primaryWhite),
                  spaceH(height: 4),
                  Text(
                    m.title,
                    style: TextStyle(
                      fontFamily: FontFamily.medium,
                      fontSize: 12,
                      color: AppThemeData.textNeonBlue.withOpacity(0.6),
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
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

class ChartsSection extends StatelessWidget {
  final DashboardHomeController ctrl;
  const ChartsSection({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _S.hPad(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Analytics', icon: Icons.insights_rounded, color: AppThemeData.neonBlue),
          spaceH(height: 16),
          isWide ? _buildWideLayout(context) : _buildNarrowLayout(context),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _ChartCard(chart: ctrl.charts.isNotEmpty ? ctrl.charts[0] : null, ctrl: ctrl)),
        const SizedBox(width: 14),
        Expanded(flex: 2, child: _ChartCard(chart: ctrl.charts.length > 1 ? ctrl.charts[1] : null, ctrl: ctrl)),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      children: [
        _ChartCard(chart: ctrl.charts.isNotEmpty ? ctrl.charts[0] : null, ctrl: ctrl),
        spaceH(height: 14),
        _ChartCard(chart: ctrl.charts.length > 1 ? ctrl.charts[1] : null, ctrl: ctrl),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final DashboardChartModel? chart;
  final DashboardHomeController ctrl;
  const _ChartCard({required this.chart, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (chart == null) return  _ShimmerCard();

    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeData.surfaceElevated.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chart!.accentColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chart!.title,
            style: TextStyle(
              fontFamily: FontFamily.semiBold,
              fontSize: 14,
              color: AppThemeData.textNeonBlue.withOpacity(0.8),
            ),
          ),
          spaceH(height: 16),
          Expanded(
            child: _ChartPainter(chart: chart!),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends StatelessWidget {
  final DashboardChartModel chart;
  const _ChartPainter({required this.chart});

  @override
  Widget build(BuildContext context) {
    if (chart.type == ChartType.donut) return _DonutChart(chart: chart);
    if (chart.type == ChartType.radial) return _RadialChart(chart: chart);
    return _LineAreaChart(chart: chart);
  }
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

class AIInsightsSection extends StatelessWidget {
  final DashboardHomeController ctrl;
  const AIInsightsSection({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final hPad = _S.hPad(context);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'AI Insights', icon: SolarIconsBold.magicStick, color: AppThemeData.neonPurple),
          spaceH(height: 16),
          Obx(() {
            final items = ctrl.insights;
            if (items.isEmpty) return const SizedBox.shrink();

            return isWide
                ? Row(
                    children: items.take(3).map((i) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _InsightCard(insight: i, ctrl: ctrl),
                      ),
                    )).toList(),
                  )
                : Column(
                    children: items.take(3).map((i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _InsightCard(insight: i, ctrl: ctrl),
                    )).toList(),
                  );
          }),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final AIInsightModel insight;
  final DashboardHomeController ctrl;
  const _InsightCard({required this.insight, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ctrl.onInsightTap(insight),
      child: AnimatedBuilder(
        animation: ctrl.glowCtrl,
        builder: (_, __) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemeData.surfaceElevated.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: insight.accentColor.withOpacity(0.12 + ctrl.glowCtrl.value * 0.06),
              ),
              boxShadow: AppThemeData.neonGlow(insight.accentColor, blur: 12, opacity: ctrl.glowCtrl.value * 0.04),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: insight.accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(insight.icon, color: insight.accentColor, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: TextStyle(
                          fontFamily: FontFamily.semiBold,
                          fontSize: 13,
                          color: AppThemeData.primaryWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      spaceH(height: 4),
                      Text(
                        insight.description,
                        style: TextStyle(
                          fontFamily: FontFamily.regular,
                          fontSize: 11,
                          color: AppThemeData.textNeonBlue.withOpacity(0.5),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  final DashboardHomeController ctrl;
  const QuickActionsSection({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final hPad = _S.hPad(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Quick Actions', icon: SolarIconsBold.bolt, color: AppThemeData.neonOrange),
          spaceH(height: 14),
          Obx(() => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ctrl.quickActions.map((a) => _ActionChip(
              action: a,
              ctrl: ctrl,
            )).toList(),
          )),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final QuickActionModel action;
  final DashboardHomeController ctrl;
  const _ActionChip({required this.action, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl.glowCtrl,
      builder: (_, __) {
        return GestureDetector(
          onTap: () => ctrl.onQuickAction(action),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppThemeData.surfaceElevated.withOpacity(0.5),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: action.accentColor.withOpacity(0.15 + ctrl.glowCtrl.value * 0.05)),
              boxShadow: AppThemeData.neonGlow(action.accentColor, blur: 8, opacity: ctrl.glowCtrl.value * 0.04),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, color: action.accentColor, size: 15),
                const SizedBox(width: 8),
                Text(
                  action.title,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 12,
                    color: action.accentColor.withOpacity(0.9),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ActivityTimeline extends StatelessWidget {
  final DashboardHomeController ctrl;
  const ActivityTimeline({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final hPad = _S.hPad(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Recent Activity', icon: Icons.timeline_rounded, color: AppThemeData.neonTeal),
          spaceH(height: 14),
          Obx(() {
            final items = ctrl.activities;
            if (items.isEmpty) return _buildEmptyState();
            return Column(
              children: items.take(5).map((a) => _ActivityItem(activity: a)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeData.surfaceElevated.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeData.surfaceBorder.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          'No recent activity',
          style: TextStyle(
            fontFamily: FontFamily.regular,
            fontSize: 13,
            color: AppThemeData.textNeonBlue.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
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
          const SizedBox(width: 12),
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

class ProfileSystemPanel extends StatelessWidget {
  final DashboardHomeController ctrl;
  const ProfileSystemPanel({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final hPad = _S.hPad(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Obx(() {
        final p = ctrl.profile.value;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppThemeData.surfaceElevated.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemeData.neonPurple.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppThemeData.appleIntelligenceGradientCool,
                      boxShadow: AppThemeData.neonGlow(AppThemeData.neonPurple, blur: 12, opacity: 0.15),
                    ),
                    child: Center(
                      child: Text(
                        p.userName.isNotEmpty ? p.userName[0].toUpperCase() : 'A',
                        style: TextStyle(
                          fontFamily: FontFamily.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.userName,
                          style: TextStyle(
                            fontFamily: FontFamily.semiBold,
                            fontSize: 15,
                            color: AppThemeData.primaryWhite,
                          ),
                        ),
                        spaceH(height: 2),
                        Text(
                          p.email,
                          style: TextStyle(
                            fontFamily: FontFamily.regular,
                            fontSize: 11,
                            color: AppThemeData.textNeonBlue.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              spaceH(height: 20),
              _buildStorageBar(p),
              spaceH(height: 16),
              _buildAIStats(p),
              spaceH(height: 14),
              _buildServices(p),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStorageBar(ProfileSystemModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Storage',
              style: TextStyle(fontFamily: FontFamily.medium, fontSize: 11, color: AppThemeData.textNeonBlue.withOpacity(0.6)),
            ),
            Text(
              '${p.storageUsedMB}MB / ${p.storageTotalMB}MB',
              style: TextStyle(fontFamily: FontFamily.regular, fontSize: 10, color: AppThemeData.textNeonMint.withOpacity(0.5)),
            ),
          ],
        ),
        spaceH(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: p.storagePercent,
            backgroundColor: AppThemeData.surfaceBorder.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppThemeData.neonMint),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildAIStats(ProfileSystemModel p) {
    return Row(
      children: [
        _StatChip(label: 'AI Score', value: '${p.aiScore}', color: AppThemeData.neonPurple),
        const SizedBox(width: 10),
        _StatChip(label: 'Devices', value: '${p.totalDevices}', color: AppThemeData.neonTeal),
        const SizedBox(width: 10),
        _StatChip(label: 'Sessions', value: '${p.activeSessions}', color: AppThemeData.neonOrange),
      ],
    );
  }

  Widget _buildServices(ProfileSystemModel p) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: p.services.map((s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: s.color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: s.color.withOpacity(s.isConnected ? 0.2 : 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(s.icon, color: s.color, size: 12),
            const SizedBox(width: 5),
            Text(
              s.name,
              style: TextStyle(
                fontFamily: FontFamily.medium,
                fontSize: 10,
                color: s.color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      )).toList(),
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
        const SizedBox(width: 10),
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

class DashboardScrollView extends StatelessWidget {
  final DashboardHomeController ctrl;
  const DashboardScrollView({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isWide = _S.isDesktop(context);

    return Obx(() {
      if (ctrl.isLoading.value) return const FuturisticLoader();

      return SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: 40,
          top: _S.isMobile(context) ? 12 : 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _S.contentMaxW(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeroSection(ctrl: ctrl),
                spaceH(height: 24),
                AnalyticsGrid(ctrl: ctrl),
                spaceH(height: 28),
                ChartsSection(ctrl: ctrl),
                spaceH(height: 28),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: AIInsightsSection(ctrl: ctrl)),
                      const SizedBox(width: 20),
                      Expanded(child: ProfileSystemPanel(ctrl: ctrl)),
                    ],
                  )
                else ...[
                  AIInsightsSection(ctrl: ctrl),
                  spaceH(height: 24),
                  ProfileSystemPanel(ctrl: ctrl),
                ],
                spaceH(height: 28),
                QuickActionsSection(ctrl: ctrl),
                spaceH(height: 28),
                ActivityTimeline(ctrl: ctrl),
              ],
            ),
          ),
        ),
      );
    });
  }
}
