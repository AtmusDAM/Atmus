import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherServiceFailure implements Exception {
  final String message;
  WeatherServiceFailure(this.message);
  @override
  String toString() => message;
}

class Weather {
  final String city;
  final double tempC;
  final String condition;
  final String iconUrl;
  final double tempMinC;
  final double tempMaxC;
  final double feelsLikeC;
  final double rain1hMm;
  final int humidity;
  final int pressure;
  final double windMs;

  Weather({
    required this.city,
    required this.tempC,
    required this.condition,
    required this.iconUrl,
    required this.tempMinC,
    required this.tempMaxC,
    required this.feelsLikeC,
    required this.rain1hMm,
    required this.humidity,
    required this.pressure,
    required this.windMs,
  });

  factory Weather.fromOpenWeatherJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString();
    final main = json['main'] ?? {};
    final weatherList = (json['weather'] is List) ? json['weather'] as List : const [];
    final first = weatherList.isNotEmpty ? (weatherList.first as Map<String, dynamic>) : {};
    final icon = (first['icon'] ?? '').toString(); // ex: "10d"
    final iconUrl = icon.isEmpty ? '' : 'https://openweathermap.org/img/wn/$icon@2x.png';
    final rain = (json['rain'] is Map) ? json['rain'] as Map<String, dynamic> : const {};
    final wind = (json['wind'] is Map) ? json['wind'] as Map<String, dynamic> : const {};

    double _toD(dynamic v) => (v is num) ? v.toDouble() : 0.0;
    int _toI(dynamic v) => (v is num) ? v.toInt() : 0;

    return Weather(
      city: name,
      tempC: _toD(main['temp']),
      condition: (first['description'] ?? '').toString(),
      iconUrl: iconUrl,
      tempMinC: _toD(main['temp_min']),
      tempMaxC: _toD(main['temp_max']),
      feelsLikeC: _toD(main['feels_like']),
      rain1hMm: _toD(rain['1h']),
      humidity: _toI(main['humidity']),
      pressure: _toI(main['pressure']),
      windMs: _toD(wind['speed']),
    );
  }
}

class WeatherService {
  final String apiKey;
  final http.Client _client;

  WeatherService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  static const String _host = 'api.openweathermap.org';

  WeatherServiceFailure _failureFromResponse(http.Response res) {
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map && decoded['message'] != null) {
        return WeatherServiceFailure('HTTP ${res.statusCode} – ${decoded['message']}');
      }
    } catch (_) {}
    return WeatherServiceFailure('Erro ao consultar OpenWeather: HTTP ${res.statusCode}');
  }

  /// Clima atual por CIDADE
  Future<Weather> getByCity(String city) async {
    final uri = Uri.https(_host, '/data/2.5/weather', {
      'q': city,
      'appid': apiKey,
      'units': 'metric',
      'lang': 'pt_br',
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) throw _failureFromResponse(res);
    final data = json.decode(res.body) as Map<String, dynamic>;
    return Weather.fromOpenWeatherJson(data);
  }

  /// Clima atual por LAT/LON (GPS)
  Future<Weather> getCurrentByLatLon(double lat, double lon) async {
    final uri = Uri.https(_host, '/data/2.5/weather', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': apiKey,
      'units': 'metric',
      'lang': 'pt_br',
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) throw _failureFromResponse(res);
    final data = json.decode(res.body) as Map<String, dynamic>;
    return Weather.fromOpenWeatherJson(data);
  }

  Future<Weather> getByLatLon(double lat, double lon) {
    return getCurrentByLatLon(lat, lon);
  }
}
