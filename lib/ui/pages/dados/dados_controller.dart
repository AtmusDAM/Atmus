import 'package:get/get.dart';
import 'package:atmus/services/api_service.dart';

class DadosController extends GetxController {
  final ApiService apiService = ApiService();

  // Índice da navegação inferior
  var selectedIndex = 0.obs;

  // Dados principais
  var pressao = 0.0.obs;
  var umidade = 0.obs;
  var vento = 0.obs;
  var indiceUV = "".obs;

  // Precipitação
  var precipitacaoManha = 0.obs;
  var precipitacaoTarde = 0.obs;
  var precipitacaoNoite = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final currentData = await apiService.fetchCurrentWeather("Recife,BR");
    if (currentData != null) {
      pressao.value = (currentData['main']['pressure'] ?? 0).toDouble();
      umidade.value = currentData['main']['humidity'] ?? 0;
      vento.value = ((currentData['wind']['speed'] ?? 0) as num).round();
      indiceUV.value = "N/D";
    }

    final forecastData = await apiService.fetchWeatherForecast("Recife,BR");
    if (forecastData != null && forecastData['list'] != null) {
      List<dynamic> forecastList = forecastData['list'];

      double manhaSum = 0, tardeSum = 0, noiteSum = 0;
      int manhaCount = 0, tardeCount = 0, noiteCount = 0;

      for (var item in forecastList) {
        int dt = item['dt'];
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000, isUtc: true).toLocal();
        double pop = (item['pop'] ?? 0).toDouble();

        int hour = dateTime.hour;

        if (hour >= 6 && hour < 12) {
          manhaSum += pop;
          manhaCount++;
        } else if (hour >= 12 && hour < 18) {
          tardeSum += pop;
          tardeCount++;
        } else if (hour >= 18 && hour < 24) {
          noiteSum += pop;
          noiteCount++;
        }
      }

      precipitacaoManha.value = manhaCount > 0 ? ((manhaSum / manhaCount) * 100).round() : 0;
      precipitacaoTarde.value = tardeCount > 0 ? ((tardeSum / tardeCount) * 100).round() : 0;
      precipitacaoNoite.value = noiteCount > 0 ? ((noiteSum / noiteCount) * 100).round() : 0;
    } else {
      print("[DadosController] Falha ao carregar dados da previsão.");
    }
  }
}
