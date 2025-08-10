import 'package:atmus/services/api_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var temperaturaAtual = 25.0.obs;
  var temperaturaMin = 18.0.obs;
  var temperaturaMax = 28.0.obs;
  var sensacaoSol = 27.0.obs;
  var sensacaoChuva = 27.0.obs;
  var descricaoTempo = "Parcialmente nublado".obs;

  var selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getWeather();
  }

  // funçao de teste para dados da API
  void getWeather() async {
    ApiService apiService = ApiService();
    var weatherData = await apiService.fetchCurrentWeather('Recife');

    if (weatherData != null) {
      double temp = weatherData['current']['temp_c']?.toDouble() ?? 0.0;
      double tempMin = weatherData['forecast']?['forecastday']?[0]?['day']?['mintemp_c']?.toDouble() ?? 0.0;
      double tempMax = weatherData['forecast']?['forecastday']?[0]?['day']?['maxtemp_c']?.toDouble() ?? 0.0;
      String desc = weatherData['current']['condition']['text'] ?? 'Sem dados';

      sensacaoSol.value = weatherData['current']['feelslike_c']?.toDouble() ?? 0.0;
      sensacaoChuva.value = weatherData['current']['precip_mm']?.toDouble() ?? 0.0;


      temperaturaAtual.value = temp;
      temperaturaMin.value = tempMin;
      temperaturaMax.value = tempMax;
      descricaoTempo.value = desc;

      print('Temperatura atual: $temp');
    } else {
      print('Falha ao carregar dados do tempo.');
    }
  }
}
