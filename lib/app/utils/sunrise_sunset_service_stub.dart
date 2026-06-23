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
    return SunriseSunsetResult(
      sunrise: _fallbackSunrise,
      sunset: _fallbackSunset,
      fromAPI: false,
    );
  }
}
