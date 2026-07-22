import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/weather_model.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class WeatherForecastRow extends StatelessWidget {
  final List<DailyForecast> forecast;
  final String Function(double) tempString;
  final IconData Function(int) weatherIcon;

  const WeatherForecastRow({
    super.key,
    required this.forecast,
    required this.tempString,
    required this.weatherIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    final allMax = forecast.map((d) => d.maxTemp).reduce((a, b) => a > b ? a : b);
    final allMin = forecast.map((d) => d.minTemp).reduce((a, b) => a < b ? a : b);
    final range = allMax - allMin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        ...List.generate(forecast.length, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: i < forecast.length - 1 ? 4 : 0),
            child: _ForecastRow(
              day: forecast[i],
              isToday: i == 0,
              allMin: allMin,
              range: range,
              tempString: tempString,
              weatherIcon: weatherIcon,
            ),
          );
        }),
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
            color: AppThemeData.neonPurple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.calendar_view_week_rounded, color: AppThemeData.neonPurple, size: 14),
        ),
        const SizedBox(width: 8),
        TextCustom(
          title: '7-Day Forecast',
          fontSize: 15,
          fontFamily: FontFamily.semiBold,
          color: AppThemeData.primaryWhite,
        ),
      ],
    );
  }
}

class _ForecastRow extends StatelessWidget {
  final DailyForecast day;
  final bool isToday;
  final double allMin;
  final double range;
  final String Function(double) tempString;
  final IconData Function(int) weatherIcon;

  const _ForecastRow({
    required this.day,
    required this.isToday,
    required this.allMin,
    required this.range,
    required this.tempString,
    required this.weatherIcon,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = isToday ? 'Today' : DateFormat('EEE').format(day.date);
    final lowFrac = range > 0 ? (day.minTemp - allMin) / range : 0.0;
    final highFrac = range > 0 ? (day.maxTemp - allMin) / range : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isToday ? AppThemeData.primary50.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: TextCustom(
              title: dayName,
              fontSize: 14,
              fontFamily: isToday ? FontFamily.bold : FontFamily.regular,
              color: isToday
                  ? AppThemeData.primaryWhite
                  : AppThemeData.primaryWhite.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 8),
          Icon(weatherIcon(day.weatherCode), color: AppThemeData.primaryWhite, size: 22),
          const SizedBox(width: 16),
          TextCustom(
            title: tempString(day.minTemp),
            fontSize: 14,
            fontFamily: FontFamily.regular,
            color: AppThemeData.primaryWhite.withValues(alpha: 0.45),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TempRangeBar(
              lowFrac: lowFrac,
              highFrac: highFrac,
              isToday: isToday,
            ),
          ),
          const SizedBox(width: 10),
          TextCustom(
            title: tempString(day.maxTemp),
            fontSize: 14,
            fontFamily: FontFamily.bold,
            color: AppThemeData.primaryWhite,
          ),
          const SizedBox(width: 14),
          if (day.precipitationProbability > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_drop_outlined, color: AppThemeData.neonTeal, size: 12),
                const SizedBox(width: 3),
                TextCustom(
                  title: '${day.precipitationProbability}%',
                  fontSize: 12,
                  color: AppThemeData.neonTeal,
                ),
              ],
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _TempRangeBar extends StatelessWidget {
  final double lowFrac;
  final double highFrac;
  final bool isToday;

  const _TempRangeBar({
    required this.lowFrac,
    required this.highFrac,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final startX = lowFrac * barWidth;
        final endX = highFrac * barWidth;
        final segmentWidth = (endX - startX).clamp(2.0, barWidth);

        return SizedBox(
          height: 6,
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppThemeData.surfaceLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Positioned(
                left: startX,
                child: Container(
                  width: segmentWidth,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isToday
                          ? [AppThemeData.neonTeal, AppThemeData.neonBlue]
                          : [AppThemeData.neonTeal.withValues(alpha: 0.6), AppThemeData.neonBlue.withValues(alpha: 0.6)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: AppThemeData.neonTeal.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
