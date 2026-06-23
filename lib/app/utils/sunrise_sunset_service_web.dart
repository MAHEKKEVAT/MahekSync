import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:geolocator/geolocator.dart' as geo;

class SunriseSunsetResult {
  final DateTime sunrise;
  final DateTime sunset;
  final bool fromAPI;

  const SunriseSunsetResult({
    required this.sunrise,
    required this.sunset,
    required this.fromAPI,
  });
}

class SunriseSunsetService {
  static DateTime? _cachedSunrise;
  static DateTime? _cachedSunset;
  static String? _cachedDate;

  static const _fallbackSunriseHour = 6;
  static const _fallbackSunsetHour = 18;

  static DateTime get _fallbackSunrise {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, _fallbackSunriseHour);
  }

  static DateTime get _fallbackSunset {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, _fallbackSunsetHour);
  }

  static Future<SunriseSunsetResult> fetch() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (_cachedDate == today &&
        _cachedSunrise != null &&
        _cachedSunset != null) {
      return SunriseSunsetResult(
        sunrise: _cachedSunrise!,
        sunset: _cachedSunset!,
        fromAPI: true,
      );
    }

    try {
      final position = await _getPosition().timeout(const Duration(seconds: 6));
      if (position == null) return _fallback();

      final url =
          'https://api.sunrise-sunset.org/json?lat=${position['lat']}&lng=${position['lng']}&formatted=0';

      final body = await html.HttpRequest.getString(url)
          .timeout(const Duration(seconds: 6));
      final data = json.decode(body);
      if (data['status'] != 'OK') return _fallback();

      final results = data['results'];
      final sunrise = DateTime.parse(results['sunrise']).toLocal();
      final sunset = DateTime.parse(results['sunset']).toLocal();

      _cachedSunrise = sunrise;
      _cachedSunset = sunset;
      _cachedDate = today;

      return SunriseSunsetResult(
        sunrise: sunrise,
        sunset: sunset,
        fromAPI: true,
      );
    } catch (_) {
      return _fallback();
    }
  }

  static SunriseSunsetResult _fallback() {
    return SunriseSunsetResult(
      sunrise: _fallbackSunrise,
      sunset: _fallbackSunset,
      fromAPI: false,
    );
  }

  static Future<Map<String, double>?> _getPosition() async {
    try {
      final permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        return null;
      }
      final pos = await geo.Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 6),
      );
      return {'lat': pos.latitude, 'lng': pos.longitude};
    } catch (_) {
      return null;
    }
  }
}
