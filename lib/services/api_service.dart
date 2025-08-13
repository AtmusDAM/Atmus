import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _apiKey = dotenv.env['API_KEY'] ?? 'missing_api_key';
  final String _host = dotenv.env['API_HOST'] ?? 'missing_api_host';

  Future<Map<String, dynamic>?> fetchCurrentWeather(String city) async {
    final url = Uri.https(_host, '/data/2.5/weather', {
      'q': city,
      'appid': _apiKey,
      'lang': 'pt_br',
      'units': 'metric',
    });

    try {
      final response = await http.get(url);
      print('[Weather] GET $url -> ${response.statusCode}');
      print('[Weather] body: ${response.body}');

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
}
