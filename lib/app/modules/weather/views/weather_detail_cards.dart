import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/weather_model.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class WeatherDetailCards extends StatelessWidget {
  final CurrentWeather? current;
  final DateTime? sunrise;
  final DateTime? sunset;
  final List<DailyForecast> forecast;

  const WeatherDetailCards({
    super.key,
    this.current,
    this.sunrise,
    this.sunset,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _SunriseSunsetCard(
          sunrise: sunrise,
          sunset: sunset,
          isWide: !isMobile,
        ),
        _PrecipitationCard(
          rainChance: forecast.isNotEmpty ? forecast.first.precipitationProbability : 0,
        ),
        _WindCard(current: current),
        _PressureCard(current: current),
        _UvCard(current: current),
        _HumidityCard(current: current),
        _VisibilityCard(current: current),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  SUNRISE / SUNSET ARC
// ════════════════════════════════════════════════════════════════

class _SunriseSunsetCard extends StatelessWidget {
  final DateTime? sunrise;
  final DateTime? sunset;
  final bool isWide;

  const _SunriseSunsetCard({this.sunrise, this.sunset, this.isWide = false});

  @override
  Widget build(BuildContext context) {
    final srStr = sunrise != null ? DateFormat('h:mm a').format(sunrise!) : '—';
    final ssStr = sunset != null ? DateFormat('h:mm a').format(sunset!) : '—';

    double progress = 0.5;
    if (sunrise != null && sunset != null) {
      final now = DateTime.now();
      final total = sunset!.difference(sunrise!).inMinutes;
      final elapsed = now.difference(sunrise!).inMinutes;
      progress = (elapsed / total).clamp(0.0, 1.0);
    }

    return _GlassDetailCard(
      width: isWide ? 300 : double.infinity,
      accentColor: AppThemeData.neonOrange,
      title: 'Sunrise & Sunset',
      icon: Icons.wb_twilight_rounded,
      child: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: Size(isWide ? 270 : double.infinity, 100),
              painter: _SunriseArcPainter(progress: progress),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  TextCustom(
                    title: 'Sunrise',
                    fontSize: 11,
                    color: AppThemeData.primaryWhite.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 2),
                  TextCustom(
                    title: srStr,
                    fontSize: 14,
                    fontFamily: FontFamily.semiBold,
                    color: AppThemeData.primaryWhite,
                  ),
                ],
              ),
              Column(
                children: [
                  TextCustom(
                    title: 'Sunset',
                    fontSize: 11,
                    color: AppThemeData.primaryWhite.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 2),
                  TextCustom(
                    title: ssStr,
                    fontSize: 14,
                    fontFamily: FontFamily.semiBold,
                    color: AppThemeData.primaryWhite,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunriseArcPainter extends CustomPainter {
  final double progress;
  _SunriseArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 8;
    final radius = size.width * 0.42;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppThemeData.surfaceLight;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      pi,
      pi,
      false,
      trackPaint,
    );

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          AppThemeData.neonOrange,
          AppThemeData.neonYellow,
        ],
        startAngle: pi,
        endAngle: 2 * pi,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      pi,
      pi * progress,
      false,
      activePaint,
    );

    final dotAngle = pi + pi * progress;
    final dotX = cx + radius * cos(dotAngle);
    final dotY = cy + radius * sin(dotAngle);

    final dotGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppThemeData.neonOrange.withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(dotX, dotY), radius: 12));
    canvas.drawCircle(Offset(dotX, dotY), 12, dotGlowPaint);

    final dotPaint = Paint()..color = AppThemeData.neonOrange;
    canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);
    final dotCenter = Paint()..color = AppThemeData.primaryWhite;
    canvas.drawCircle(Offset(dotX, dotY), 2, dotCenter);
  }

  @override
  bool shouldRepaint(_SunriseArcPainter old) => old.progress != progress;
}

// ════════════════════════════════════════════════════════════════
//  PRECIPITATION
// ════════════════════════════════════════════════════════════════

class _PrecipitationCard extends StatelessWidget {
  final int rainChance;
  const _PrecipitationCard({required this.rainChance});

  @override
  Widget build(BuildContext context) {
    final color = rainChance > 50 ? AppThemeData.neonTeal : AppThemeData.neonBlue;
    return _GlassDetailCard(
      accentColor: color,
      title: 'Precipitation',
      icon: Icons.water_drop_outlined,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: AppThemeData.neonGlow(color, blur: 16, spread: -4, opacity: 0.15),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: rainChance / 100,
                      strokeWidth: 6,
                      backgroundColor: AppThemeData.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  TextCustom(
                    title: '$rainChance%',
                    fontSize: 18,
                    fontFamily: FontFamily.bold,
                    color: AppThemeData.primaryWhite,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextCustom(
                title: rainChance > 50
                    ? 'Rain expected later today.'
                    : rainChance > 20
                        ? 'Light rain possible.'
                        : 'Low chance of rain.',
                fontSize: 13,
                color: AppThemeData.primaryWhite.withValues(alpha: 0.5),
                maxLine: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  WIND
// ════════════════════════════════════════════════════════════════

class _WindCard extends StatelessWidget {
  final CurrentWeather? current;
  const _WindCard({this.current});

  @override
  Widget build(BuildContext context) {
    final speed = current?.windSpeed.toStringAsFixed(1) ?? '—';
    final dir = current?.windDirectionText ?? '—';
    return _GlassDetailCard(
      accentColor: AppThemeData.neonBlue,
      title: 'Wind',
      icon: Icons.air,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: [
            TextCustom(
              title: speed,
              fontSize: 36,
              fontFamily: FontFamily.bold,
              color: AppThemeData.primaryWhite,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: 'km/h',
                  fontSize: 12,
                  color: AppThemeData.primaryWhite.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppThemeData.neonBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextCustom(
                    title: dir,
                    fontSize: 12,
                    fontFamily: FontFamily.semiBold,
                    color: AppThemeData.neonBlue,
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

// ════════════════════════════════════════════════════════════════
//  PRESSURE
// ════════════════════════════════════════════════════════════════

class _PressureCard extends StatelessWidget {
  final CurrentWeather? current;
  const _PressureCard({this.current});

  @override
  Widget build(BuildContext context) {
    final value = current?.pressure.toStringAsFixed(0) ?? '—';
    return _GlassDetailCard(
      accentColor: AppThemeData.neonPurple,
      title: 'Pressure',
      icon: Icons.speed,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: [
            TextCustom(
              title: value,
              fontSize: 36,
              fontFamily: FontFamily.bold,
              color: AppThemeData.primaryWhite,
            ),
            const SizedBox(width: 6),
            TextCustom(
              title: 'hPa',
              fontSize: 12,
              color: AppThemeData.primaryWhite.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  UV INDEX
// ════════════════════════════════════════════════════════════════

class _UvCard extends StatelessWidget {
  final CurrentWeather? current;
  const _UvCard({this.current});

  @override
  Widget build(BuildContext context) {
    final uv = current?.uvIndex.toStringAsFixed(1) ?? '—';
    final label = current?.uvLabel ?? '—';
    return _GlassDetailCard(
      accentColor: AppThemeData.neonOrange,
      title: 'UV Index',
      icon: Icons.wb_sunny_outlined,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: uv,
              fontSize: 36,
              fontFamily: FontFamily.bold,
              color: AppThemeData.primaryWhite,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppThemeData.neonOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextCustom(
                title: label,
                fontSize: 12,
                fontFamily: FontFamily.semiBold,
                color: AppThemeData.neonOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  HUMIDITY
// ════════════════════════════════════════════════════════════════

class _HumidityCard extends StatelessWidget {
  final CurrentWeather? current;
  const _HumidityCard({this.current});

  @override
  Widget build(BuildContext context) {
    final humidity = current?.humidity.toInt().toString() ?? '—';
    final label = current != null && current!.humidity > 70 ? 'High' : 'Normal';
    return _GlassDetailCard(
      accentColor: AppThemeData.neonTeal,
      title: 'Humidity',
      icon: Icons.water_drop_outlined,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextCustom(
                  title: humidity,
                  fontSize: 36,
                  fontFamily: FontFamily.bold,
                  color: AppThemeData.primaryWhite,
                ),
                TextCustom(
                  title: '%',
                  fontSize: 18,
                  fontFamily: FontFamily.semiBold,
                  color: AppThemeData.primaryWhite.withValues(alpha: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppThemeData.neonTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextCustom(
                title: label,
                fontSize: 12,
                fontFamily: FontFamily.semiBold,
                color: AppThemeData.neonTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  VISIBILITY
// ════════════════════════════════════════════════════════════════

class _VisibilityCard extends StatelessWidget {
  final CurrentWeather? current;
  const _VisibilityCard({this.current});

  @override
  Widget build(BuildContext context) {
    final vis = current?.visibilityText ?? '—';
    return _GlassDetailCard(
      accentColor: AppThemeData.neonMint,
      title: 'Visibility',
      icon: Icons.visibility_outlined,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: TextCustom(
          title: vis,
          fontSize: 28,
          fontFamily: FontFamily.bold,
          color: AppThemeData.primaryWhite,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  SHARED GLASS CARD
// ════════════════════════════════════════════════════════════════

class _GlassDetailCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final String title;
  final IconData icon;
  final double? width;

  const _GlassDetailCard({
    required this.child,
    required this.accentColor,
    required this.title,
    required this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppThemeData.surfaceDeep.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppThemeData.primaryWhite.withValues(alpha: 0.07),
            ),
            boxShadow: [
              BoxShadow(
                color: AppThemeData.surfaceVoid.withValues(alpha: 0.4),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(gradient: AppThemeData.glassShimmerDark),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: accentColor, size: 14),
                      ),
                      const SizedBox(width: 8),
                      TextCustom(
                        title: title,
                        fontSize: 15,
                        fontFamily: FontFamily.semiBold,
                        color: AppThemeData.primaryWhite,
                      ),
                    ],
                  ),
                  child,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
