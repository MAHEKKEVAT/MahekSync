// lib/app/models/weather_model.dart

class CurrentWeather {
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final int windDirection;
  final double pressure;
  final double uvIndex;
  final int weatherCode;
  final double visibility;

  CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.uvIndex,
    required this.weatherCode,
    this.visibility = 0,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0,
      feelsLike: (json['apparent_temperature'] as num?)?.toDouble() ?? 0,
      humidity: (json['relative_humidity_2m'] as num?)?.toDouble() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      windDirection: (json['wind_direction_10m'] as num?)?.toInt() ?? 0,
      pressure: (json['surface_pressure'] as num?)?.toDouble() ?? 0,
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      visibility: (json['visibility'] as num?)?.toDouble() ?? 0,
    );
  }

  String get conditionText => weatherCodeToText(weatherCode);
  String get windDirectionText => _degreesToDirection(windDirection.clamp(0, 359));
  String get uvLabel {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  String get visibilityText {
    if (visibility <= 0) return '—';
    final km = visibility / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  static String weatherCodeToText(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1) return 'Mainly Clear';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 55) return 'Drizzle';
    if (code <= 57) return 'Freezing Drizzle';
    if (code <= 65) return 'Rainy';
    if (code <= 67) return 'Freezing Rain';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Rain Showers';
    if (code <= 86) return 'Snow Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static String weatherCondition(int code) {
    if (code == 0) return 'clear';
    if (code <= 3) return 'cloudy';
    if (code <= 48) return 'foggy';
    if (code <= 57) return 'rainy';
    if (code <= 67) return 'rainy';
    if (code <= 77) return 'snowy';
    if (code <= 82) return 'rainy';
    if (code <= 86) return 'snowy';
    if (code <= 99) return 'stormy';
    return 'clear';
  }

  static bool isRainCode(int code) {
    return (code >= 51 && code <= 57) ||
           (code >= 61 && code <= 67) ||
           (code >= 80 && code <= 82);
  }

  static bool isSnowCode(int code) {
    return (code >= 71 && code <= 77) ||
           (code >= 85 && code <= 86);
  }

  static String _degreesToDirection(int degrees) {
    const dirs = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
                  'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    return dirs[((degrees + 11.25) / 22.5).floor() % 16];
  }
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final int precipitationProbability;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.precipitationProbability,
  });
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });
}

class CitySearchResult {
  final String name;
  final String? admin1;
  final String? country;
  final double latitude;
  final double longitude;

  CitySearchResult({
    required this.name,
    this.admin1,
    this.country,
    required this.latitude,
    required this.longitude,
  });

  factory CitySearchResult.fromJson(Map<String, dynamic> json) {
    return CitySearchResult(
      name: json['name'] ?? '',
      admin1: json['admin1'],
      country: json['country'],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  String get displayName {
    final parts = <String>[name];
    if (admin1 != null && admin1!.isNotEmpty) parts.add(admin1!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}

class WeatherHighlight {
  final String label;
  final String value;
  final String? subLabel;

  WeatherHighlight({required this.label, required this.value, this.subLabel});
}
