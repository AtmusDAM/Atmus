import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:atmus/data/models/city_model.dart';
import 'package:atmus/data/repositories/weather_repository.dart';
import 'package:atmus/data/models/weather_model.dart';
import '../locais/locais_viewmodel.dart';

class HomeViewModel extends GetxController {
  final WeatherRepository _repository = WeatherRepository();
  final LocaisViewModel locaisController = Get.find<LocaisViewModel>();

  // Navegação inferior
  final selectedIndex = 0.obs;

  // Unidade escolhida (Celsius ou Fahrenheit)
  final RxString unidade = "Celsius".obs;

  // Clima atual exibido no Home
  final temperaturaAtual = 0.0.obs;
  final temperaturaMin = 0.0.obs;
  final temperaturaMax = 0.0.obs;
  final sensacaoSol = 0.0.obs;
  final sensacaoChuva = 0.0.obs;
  final descricaoTempo = 'Carregando...'.obs;
  final weatherIcon = ''.obs;

  // --- Estado de cidade ---
  /// Nome vindo do GPS (tem prioridade quando não vazio)
  final RxString gpsCity = ''.obs;

  /// Coordenada do GPS (para recentrar mapas)
  final Rxn<LatLng> gpsCoord = Rxn<LatLng>();

  /// Nome unificado que TODAS as telas devem exibir
  final RxString cityName = 'Carregando...'.obs;

  /// Sinal de “cidade mudou” para outras telas recarregarem dados (forecast, dados+)
  final RxInt cityChanged = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Sempre que a cidade manual mudar, recalcula nome + clima
    ever<CityModel?>(locaisController.selectedCity, (_) => _recomputeCity());

    // Sempre que o GPS mudar, recalcula nome + clima
    ever<String>(gpsCity, (_) => _recomputeCity());

    // Inicial
    _recomputeCity();
  }

  /// Chamado pelo WeatherController quando o GPS dá sucesso
  void setGpsCityAndCoord(String city, double lat, double lon) {
    gpsCity.value = city;
    gpsCoord.value = LatLng(lat, lon);
    // _recomputeCity() será chamado pelo listener de gpsCity
  }

  /// Quando o usuário escolhe cidade manualmente na gaveta,
  /// limpamos o override do GPS para a cidade manual ter prioridade.
  void clearGpsOverride() {
    gpsCity.value = '';
    gpsCoord.value = null;
  }

  /// Recalcula cityName, dispara cityChanged e atualiza clima atual do Home
  Future<void> _recomputeCity() async {
    final manual = locaisController.selectedCity.value?.name?.trim() ?? '';
    final byGps = gpsCity.value.trim();

    // prioridade: GPS se existir, senão manual
    final chosen = byGps.isNotEmpty ? byGps : (manual.isNotEmpty ? manual : 'Carregando...');
    cityName.value = chosen;

    // atualiza clima do Home
    if (chosen != 'Carregando...') {
      await _refreshCurrentWeather(chosen);
    }

    // notifica outras telas para recarregar (Previsão, Dados+)
    cityChanged.value++;
  }

  Future<void> _refreshCurrentWeather(String city) async {
    final Weather? weather = await _repository.getCurrentWeather(city);
    if (weather != null) {
      applyWeather(weather);
    } else {
      descricaoTempo.value = 'Erro ao carregar';
    }
  }

  /// Usado por WeatherController e pela própria tela Home
  void applyWeather(Weather w) {
    temperaturaAtual.value = w.temp;
    temperaturaMin.value = w.tempMin;
    temperaturaMax.value = w.tempMax;
    sensacaoSol.value = w.feelsLike;
    sensacaoChuva.value = w.rain1h;
    descricaoTempo.value = w.description;
    weatherIcon.value = w.icon;
  }

  // --- Conversão de unidades ---
  double _toFahrenheit(double celsius) => (celsius * 9 / 5) + 32;

  double displayTemp(double value) {
    return unidade.value == "Fahrenheit" ? _toFahrenheit(value) : value;
  }

  String get unidadeSimbolo => unidade.value == "Fahrenheit" ? "ºF" : "ºC";
}
