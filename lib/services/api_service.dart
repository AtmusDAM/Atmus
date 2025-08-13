import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey = 'b2a53975e7848b3254d83a2a62116856';
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
