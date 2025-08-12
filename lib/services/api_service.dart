import 'dart:convert';
import 'package:http/http.dart' as http;

// esboço do apiService(adicionar chave)
class ApiService {
  final String apiKey = 'CHAVE_API';
  final String baseUrl = 'http://api.weatherapi.com/v1';

  Future<Map<String, dynamic>?> fetchCurrentWeather(String city) async {
    final url = Uri.parse('$baseUrl/current.json?key=$apiKey&q=$city&lang=pt');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Erro ao buscar dados: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro na requisição: $e');
      return null;
    }
  }
}
