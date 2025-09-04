import 'package:atmus/data/models/city_model.dart';
import 'package:get/get.dart';

import '../../data/repositories/weather_repository.dart';
import '../../data/models/weather_model.dart';

// para receber o Weather do serviço (GPS via WeatherController)
import 'package:atmus/data/weather_service.dart' as svc;

import '../locais/locais_viewmodel.dart';

class HomeViewModel extends GetxController {
  final WeatherRepository _repository = WeatherRepository();
  final LocaisViewModel locaisController = Get.find<LocaisViewModel>();

  var selectedIndex = 0.obs;

  // === Estados que a UI já usa ===
  var temperaturaAtual = 0.0.obs;
  var temperaturaMin = 0.0.obs;
  var temperaturaMax = 0.0.obs;
  var sensacaoSol = 0.0.obs;     // feels_like
  var sensacaoChuva = 0.0.obs;   // rain 1h (mm)
  var descricaoTempo = 'Carregando...'.obs;
  var weatherIcon = ''.obs;

  // NOVO: nome vindo do GPS (tem prioridade no header quando não vazio)
  var gpsCity = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Recarrega quando mudar a cidade da gaveta
    ever(locaisController.selectedCity, (_) => getWeather());
    // Primeira carga
    getWeather();
  }

  /// Fluxo por cidade (gaveta) via repository
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

      // quando vem por cidade, usamos o nome da gaveta
      gpsCity.value = ''; // limpa para o header voltar a usar a cidade selecionada
    } else {
      descricaoTempo.value = 'Erro ao carregar';
    }
  }

  /// Recebe o clima obtido por GPS (WeatherService via WeatherController)
  void applyWeather(svc.Weather w) {
    // cidade do GPS tem prioridade no header
    gpsCity.value = w.city;

    temperaturaAtual.value = w.tempC;
    descricaoTempo.value = w.condition;
    weatherIcon.value = w.iconUrl;

    // usar min/max do serviço quando disponíveis; se 0, caia para tempC
    temperaturaMin.value = (w.tempMinC != 0.0) ? w.tempMinC : w.tempC;
    temperaturaMax.value = (w.tempMaxC != 0.0) ? w.tempMaxC : w.tempC;

    // sensação e precipitação vindas do endpoint atual
    sensacaoSol.value = w.feelsLikeC;   // feels_like (°C)
    sensacaoChuva.value = w.rain1hMm;   // chuva última hora (mm)

    update(); // caso exista GetBuilder em alguma parte
  }
}
