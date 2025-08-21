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
    "Quinta-feira": [0, 0],
    "Sexta-feira": [0, 0],
    "Sábado": [0, 0],
    "Domingo": [0, 0],
  }.obs;

  var temperaturasHora = <String, int>{
    "09:00h": 0,
    "12:00h": 0,
    "15:00h": 0,
    "18:00h": 0,
    "21:00h": 0,
    "00:00h": 0,
    "03:00h": 0,
    "06:00h": 0,
  }.obs;

  var resumo = "".obs;

  var iconesHora = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeatherData("Recife");
  }

  Future<void> fetchWeatherData(String city) async {
    final data = await apiService.fetchWeatherForecast(city);
    print("Dados brutos da API:");
    print(data);
    if (data != null) {
      try {
        resumo.value = data['list'][0]['weather'][0]['description'] ?? "";

        Map<String, List<num>> tempsPorDia = {};

        for (var item in data['list']) {
          final dt = DateTime.parse(item['dt_txt']);
          final diaStr = "${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}";

          final temp = (item['main']['temp'] as num);

          if (!tempsPorDia.containsKey(diaStr)) {
            tempsPorDia[diaStr] = [];
          }
          tempsPorDia[diaStr]!.add(temp);
        }

        temperaturas.clear();

        tempsPorDia.forEach((diaStr, temps) {
          final date = DateTime.parse(diaStr);
          final dayName = _formatDay(date);
          final minTemp = temps.reduce((a, b) => a < b ? a : b).round();
          final maxTemp = temps.reduce((a, b) => a > b ? a : b).round();

          temperaturas[dayName] = [minTemp, maxTemp];
        });

        temperaturas.refresh();

        for (var horaStr in temperaturasHora.keys.toList()) {
          final hourInt = int.parse(horaStr.split(':')[0]);

          final item = data['list'].firstWhere(
                (i) {
              final dt = DateTime.parse(i['dt_txt']);
              return dt.hour == hourInt;
            },
            orElse: () => {},
          );

          if (item.isNotEmpty) {
            temperaturasHora[horaStr] = (item['main']['temp'] as num).round();
            iconesHora[horaStr] = item['weather'][0]['icon'];
          }

          if (item != null) {
            temperaturasHora[horaStr] = (item['main']['temp'] as num).round();
            iconesHora[horaStr] = item['weather'][0]['icon'];
          }
        }

        temperaturasHora.refresh();
        iconesHora.refresh();
      } catch (e) {
        print("Erro ao processar dados de previsão: $e");
      }
    } else {
      print("Dados da API são nulos");
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
    final ontem = hoje.subtract(const Duration(days: 1));

    if (date.day == ontem.day && date.month == ontem.month && date.year == ontem.year) {
      return "Ontem";
    }
    if (date.day == hoje.day && date.month == hoje.month && date.year == hoje.year) {
      return "Hoje";
    }
    return diasSemana[date.weekday] ?? "";
  }
}
