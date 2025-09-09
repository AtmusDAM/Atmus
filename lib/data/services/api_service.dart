import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/city_model.dart';

class ApiService {
  static const String apiKey = 'b2a53975e7848b3254d83a2a62116856';
  final String host = 'api.openweathermap.org';

  Future<Map<String, dynamic>?> fetchCurrentWeather(String city) async {
    final url = Uri.https(host, '/data/2.5/weather', {
      'q': city,
      'appid': apiKey,
      'lang': 'pt_br',
      'units': 'metric',
    });

    try {
      final response = await http.get(url);
      print('[Weather] GET $url -> ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('[Weather] Erro na requisição: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchWeatherForecast(String city) async {
    final url = Uri.https(host, '/data/2.5/forecast', {
      'q': city,
      'appid': apiKey,
      'lang': 'pt_br',
      'units': 'metric',
    });

    try {
      final response = await http.get(url);
      print('[Forecast] GET $url -> ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('[Forecast] Erro na requisição: $e');
      return null;
    }
  }

  Future<List<CityModel>> searchCities(String cityName) async {
    final url = Uri.https(
      host,
      '/geo/1.0/direct',
      {'q': cityName, 'limit': '15', 'appid': apiKey, 'lang': 'pt_br'},
    );

    try {
      final response = await http.get(url);
      print('[Geo] GET $url -> ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CityModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('[Geo] Erro na requisição: $e');
      return [];
    }
  }
}
