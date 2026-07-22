import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/weather_model.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class WeatherHourlyChart extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final String Function(double) formatTemp;
  final bool Function(int) isRainCode;

  const WeatherHourlyChart({
    super.key,
    required this.hourly,
    required this.formatTemp,
    required this.isRainCode,
  });

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    final temps = hourly.map((h) => h.temperature).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    final tempRange = maxTemp - minTemp;
    final padding = tempRange > 0 ? tempRange * 0.15 : 2.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildChart(minTemp - padding, maxTemp + padding),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppThemeData.neonTeal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.schedule_rounded, color: AppThemeData.neonTeal, size: 14),
        ),
        const SizedBox(width: 8),
        TextCustom(
          title: 'Hourly Forecast',
          fontSize: 15,
          fontFamily: FontFamily.semiBold,
          color: AppThemeData.primaryWhite,
        ),
      ],
    );
  }

  Widget _buildChart(double minY, double maxY) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppThemeData.surfaceElevated,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final idx = spot.x.toInt();
                  if (idx < 0 || idx >= hourly.length) return null;
                  final h = hourly[idx];
                  return LineTooltipItem(
                    '',
                    const TextStyle(),
                    children: [
                      TextSpan(
                        text: DateFormat('HH:mm').format(h.time),
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: FontFamily.medium,
                          color: AppThemeData.primaryWhite.withValues(alpha: 0.6),
                        ),
                      ),
                      const TextSpan(text: '\n'),
                      TextSpan(
                        text: '${formatTemp(h.temperature)}°',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: FontFamily.bold,
                          color: AppThemeData.primaryWhite,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: _bottomInterval(),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= hourly.length) return const SizedBox.shrink();
                  if (idx % _bottomInterval().toInt() != 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextCustom(
                      title: DateFormat('HH:mm').format(hourly[idx].time),
                      fontSize: 10,
                      fontFamily: FontFamily.medium,
                      color: AppThemeData.primaryWhite.withValues(alpha: 0.45),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(hourly.length, (i) => FlSpot(i.toDouble(), hourly[i].temperature)),
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppThemeData.neonTeal,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, idx) {
                  final h = idx < hourly.length ? hourly[idx] : null;
                  final isRain = h != null && isRainCode(h.weatherCode);
                  return FlDotCirclePainter(
                    radius: isRain ? 4 : 3,
                    color: isRain ? AppThemeData.neonBlue : AppThemeData.neonTeal,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppThemeData.neonTeal.withValues(alpha: 0.2),
                    AppThemeData.neonTeal.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      ),
    );
  }

  double _bottomInterval() {
    if (hourly.length <= 8) return 1;
    if (hourly.length <= 16) return 2;
    return 3;
  }
}
