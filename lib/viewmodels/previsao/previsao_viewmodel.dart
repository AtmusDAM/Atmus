import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/forecast_model.dart';
import '../../data/repositories/weather_repository.dart';

class PrevisaoViewModel extends GetxController {
  final WeatherRepository _repository = WeatherRepository();

  var temperaturas = <String, List<int>>{}.obs;
  var temperaturasHora = <String, int>{}.obs;
  var resumo = "Carregando...".obs;
  var iconesHora = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeatherData("Recife");
  }

  Future<void> fetchWeatherData(String city) async {
    final Forecast? forecast = await _repository.getWeatherForecast(city);
    if (forecast != null && forecast.items.isNotEmpty) {
      resumo.value = forecast.items.first.description;
      _processDailyForecast(forecast.items);
      _processHourlyForecast(forecast.items);
    } else {
      resumo.value = "Erro ao carregar previsão";
    }
  }

  void _processDailyForecast(List<ForecastItem> items) {
    final Map<String, List<double>> tempsByDay = {};
    for (var item in items) {
      final dayKey = DateFormat('yyyy-MM-dd').format(item.dateTime);
      if (!tempsByDay.containsKey(dayKey)) {
        tempsByDay[dayKey] = [];
      }
      tempsByDay[dayKey]!.add(item.temp);
    }

    final Map<String, List<int>> processedTemps = {};
    tempsByDay.forEach((day, temps) {
      final date = DateTime.parse(day);
      final dayName = _formatDay(date);
      final minTemp = temps.reduce((a, b) => a < b ? a : b).round();
      final maxTemp = temps.reduce((a, b) => a > b ? a : b).round();
      processedTemps[dayName] = [minTemp, maxTemp];
    });

    temperaturas.value = processedTemps;
  }

  void _processHourlyForecast(List<ForecastItem> items) {
    final Map<String, int> hourlyTemps = {};
    final Map<String, String> hourlyIcons = {};

    final now = DateTime.now();
    final next24Hours = items.where((item) =>
    item.dateTime.isAfter(now) &&
        item.dateTime.isBefore(now.add(const Duration(hours: 24))));

    for (var item in next24Hours) {
      final hourKey = DateFormat('HH:00').format(item.dateTime);
      hourlyTemps[hourKey] = item.temp.round();
      hourlyIcons[hourKey] = item.icon;
    }

    temperaturasHora.value = hourlyTemps;
    iconesHora.value = hourlyIcons;
  }

  String _formatDay(DateTime date) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return "Hoje";
    }
    if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return "Amanhã";
    }
    return DateFormat('EEEE', 'pt_BR').format(date);
  }
}
