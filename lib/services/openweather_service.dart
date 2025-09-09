import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:atmus/secrets.dart';

class OpenWeatherService {
  // Usa a mesma fonte de chave do projeto
  static String get _apiKey => Secrets.weatherApiKey;

  static const String _baseWeather = 'https://api.openweathermap.org/data/2.5';
  static const String _baseGeo = 'https://api.openweathermap.org/geo/1.0';

  final http.Client _client;
  OpenWeatherService({http.Client? client}) : _client = client ?? http.Client();

  // ---------------- Current weather ----------------
  Future<Map<String, dynamic>> getCurrentByLatLon(double lat, double lon) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenWeather API key ausente (Secrets.weatherApiKey vazio).');
    }
    final uri = Uri.parse('$_baseWeather/weather').replace(queryParameters: {
      'lat': '$lat',
      'lon': '$lon',
      'units': 'metric',
      'lang': 'pt_br',
      'appid': _apiKey,
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Falha /weather (${res.statusCode}): ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ---------------- Direct geocoding ----------------
  Future<List<Map<String, dynamic>>> searchCities(String query, {int limit = 10}) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenWeather API key ausente (Secrets.weatherApiKey vazio).');
    }
    final uri = Uri.parse('$_baseGeo/direct').replace(queryParameters: {
      'q': query,
      'limit': '$limit',
      'appid': _apiKey,
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Falha /geo/direct (${res.statusCode}): ${res.body}');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  // ---------------- Reverse geocoding ----------------
  Future<List<Map<String, dynamic>>> reverseGeocode(double lat, double lon, {int limit = 1}) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenWeather API key ausente (Secrets.weatherApiKey vazio).');
    }
    final uri = Uri.parse('$_baseGeo/reverse').replace(queryParameters: {
      'lat': '$lat',
      'lon': '$lon',
      'limit': '$limit',
      'appid': _apiKey,
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Falha /geo/reverse (${res.statusCode}): ${res.body}');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
