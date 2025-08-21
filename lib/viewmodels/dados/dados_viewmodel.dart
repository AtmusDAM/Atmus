import 'package:get/get.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/forecast_model.dart';

class DadosViewModel extends GetxController {
  final WeatherRepository _repository = WeatherRepository();

  var pressao = 0.0.obs;
  var umidade = 0.obs;
  var vento = 0.0.obs;
  var indiceUV = "N/D".obs; // UV index is not in the current API response

  var precipitacaoManha = 0.obs;
  var precipitacaoTarde = 0.obs;
  var precipitacaoNoite = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final Weather? weather = await _repository.getCurrentWeather("Recife,BR");
    if (weather != null) {
      pressao.value = weather.pressure.toDouble();
      umidade.value = weather.humidity;
      vento.value = weather.windSpeed;
    }

    final Forecast? forecast = await _repository.getWeatherForecast("Recife,BR");
    if (forecast != null) {
      _calculatePrecipitation(forecast.items);
    }
  }

  void _calculatePrecipitation(List<ForecastItem> forecastItems) {
    double manhaSum = 0;
    int manhaCount = 0;
    double tardeSum = 0;
    int tardeCount = 0;
    double noiteSum = 0;
    int noiteCount = 0;

    for (var item in forecastItems) {
      final hour = item.dateTime.hour;
      if (hour >= 6 && hour < 12) {
        manhaSum += item.pop;
        manhaCount++;
      } else if (hour >= 12 && hour < 18) {
        tardeSum += item.pop;
        tardeCount++;
      } else if (hour >= 18 || hour < 6) { // Night can span across midnight
        noiteSum += item.pop;
        noiteCount++;
      }
    }

    precipitacaoManha.value = manhaCount > 0 ? ((manhaSum / manhaCount) * 100).round() : 0;
    precipitacaoTarde.value = tardeCount > 0 ? ((tardeSum / tardeCount) * 100).round() : 0;
    precipitacaoNoite.value = noiteCount > 0 ? ((noiteSum / noiteCount) * 100).round() : 0;
  }
}
