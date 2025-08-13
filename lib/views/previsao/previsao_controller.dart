import 'package:get/get.dart';
import '../../services/api_service.dart';

class PrevisaoController extends GetxController {
  final ApiService apiService = ApiService();

  var temperaturas = <String, List<int>>{
    "Ontem": [0, 0],
    "Hoje": [0, 0],
    "Segunda": [0, 0],
    "Terça-feira": [0, 0],
    "Quarta-feira": [0, 0],
    "Sábado": [0, 0],
  }.obs;

  var temperaturasHora = <String, int>{
    "11:00h": 0,
    "12:00h": 0,
    "13:00h": 0,
    "14:00h": 0,
    "15:00h": 0,
    "16:00h": 0,
    "17:00h": 0,
    "18:00h": 0,
    "19:00h": 0,
    "20:00h": 0,
  }.obs;

  var resumo = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeatherData("Recife");
  }

  Future<void> fetchWeatherData(String city) async {
    final data = await apiService.fetchCurrentWeather(city);
    if (data != null) {
      try {
        // Atualiza resumo
        resumo.value = data['forecast']['forecastday'][0]['day']['condition']['text'] ?? "";

        // Atualiza temperaturas diárias
        for (var day in data['forecast']['forecastday']) {
          final date = DateTime.parse(day['date']);
          final diaSemana = _formatDay(date);

          temperaturas[diaSemana] = [
            (day['day']['mintemp_c'] as num).round(),
            (day['day']['maxtemp_c'] as num).round(),
          ];
        }

        // Atualiza temperaturas por hora (do dia atual)
        final hours = data['forecast']['forecastday'][0]['hour'];
        for (var hora in temperaturasHora.keys.toList()) {
          final hourInt = int.parse(hora.split(':')[0]);
          final entry = hours.firstWhere(
                (h) => DateTime.parse(h['time']).hour == hourInt,
            orElse: () => null,
          );
          if (entry != null) {
            temperaturasHora[hora] = (entry['temp_c'] as num).round();
          }
        }
      } catch (e) {
        print("Erro ao processar dados de previsão: $e");
      }
    }
  }

  String _formatDay(DateTime date) {
    final diasSemana = {
      1: "Segunda",
      2: "Terça-feira",
      3: "Quarta-feira",
      4: "Quinta-feira",
      5: "Sexta-feira",
      6: "Sábado",
      7: "Domingo",
    };
    final hoje = DateTime.now();
    final ontem = hoje.subtract(Duration(days: 1));

    if (date.day == ontem.day && date.month == ontem.month) return "Ontem";
    if (date.day == hoje.day && date.month == hoje.month) return "Hoje";
    return diasSemana[date.weekday] ?? "";
  }
}
