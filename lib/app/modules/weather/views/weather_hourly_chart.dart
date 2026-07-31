import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/weather_model.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/theme/weather_theme.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'weather_painter.dart';

class WeatherHourlyChart extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final String Function(double) formatTemp;
  final bool Function(int) isRainCode;
  final bool isNight;

  const WeatherHourlyChart({
    super.key,
    required this.hourly,
    required this.formatTemp,
    required this.isRainCode,
    this.isNight = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    final wt = Theme.of(context).extension<WeatherThemeExtension>();

    final temps = hourly.map((h) => h.temperature).toList();
    final minTemp = temps.reduce(min);
    final maxTemp = temps.reduce(max);

    return PremiumGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded,
                    color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.4), size: 14),
                const SizedBox(width: 6),
                TextCustom(
                  title: 'Hourly Forecast',
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.2), size: 10),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: hourly.length,
              separatorBuilder: (_, _) => const SizedBox(width: 2),
              itemBuilder: (context, i) {
                final h = hourly[i];
                final isNow = i == 0;
                final isRain = isRainCode(h.weatherCode);
                return _HourlyItem(
                  time: isNow ? 'Now' : DateFormat('ha').format(h.time),
                  temp: '${formatTemp(h.temperature)}°',
                  icon: h.weatherCode,
                  isNow: isNow,
                  isRain: isRain,
                  rainChance: h.precipitationProbability,
                  tempValue: h.temperature,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              height: 60,
              child: _TemperatureSparkline(
                hourly: hourly,
                minTemp: minTemp,
                maxTemp: maxTemp,
                isNight: isNight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyItem extends StatelessWidget {
  final String time;
  final String temp;
  final int icon;
  final bool isNow;
  final bool isRain;
  final int rainChance;
  final double tempValue;

  const _HourlyItem({
    required this.time,
    required this.temp,
    required this.icon,
    required this.isNow,
    required this.isRain,
    required this.rainChance,
    required this.tempValue,
  });

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();

    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: isNow
          ? BoxDecoration(
              color: wt?.glassBorder ?? Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: wt?.glassBorder ?? Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextCustom(
            title: time,
            fontSize: 11,
            fontFamily: isNow ? FontFamily.semiBold : FontFamily.medium,
            color: isNow
                ? wt?.textPrimary ?? Colors.white
                : wt?.textMuted ?? Colors.white.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 6),
          WeatherIcon(
            code: icon,
            size: 22,
            animate: false,
            color: isRain
                ? AppThemeData.neonTeal.withValues(alpha: 0.9)
                : wt?.textSecondary ?? Colors.white.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 6),
          TextCustom(
            title: temp,
            fontSize: 14,
            fontFamily: FontFamily.semiBold,
            color: wt?.textPrimary ?? Colors.white,
          ),
          if (rainChance > 0) ...[
            const SizedBox(height: 3),
            TextCustom(
              title: '$rainChance%',
              fontSize: 9,
              fontFamily: FontFamily.medium,
              color: AppThemeData.neonTeal.withValues(alpha: 0.7),
            ),
          ],
        ],
      ),
    );
  }
}

class _TemperatureSparkline extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final double minTemp;
  final double maxTemp;
  final bool isNight;

  const _TemperatureSparkline({
    required this.hourly,
    required this.minTemp,
    required this.maxTemp,
    required this.isNight,
  });

  @override
  Widget build(BuildContext context) {
    if (hourly.length < 2) return const SizedBox.shrink();

    final range = maxTemp - minTemp;
    final spots = <FlSpot>[];

    for (int i = 0; i < hourly.length; i++) {
      final normalized = range > 0
          ? (hourly[i].temperature - minTemp) / range
          : 0.5;
      spots.add(FlSpot(i.toDouble(), normalized));
    }

    final gradientColors = isNight
        ? [
            const Color(0xFF5E5CE6).withValues(alpha: 0.6),
            const Color(0xFF32D74B).withValues(alpha: 0.3),
          ]
        : [
            const Color(0xFFFF9F0A).withValues(alpha: 0.6),
            const Color(0xFFFFD60A).withValues(alpha: 0.3),
          ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: -0.1,
        maxY: 1.1,
        minX: 0,
        maxX: (hourly.length - 1).toDouble(),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.4,
            color: gradientColors[0],
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  gradientColors[0],
                  gradientColors[1],
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}
