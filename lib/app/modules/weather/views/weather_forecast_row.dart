import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/weather_model.dart';
import 'package:maheksync/app/theme/weather_theme.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'weather_painter.dart';

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

    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final allMax = forecast.map((d) => d.maxTemp).reduce(max);
    final allMin = forecast.map((d) => d.minTemp).reduce(min);
    final range = allMax - allMin;

    return PremiumGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Icon(Icons.date_range_rounded,
                    color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.4), size: 14),
                const SizedBox(width: 6),
                TextCustom(
                  title: '7-Day Forecast',
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          Divider(
              color: wt?.glassBorder ?? Colors.white.withValues(alpha: 0.06), height: 1),
          ...List.generate(forecast.length, (i) {
            final isFirst = i == 0;
            final isLast = i == forecast.length - 1;
            return Column(
              children: [
                _ForecastRow(
                  day: forecast[i],
                  isToday: isFirst,
                  allMin: allMin,
                  range: range,
                  tempString: tempString,
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: wt?.glassBorder ?? Colors.white.withValues(alpha: 0.05),
                    indent: 56,
                    endIndent: 16,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ForecastRow extends StatefulWidget {
  final DailyForecast day;
  final bool isToday;
  final double allMin;
  final double range;
  final String Function(double) tempString;

  const _ForecastRow({
    required this.day,
    required this.isToday,
    required this.allMin,
    required this.range,
    required this.tempString,
  });

  @override
  State<_ForecastRow> createState() => _ForecastRowState();
}

class _ForecastRowState extends State<_ForecastRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final dayName =
        widget.isToday ? 'Today' : DateFormat('EEE').format(widget.day.date);
    final lowFrac = widget.range > 0
        ? (widget.day.minTemp - widget.allMin) / widget.range
        : 0.0;
    final highFrac = widget.range > 0
        ? (widget.day.maxTemp - widget.allMin) / widget.range
        : 0.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: _isExpanded
                  ? wt?.glassBorder ?? Colors.white.withValues(alpha: 0.04)
                  : Colors.transparent,
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: TextCustom(
                      title: dayName,
                      fontSize: 15,
                      fontFamily: widget.isToday
                          ? FontFamily.semiBold
                          : FontFamily.regular,
                      color: widget.isToday
                          ? (wt?.textPrimary ?? Colors.white)
                          : (wt?.textSecondary ?? Colors.white.withValues(alpha: 0.7)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  WeatherIcon(
                    code: widget.day.weatherCode,
                    size: 22,
                    animate: false,
                    color: wt?.textSecondary ?? Colors.white.withValues(alpha: 0.8),
                  ),
                  if (widget.day.precipitationProbability > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppThemeData.neonTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextCustom(
                        title: '${widget.day.precipitationProbability}%',
                        fontSize: 10,
                        fontFamily: FontFamily.semiBold,
                        color: AppThemeData.neonTeal.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                  const Spacer(),
                  TextCustom(
                    title: widget.tempString(widget.day.minTemp),
                    fontSize: 14,
                    fontFamily: FontFamily.regular,
                    color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: _TempRangeBar(
                      lowFrac: lowFrac,
                      highFrac: highFrac,
                      avgTemp:
                          (widget.day.minTemp + widget.day.maxTemp) / 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextCustom(
                    title: widget.tempString(widget.day.maxTemp),
                    fontSize: 14,
                    fontFamily: FontFamily.semiBold,
                    color: wt?.textPrimary ?? Colors.white,
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.3),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isExpanded
                  ? _buildExpandedDetail()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetail() {
    return Container(
      padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
      child: Row(
        children: [
          _buildDetailChip(
            Icons.water_drop_outlined,
            '${widget.day.precipitationProbability}%',
            'Rain',
            AppThemeData.neonTeal,
          ),
          const SizedBox(width: 8),
          _buildDetailChip(
            Icons.thermostat_outlined,
            (widget.day.minTemp + widget.day.maxTemp) / 2 > 25 ? 'Warm' : 'Cool',
            'Feels',
            const Color(0xFFFF9F0A),
          ),
          const SizedBox(width: 8),
          _buildDetailChip(
            Icons.wb_sunny_outlined,
            widget.isToday ? 'Now' : DateFormat('MMM d').format(widget.day.date),
            'Day',
            const Color(0xFFFFD60A),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.7), size: 12),
          const SizedBox(width: 4),
          TextCustom(
            title: value,
            fontSize: 11,
            fontFamily: FontFamily.semiBold,
            color: color.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 2),
          TextCustom(
            title: label,
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _TempRangeBar extends StatelessWidget {
  final double lowFrac;
  final double highFrac;
  final double avgTemp;

  const _TempRangeBar({
    required this.lowFrac,
    required this.highFrac,
    required this.avgTemp,
  });

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final startX = lowFrac * barWidth;
        final endX = highFrac * barWidth;
        final segmentWidth = max(endX - startX, 4.0);

        return SizedBox(
          height: 6,
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: wt?.glassBorder ?? Colors.white.withValues(alpha: 0.08),
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
                      colors: _tempGradientColors(avgTemp),
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: _tempGradientColors(avgTemp).last
                            .withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Color> _tempGradientColors(double temp) {
    if (temp < 5) return const [Color(0xFF4A90D9), Color(0xFF5AC8FA)];
    if (temp < 15) return const [Color(0xFF5AC8FA), Color(0xFF34C759)];
    if (temp < 22) return const [Color(0xFF34C759), Color(0xFFFFCC00)];
    if (temp < 30) return const [Color(0xFFFFCC00), Color(0xFFFF9500)];
    return const [Color(0xFFFF9500), Color(0xFFFF3B30)];
  }
}
