import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/weather_model.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/theme/weather_theme.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'weather_painter.dart';

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
    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 900;

    if (isDesktop) {
      return _buildDesktopGrid();
    }
    return _buildMobileGrid();
  }

  Widget _buildDesktopGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _FeelsLikeCard(current: current)),
            const SizedBox(width: 12),
            Expanded(child: _UvIndexCard(current: current)),
          ],
        ),
        const SizedBox(height: 12),
        _WindCompassCard(current: current),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _SunriseSunsetCard(
                    sunrise: sunrise, sunset: sunset)),
            const SizedBox(width: 12),
            Expanded(
                child: _PrecipitationCard(
              rainChance: forecast.isNotEmpty
                  ? forecast.first.precipitationProbability
                  : 0,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _HumidityCard(current: current)),
            const SizedBox(width: 12),
            Expanded(child: _PressureCard(current: current)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _VisibilityCard(current: current)),
            const SizedBox(width: 12),
            Expanded(child: _DewPointCard(current: current)),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _FeelsLikeCard(current: current)),
            const SizedBox(width: 12),
            Expanded(child: _UvIndexCard(current: current)),
          ],
        ),
        const SizedBox(height: 12),
        _WindCompassCard(current: current),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _SunriseSunsetCard(
                    sunrise: sunrise, sunset: sunset)),
            const SizedBox(width: 12),
            Expanded(
                child: _PrecipitationCard(
              rainChance: forecast.isNotEmpty
                  ? forecast.first.precipitationProbability
                  : 0,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _HumidityCard(current: current)),
            const SizedBox(width: 12),
            Expanded(child: _PressureCard(current: current)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _VisibilityCard(current: current)),
            const SizedBox(width: 12),
            Expanded(child: _DewPointCard(current: current)),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  FEELS LIKE — Temperature differential bars
// ══════════════════════════════════════════════════════════════════════

class _FeelsLikeCard extends StatelessWidget {
  final CurrentWeather? current;
  const _FeelsLikeCard({this.current});

  @override
  Widget build(BuildContext context) {
    final feels = current?.feelsLike.round().toString() ?? '—';
    final actual = current?.temperature ?? 0;
    final feelsVal = current?.feelsLike ?? 0;

    final temps = [actual, feelsVal];
    final minT = temps.reduce(min) - 3;
    final maxT = temps.reduce(max) + 3;

    final wt = Theme.of(context).extension<WeatherThemeExtension>();

    return PremiumGlassCard(
      glowColor: wt?.accentBlue ?? const Color(0xFF5E5CE6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.thermostat_outlined,
                  color: (wt?.accentBlue ?? const Color(0xFF5E5CE6)).withValues(alpha: 0.7),
                  size: 14),
              const SizedBox(width: 6),
              TextCustom(
                title: 'Feels Like',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$feels°',
            style: TextStyle(
              fontSize: 36,
              fontFamily: FontFamily.bold,
              color: wt?.textPrimary ?? Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: CustomPaint(
              size: Size.infinite,
              painter: FeelsLikePainter(
                actualTemp: actual,
                feelsTemp: feelsVal,
                minTemp: minT,
                maxTemp: maxT,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: wt?.accentBlue ?? const Color(0xFF5E5CE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              TextCustom(
                title: 'Actual',
                fontSize: 10,
                color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 12),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: wt?.accentOrange ?? const Color(0xFFFF9F0A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              TextCustom(
                title: 'Feels like',
                fontSize: 10,
                color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextCustom(
            title: _feelsDescription(current?.feelsLike, current?.temperature),
            fontSize: 11,
            color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.35),
            maxLine: 2,
          ),
        ],
      ),
    );
  }

  String _feelsDescription(double? feels, double? actual) {
    if (feels == null || actual == null) return '';
    final diff = feels - actual;
    if (diff < -2) return 'Wind is making it feel colder.';
    if (diff > 2) return 'Humidity is making it feel warmer.';
    return 'Similar to actual temperature.';
  }
}

// ══════════════════════════════════════════════════════════════════════
//  UV INDEX — Gradient arc meter
// ══════════════════════════════════════════════════════════════════════

class _UvIndexCard extends StatelessWidget {
  final CurrentWeather? current;
  const _UvIndexCard({this.current});

  @override
  Widget build(BuildContext context) {
    final uv = current?.uvIndex ?? 0;
    final label = current?.uvLabel ?? '—';

    final wt = Theme.of(context).extension<WeatherThemeExtension>();

    return PremiumGlassCard(
      glowColor: _uvColor(uv),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined,
                  color: _uvColor(uv).withValues(alpha: 0.7), size: 14),
              const SizedBox(width: 6),
              TextCustom(
                title: 'UV Index',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: CustomPaint(
              size: Size.infinite,
              painter: UvArcPainter(uvValue: uv),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              uv.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 28,
                fontFamily: FontFamily.bold,
                color: wt?.textPrimary ?? Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _uvColor(uv).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextCustom(
                title: label,
                fontSize: 11,
                fontFamily: FontFamily.semiBold,
                color: _uvColor(uv),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _uvColor(double uv) {
    if (uv <= 2) return const Color(0xFF34C759);
    if (uv <= 5) return const Color(0xFFFFCC00);
    if (uv <= 7) return const Color(0xFFFF9500);
    if (uv <= 10) return const Color(0xFFFF3B30);
    return const Color(0xFFAF52DE);
  }
}

// ══════════════════════════════════════════════════════════════════════
//  WIND COMPASS — Full width compass card
// ══════════════════════════════════════════════════════════════════════

class _WindCompassCard extends StatelessWidget {
  final CurrentWeather? current;
  const _WindCompassCard({this.current});

  @override
  Widget build(BuildContext context) {
    final speed = current?.windSpeed.toStringAsFixed(1) ?? '—';
    final dir = current?.windDirectionText ?? '—';
    final deg = current?.windDirection ?? 0;

    final wt = Theme.of(context).extension<WeatherThemeExtension>();

    return PremiumGlassCard(
      glowColor: wt?.accentCyan ?? const Color(0xFF64D2FF),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.explore_rounded,
                        color:
                            (wt?.accentCyan ?? const Color(0xFF64D2FF)).withValues(alpha: 0.7),
                        size: 14),
                    const SizedBox(width: 6),
                    TextCustom(
                      title: 'Wind',
                      fontSize: 12,
                      fontFamily: FontFamily.medium,
                      color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      speed,
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: FontFamily.bold,
                        color: wt?.textPrimary ?? Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: TextCustom(
                        title: 'km/h',
                        fontSize: 12,
                        color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (wt?.accentCyan ?? const Color(0xFF64D2FF)).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextCustom(
                    title: dir,
                    fontSize: 12,
                    fontFamily: FontFamily.semiBold,
                    color: (wt?.accentCyan ?? const Color(0xFF64D2FF)).withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: WindCompassPainter(
                direction: deg.toDouble(),
                animationValue: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  SUNRISE / SUNSET — Enhanced arc with golden sun
// ══════════════════════════════════════════════════════════════════════

class _SunriseSunsetCard extends StatefulWidget {
  final DateTime? sunrise;
  final DateTime? sunset;
  const _SunriseSunsetCard({this.sunrise, this.sunset});

  @override
  State<_SunriseSunsetCard> createState() => _SunriseSunsetCardState();
}

class _SunriseSunsetCardState extends State<_SunriseSunsetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final srStr = widget.sunrise != null
        ? DateFormat('h:mm a').format(widget.sunrise!)
        : '—';
    final ssStr = widget.sunset != null
        ? DateFormat('h:mm a').format(widget.sunset!)
        : '—';

    double progress = 0.5;
    if (widget.sunrise != null && widget.sunset != null) {
      final now = DateTime.now();
      final total = widget.sunset!.difference(widget.sunrise!).inMinutes;
      final elapsed = now.difference(widget.sunrise!).inMinutes;
      progress = (elapsed / total).clamp(0.0, 1.0);
    }

    return PremiumGlassCard(
      glowColor: wt?.accentYellow ?? const Color(0xFFFFD60A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_twilight_outlined,
                  color:
                      (wt?.accentYellow ?? const Color(0xFFFFD60A)).withValues(alpha: 0.7),
                  size: 14),
              const SizedBox(width: 6),
              TextCustom(
                title: 'Sunrise & Sunset',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return SizedBox(
                height: 90,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      size: Size(constraints.maxWidth, 90),
                      painter: SunriseArcPainter(
                        progress: progress,
                        animationValue: _animController.value,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    title: 'Sunrise',
                    fontSize: 10,
                    color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.4),
                  ),
                  TextCustom(
                    title: srStr,
                    fontSize: 13,
                    fontFamily: FontFamily.semiBold,
                    color: wt?.textPrimary ?? Colors.white,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextCustom(
                    title: 'Sunset',
                    fontSize: 10,
                    color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.4),
                  ),
                  TextCustom(
                    title: ssStr,
                    fontSize: 13,
                    fontFamily: FontFamily.semiBold,
                    color: wt?.textPrimary ?? Colors.white,
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

// ══════════════════════════════════════════════════════════════════════
//  PRECIPITATION — Water fill gauge
// ══════════════════════════════════════════════════════════════════════

class _PrecipitationCard extends StatefulWidget {
  final int rainChance;
  const _PrecipitationCard({required this.rainChance});

  @override
  State<_PrecipitationCard> createState() => _PrecipitationCardState();
}

class _PrecipitationCardState extends State<_PrecipitationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final rain = widget.rainChance;

    return PremiumGlassCard(
      glowColor: AppThemeData.neonTeal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined,
                  color: AppThemeData.neonTeal.withValues(alpha: 0.7),
                  size: 14),
              const SizedBox(width: 6),
              TextCustom(
                title: 'Precipitation',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: PrecipitationFillPainter(
                    percentage: rain.toDouble(),
                    animationValue: _animController.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$rain',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: FontFamily.bold,
                  color: wt?.textPrimary ?? Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: TextCustom(
                  title: '%',
                  fontSize: 16,
                  fontFamily: FontFamily.semiBold,
                  color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextCustom(
            title: rain > 50
                ? 'Rain expected.'
                : rain > 20
                    ? 'Light rain possible.'
                    : 'Low chance of rain.',
            fontSize: 11,
            color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.4),
            maxLine: 2,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  HUMIDITY — Liquid wave fill
// ══════════════════════════════════════════════════════════════════════

class _HumidityCard extends StatefulWidget {
  final CurrentWeather? current;
  const _HumidityCard({this.current});

  @override
  State<_HumidityCard> createState() => _HumidityCardState();
}

class _HumidityCardState extends State<_HumidityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final humidity = widget.current?.humidity ?? 0;
    final label = humidity > 70 ? 'High' : 'Normal';

    return PremiumGlassCard(
      glowColor: wt?.accentBlue ?? const Color(0xFF5E5CE6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined,
                  color: (wt?.accentBlue ?? const Color(0xFF5E5CE6)).withValues(alpha: 0.7),
                  size: 14),
              const SizedBox(width: 6),
              TextCustom(
                title: 'Humidity',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: HumidityWavePainter(
                    humidity: humidity,
                    animationValue: _animController.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${humidity.toInt()}',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: FontFamily.bold,
                  color: wt?.textPrimary ?? Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: TextCustom(
                  title: '%',
                  fontSize: 16,
                  fontFamily: FontFamily.semiBold,
                  color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (wt?.accentBlue ?? const Color(0xFF5E5CE6)).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextCustom(
                  title: label,
                  fontSize: 10,
                  fontFamily: FontFamily.semiBold,
                  color:
                      (wt?.accentBlue ?? const Color(0xFF5E5CE6)).withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  PRESSURE — Circular gauge
// ══════════════════════════════════════════════════════════════════════

class _PressureCard extends StatelessWidget {
  final CurrentWeather? current;
  const _PressureCard({this.current});

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final pressure = current?.pressure ?? 0;

    return PremiumGlassCard(
      glowColor: wt?.accentGreen ?? const Color(0xFF34C759),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed_rounded,
                  color: (wt?.accentGreen ?? const Color(0xFF34C759)).withValues(alpha: 0.7),
                  size: 14),
              const SizedBox(width: 6),
              TextCustom(
                title: 'Pressure',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: PressureGaugePainter(pressure: pressure),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pressure.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: FontFamily.bold,
                    color: wt?.textPrimary ?? Colors.white,
                  ),
                ),
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: TextCustom(
                    title: 'hPa',
                    fontSize: 11,
                    color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  VISIBILITY — Mountain horizon
// ══════════════════════════════════════════════════════════════════════

class _VisibilityCard extends StatelessWidget {
  final CurrentWeather? current;
  const _VisibilityCard({this.current});

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final vis = current?.visibilityText ?? '—';
    final visKm = (current?.visibility ?? 0) / 1000;

    return PremiumGlassCard(
      glowColor: wt?.accentPurple ?? const Color(0xFFAF52DE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_outlined,
                  color: (wt?.accentPurple ?? const Color(0xFFAF52DE)).withValues(alpha: 0.7),
                  size: 14),
              const SizedBox(width: 6),
              TextCustom(
                title: 'Visibility',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                size: Size.infinite,
                painter: VisibilityMountainPainter(visibilityKm: visKm),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vis,
            style: TextStyle(
              fontSize: 28,
              fontFamily: FontFamily.bold,
              color: wt?.textPrimary ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  DEW POINT — Calculated from humidity + temperature
// ══════════════════════════════════════════════════════════════════════

class _DewPointCard extends StatelessWidget {
  final CurrentWeather? current;
  const _DewPointCard({this.current});

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final temp = current?.temperature ?? 0;
    final rh = current?.humidity ?? 0;
    final dewPoint = _calculateDewPoint(temp, rh);
    final label = _dewPointLabel(dewPoint);

    return PremiumGlassCard(
      glowColor: wt?.accentGreen ?? const Color(0xFF32D74B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grain_rounded,
                  color: (wt?.accentGreen ?? const Color(0xFF32D74B)).withValues(alpha: 0.7),
                  size: 14),
              const SizedBox(width: 6),
              TextCustom(
                title: 'Dew Point',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: wt?.textMuted ?? Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${dewPoint.round()}°',
            style: TextStyle(
              fontSize: 36,
              fontFamily: FontFamily.bold,
              color: wt?.textPrimary ?? Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (wt?.accentGreen ?? const Color(0xFF32D74B)).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextCustom(
              title: label,
              fontSize: 11,
              fontFamily: FontFamily.semiBold,
              color:
                  (wt?.accentGreen ?? const Color(0xFF32D74B)).withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateDewPoint(double temp, double humidity) {
    const a = 17.27;
    const b = 237.7;
    final alpha = (a * temp) / (b + temp) + log(humidity / 100);
    return (b * alpha) / (a - alpha);
  }

  String _dewPointLabel(double dp) {
    if (dp < 10) return 'Very Dry';
    if (dp < 15) return 'Comfortable';
    if (dp < 20) return 'Slightly Humid';
    if (dp < 25) return 'Humid';
    return 'Very Humid';
  }
}
