import 'package:atmus/data/models/city_model.dart';
import 'package:get/get.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/models/weather_model.dart';
import '../locais/locais_viewmodel.dart';

class HomeViewModel extends GetxController {
  final WeatherRepository _repository = WeatherRepository();

  final LocaisViewModel locaisController = Get.find<LocaisViewModel>();

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

    ever(locaisController.selectedCity, (_) => getWeather());

    getWeather();
  }

  Future<void> getWeather() async {
    final CityModel? cidade = locaisController.selectedCity.value;
    if (cidade == null) return;

    final Weather? weather = await _repository.getCurrentWeather(cidade.name);

    if (weather != null) {
      temperaturaAtual.value = weather.temp;
      temperaturaMin.value = weather.tempMin;
      temperaturaMax.value = weather.tempMax;
      sensacaoSol.value = weather.feelsLike;
      sensacaoChuva.value = weather.rain1h;
      descricaoTempo.value = weather.description;
      weatherIcon.value = weather.icon;
    } else {
      descricaoTempo.value = 'Erro ao carregar';
    }
  }
}
