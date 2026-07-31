// lib/app/modules/weather/controllers/weather_controller.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/models/weather_model.dart';
import 'package:maheksync/app/services/weather_api.dart';

class WeatherController extends GetxController {
  static const _fallbackLat = 21.1702;
  static const _fallbackLng = 72.8311;
  static const _fallbackCity = 'Surat, Gujarat';

  final isLoading = true.obs;
  final hasError = false.obs;
  final currentWeather = Rxn<CurrentWeather>();
  final forecast = <DailyForecast>[].obs;
  final hourlyForecast = <HourlyForecast>[].obs;
  final highlights = <WeatherHighlight>[].obs;
  final cityName = 'Getting location...'.obs;
  final isCelsius = true.obs;
  final latitude = Rxn<double>();
  final longitude = Rxn<double>();
  final sunrise = Rxn<DateTime>();
  final sunset = Rxn<DateTime>();
  final dataFetchTime = Rxn<DateTime>();

  double get _lat => latitude.value ?? _fallbackLat;
  double get _lng => longitude.value ?? _fallbackLng;

  String get weatherCondition {
    final cw = currentWeather.value;
    if (cw == null) return 'clear';
    return CurrentWeather.weatherCondition(cw.weatherCode);
  }

  bool get isRainy {
    final cw = currentWeather.value;
    if (cw == null) return false;
    return CurrentWeather.isRainCode(cw.weatherCode);
  }

  bool get isSnowy {
    final cw = currentWeather.value;
    if (cw == null) return false;
    return CurrentWeather.isSnowCode(cw.weatherCode);
  }

  bool get isNight {
    final sr = sunrise.value;
    final ss = sunset.value;
    if (sr == null || ss == null) {
      final h = DateTime.now().hour;
      return h < 6 || h >= 20;
    }
    final now = DateTime.now();
    return now.isBefore(sr) || now.isAfter(ss);
  }

  @override
  void onInit() {
    super.onInit();
    _initLocation();
  }

  Future<void> _initLocation() async {
    isLoading.value = true;

    final located = await _determinePosition();

    if (!located) {
      latitude.value = _fallbackLat;
      longitude.value = _fallbackLng;
      cityName.value = _fallbackCity;
    }

    await fetchAll();
  }

  Future<bool> _determinePosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return false;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      ).timeout(const Duration(seconds: 5));

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      final name = await WeatherApi.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      cityName.value = name ?? _fallbackCity;

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final data = await WeatherApi.fetchWeather(
        latitude: _lat,
        longitude: _lng,
      );
      final current = data['current'];
      if (current != null) {
        currentWeather.value = CurrentWeather.fromJson(current);
      }
      final daily = data['daily'];
      if (daily != null) {
        final times = daily['time'] as List<dynamic>? ?? [];
        final maxTemps = daily['temperature_2m_max'] as List<dynamic>? ?? [];
        final minTemps = daily['temperature_2m_min'] as List<dynamic>? ?? [];
        final codes = daily['weather_code'] as List<dynamic>? ?? [];
        final rain = daily['precipitation_probability_max'] as List<dynamic>? ?? [];
        final sunrises = daily['sunrise'] as List<dynamic>? ?? [];
        final sunsets = daily['sunset'] as List<dynamic>? ?? [];

        if (sunrises.isNotEmpty && sunrises[0] != null) {
          sunrise.value = DateTime.tryParse(sunrises[0].toString());
        }
        if (sunsets.isNotEmpty && sunsets[0] != null) {
          sunset.value = DateTime.tryParse(sunsets[0].toString());
        }

        final len = [times.length, maxTemps.length, minTemps.length, codes.length, rain.length]
            .reduce((a, b) => a < b ? a : b);
        forecast.value = List.generate(len, (i) {
          return DailyForecast(
            date: DateTime.parse(times[i]),
            maxTemp: (maxTemps[i] as num).toDouble(),
            minTemp: (minTemps[i] as num).toDouble(),
            weatherCode: (codes[i] as num).toInt(),
            precipitationProbability: (rain[i] as num?)?.toInt() ?? 0,
          );
        });
      }
      final hourly = data['hourly'];
      if (hourly != null) {
        final times = hourly['time'] as List<dynamic>? ?? [];
        final temps = hourly['temperature_2m'] as List<dynamic>? ?? [];
        final codes = hourly['weather_code'] as List<dynamic>? ?? [];
        final rain = hourly['precipitation_probability'] as List<dynamic>? ?? [];

        final now = DateTime.now();
        final hLen = [times.length, temps.length, codes.length, rain.length]
            .reduce((a, b) => a < b ? a : b);
        final result = <HourlyForecast>[];
        for (int i = 0; i < hLen && result.length < 24; i++) {
          final t = DateTime.parse(times[i]);
          if (t.isBefore(now)) continue;
          result.add(HourlyForecast(
            time: t,
            temperature: (temps[i] as num).toDouble(),
            weatherCode: (codes[i] as num).toInt(),
            precipitationProbability: (rain[i] as num?)?.toInt() ?? 0,
          ));
        }
        hourlyForecast.value = result;
      }
      _buildHighlights();
      dataFetchTime.value = DateTime.now();
    } catch (_) {
      hasError.value = true;
    }
    isLoading.value = false;
  }

  void _buildHighlights() {
    final cw = currentWeather.value;
    if (cw == null) return;
    highlights.value = [
      WeatherHighlight(label: 'Humidity', value: '${cw.humidity.toInt()}%', subLabel: cw.humidity > 70 ? 'High' : 'Normal'),
      WeatherHighlight(label: 'Wind', value: '${cw.windSpeed.toStringAsFixed(1)} km/h', subLabel: cw.windDirectionText),
      WeatherHighlight(label: 'UV Index', value: cw.uvIndex.toStringAsFixed(1), subLabel: cw.uvLabel),
      WeatherHighlight(label: 'Pressure', value: '${cw.pressure.toStringAsFixed(0)} hPa', subLabel: null),
      WeatherHighlight(label: 'Visibility', value: cw.visibilityText, subLabel: null),
    ];
  }

  String formatTemp(double celsius) {
    return '${convertTemp(celsius).round()}';
  }

  void toggleUnit() {
    isCelsius.value = !isCelsius.value;
  }

  double convertTemp(double celsius) {
    if (isCelsius.value) return celsius;
    return celsius * 9 / 5 + 32;
  }

  String tempString(double celsius) {
    return '${convertTemp(celsius).round()}°';
  }

  String get dayNightString {
    if (forecast.isEmpty) return '';
    return 'Day ${tempString(forecast.first.maxTemp)} · Night ${tempString(forecast.first.minTemp)}';
  }

  String get feelsLikeString {
    final cw = currentWeather.value;
    if (cw == null) return '';
    return 'Feels like ${tempString(cw.feelsLike)}';
  }

  String get lastUpdatedText {
    final t = dataFetchTime.value;
    if (t == null) return 'Just now';
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
