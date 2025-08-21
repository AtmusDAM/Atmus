import 'package:get/get.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/models/weather_model.dart';

class HomeViewModel extends GetxController {
  final WeatherRepository _repository = WeatherRepository();

  var selectedIndex = 0.obs;

  var temperaturaAtual = 0.0.obs;
  var temperaturaMin = 0.0.obs;
  var temperaturaMax = 0.0.obs;
  var sensacaoSol = 0.0.obs;
  var sensacaoChuva = 0.0.obs;
  var descricaoTempo = 'Carregando...'.obs;
  var weatherIcon = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getWeather();
  }

  Future<void> getWeather() async {
    final Weather? weather = await _repository.getCurrentWeather('Recife,BR');

    if (weather != null) {
      temperaturaAtual.value = weather.temp;
      temperaturaMin.value = weather.tempMin;
      temperaturaMax.value = weather.tempMax;
      sensacaoSol.value = weather.feelsLike;
      sensacaoChuva.value = weather.rain1h;
      descricaoTempo.value = weather.description;
      weatherIcon.value = weather.icon;
    } else {
      print('Falha ao carregar dados do tempo.');
      descricaoTempo.value = 'Erro ao carregar';
    }
  }
}
