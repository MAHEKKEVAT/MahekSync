// lib/app/services/weather_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maheksync/app/models/weather_model.dart';

class WeatherApi {
  static const _baseUrl = 'https://api.open-meteo.com/v1';
  static const _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1';

  static Future<Map<String, dynamic>> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/forecast'
      '?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure,uv_index,visibility'
      '&hourly=temperature_2m,weather_code,precipitation_probability'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset'
      '&timezone=auto&forecast_days=7',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load weather data');
    }
    return json.decode(response.body);
  }

  static Future<List<CitySearchResult>> searchCity(String query) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse(
      '$_geocodingUrl/search?name=${Uri.encodeComponent(query)}&count=5&language=en',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return [];
    final data = json.decode(response.body);
    final results = data['results'] as List<dynamic>?;
    if (results == null) return [];
    return results.map((e) => CitySearchResult.fromJson(e)).toList();
  }
}
