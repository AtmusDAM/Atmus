// lib/data/repositories/weather_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:atmus/secrets.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart'; // ADD: modelo da previsão

class WeatherRepository {
  static const String _host = 'api.openweathermap.org';

  WeatherRepository();

  Future<Weather?> getCurrentWeather(String city) async {
    try {
      final uri = Uri.https(_host, '/data/2.5/weather', {
        'q': city,
        'appid': Secrets.weatherApiKey,
        'units': 'metric',
        'lang': 'pt_br',
      });

      final res = await http.get(uri);
      if (res.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> data = json.decode(res.body);
      final Map<String, dynamic> main = data['main'] ?? {};
      final Map<String, dynamic> wind = data['wind'] ?? {};
      final Map<String, dynamic> rain = data['rain'] ?? {};
      final List weatherList = (data['weather'] ?? []) as List;
      final Map<String, dynamic> first =
      weatherList.isNotEmpty ? weatherList.first as Map<String, dynamic> : {};

      double _toD(dynamic v) => (v is num) ? v.toDouble() : 0.0;
      int _toI(dynamic v) => (v is num) ? v.toInt() : 0;

      return Weather(
        temp: _toD(main['temp']),
        tempMin: _toD(main['temp_min']),
        tempMax: _toD(main['temp_max']),
        feelsLike: _toD(main['feels_like']),
        pressure: _toI(main['pressure']),
        humidity: _toI(main['humidity']),
        windSpeed: _toD(wind['speed']),
        rain1h: _toD(rain['1h']),
        description: (first['description'] ?? '').toString(),
        icon: (first['icon'] ?? '').toString().isEmpty
            ? ''
            : 'https://openweathermap.org/img/wn/${first['icon']}@2x.png',
      );
    } catch (_) {
      return null;
    }
  }

  /// NOVO: previsão 5 dias / 3h
  Future<Forecast?> getWeatherForecast(String city) async {
    try {
      final uri = Uri.https(_host, '/data/2.5/forecast', {
        'q': city,
        'appid': Secrets.weatherApiKey,
        'units': 'metric',
        'lang': 'pt_br',
      });

      final res = await http.get(uri);
      if (res.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> data = json.decode(res.body);
      return Forecast.fromJson(data); // Usa seu Forecast model
    } catch (_) {
      return null;
    }
  }
}
