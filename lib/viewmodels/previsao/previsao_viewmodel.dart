import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:atmus/data/repositories/weather_repository.dart';
import 'package:atmus/data/models/forecast_model.dart';
import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/data/models/city_model.dart';

class PrevisaoViewModel extends GetxController {
  final WeatherRepository _repository = WeatherRepository();

  // Dependências reais
  final LocaisViewModel _locais = Get.find<LocaisViewModel>();
  final HomeViewModel _home = Get.find<HomeViewModel>();

  // === ALIASES para a página (mantém compatibilidade com sua UI) ===
  LocaisViewModel get locaisController => _locais;

  // Estado básico
  final isLoading = false.obs;
  final error = RxnString();
  final forecast = Rxn<Forecast>();

  // === CAMPOS QUE A PÁGINA USA ===
  final RxString resumo = 'Carregando...'.obs;

  /// "HH:00" -> temperatura (int)
  final RxMap<String, int> temperaturasHora = <String, int>{}.obs;

  /// "HH:00" -> ícone (código ou URL)
  final RxMap<String, String> iconesHora = <String, String>{}.obs;

  /// "Hoje/Amanhã/segunda..." -> [min, max]
  final RxMap<String, List<int>> temperaturas = <String, List<int>>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // 1) carga inicial
    _run();

    // 2) quando mudar a cidade da gaveta
    ever<CityModel?>(_locais.selectedCity, (_) => _run());

    // 3) quando a Home mudar a localização efetiva (via GPS ou seleção por lat/lon).
    //    Usamos lastQuery como “sinal” de mudança e tentamos ler o nome da cidade da Home.
    ever<String>(_home.lastQuery, (_) => _run());
  }

  Future<void> _run() async {
    isLoading.value = true;
    error.value = null;

    try {
      final cityName = _resolveCityName();
      if (cityName == null || cityName.trim().isEmpty) {
        error.value = 'Cidade não definida.';
        isLoading.value = false;
        return;
      }

      final Forecast? f = await _repository.getWeatherForecast(cityName);
      if (f == null || f.items.isEmpty) {
        error.value = 'Falha ao carregar previsão.';
        isLoading.value = false;
        return;
      }

      forecast.value = f;

      _buildResumo(f);
      _buildHojeHoraAHora(f);
      _buildDias(f);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Tenta obter o nome da cidade de forma robusta sem depender de gpsCity.
  String? _resolveCityName() {
    // 1) Se a gaveta tiver uma cidade selecionada, priorize essa
    final selected = _locais.selectedCity.value?.name;
    if (selected != null && selected.trim().isNotEmpty) {
      return selected.trim();
    }

    // 2) Caso contrário, tente ler o nome exibido atualmente na Home (se ela expõe weatherJson)
    try {
      final dynamic j = _home.weatherJson.value;
      if (j is Map<String, dynamic>) {
        final name = (j['name'] ?? '') as String;
        if (name.trim().isNotEmpty) return name.trim();
      }
    } catch (_) {
      // se o HomeViewModel não tiver weatherJson, simplesmente ignore
    }

    // 3) Sem fonte de nome
    return null;
  }

  void _buildResumo(Forecast f) {
    if (f.items.isEmpty) {
      resumo.value = '';
      return;
    }
    final now = DateTime.now();
    ForecastItem current = f.items.first;
    for (final it in f.items) {
      final cur = current.dateTime.difference(now).inSeconds.abs();
      final dif = it.dateTime.difference(now).inSeconds.abs();
      if (dif < cur) current = it;
    }
    final desc = current.description;
    resumo.value = desc.isEmpty
        ? ''
        : desc[0].toLowerCase() + (desc.length > 1 ? desc.substring(1) : '');
  }

  void _buildHojeHoraAHora(Forecast f) {
    temperaturasHora.clear();
    iconesHora.clear();

    final now = DateTime.now();
    final within24h = f.items.where((item) =>
    item.dateTime.isAfter(now) &&
        item.dateTime.isBefore(now.add(const Duration(hours: 24))));

    final dfHour = DateFormat('HH:00');
    for (final item in within24h) {
      final key = dfHour.format(item.dateTime);
      temperaturasHora[key] = item.temp.round();
      iconesHora[key] = item.icon; // aceita URL completa ou código
    }
  }

  void _buildDias(Forecast f) {
    temperaturas.clear();

    final dias = f.dailySummaries;

    final today = DateTime.now();
    final dfKey = DateFormat('yyyy-MM-dd');
    final dfWeek = DateFormat('EEEE', 'pt_BR');

    for (final d in dias) {
      final dayDate = DateTime.tryParse('${d.day} 12:00:00') ?? today;
      String label;
      if (dfKey.format(dayDate) == dfKey.format(today)) {
        label = 'Hoje';
      } else if (dfKey.format(dayDate) ==
          dfKey.format(today.add(const Duration(days: 1)))) {
        label = 'Amanhã';
      } else {
        label = dfWeek.format(dayDate);
      }
      temperaturas[label] = [d.tempMinC.round(), d.tempMaxC.round()];
    }
  }
}
