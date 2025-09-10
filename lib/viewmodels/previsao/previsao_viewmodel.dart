import 'package:atmus/data/services/api_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:atmus/data/repositories/weather_repository.dart';
import 'package:atmus/data/models/forecast_model.dart';
import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/data/models/city_model.dart';

class PrevisaoViewModel extends GetxController {
  final WeatherRepository _repository = WeatherRepository();
  final ApiService _api = ApiService();

  final LocaisViewModel _locais = Get.find<LocaisViewModel>();
  final HomeViewModel _home = Get.find<HomeViewModel>();

  LocaisViewModel get locaisController => _locais;

  final isLoading = false.obs;
  final error = RxnString();
  final forecast = Rxn<Forecast>();

  final RxString resumo = 'Carregando...'.obs;

  final RxMap<String, int> temperaturasHora = <String, int>{}.obs;

  final RxMap<String, String> iconesHora = <String, String>{}.obs;

  final RxMap<String, List<int>> temperaturas = <String, List<int>>{}.obs;

  final RxList<Map<String, dynamic>> alerts = <Map<String, dynamic>>[].obs;


  @override
  void onInit() {
    super.onInit();

    _run();

    ever<CityModel?>(_locais.selectedCity, (_) => _run());

    ever<String>(_home.lastQuery, (_) => _run());
  }

  Future<void> _run() async {
    isLoading.value = true;
    error.value = null;

    final city = _locais.selectedCity.value;

    if (city != null && city.lat != null && city.lon != null) {
      final oneCall = await _api.fetchWeatherOneCall(city.lat!, city.lon!);
      if (oneCall != null && oneCall.containsKey('alerts')) {
        final List<dynamic> raw = oneCall['alerts'];
        alerts.value = raw.cast<Map<String, dynamic>>();
      } else {
        alerts.clear();
      }
    }

    try {
      final cityName = _resolveCityName();
      if (cityName == null || cityName.trim().isEmpty) {
        error.value = 'Cidade não definida.';
        return;
      }

      final Forecast? f = await _repository.getWeatherForecast(cityName);
      if (f == null || f.items.isEmpty) {
        error.value = 'Falha ao carregar previsão.';
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

  String? _resolveCityName() {
    final selected = _locais.selectedCity.value?.name;
    if (selected != null && selected.trim().isNotEmpty) {
      return selected.trim();
    }

    try {
      final dynamic j = _home.weatherJson.value;
      if (j is Map<String, dynamic>) {
        final name = (j['name'] ?? '') as String;
        if (name.trim().isNotEmpty) return name.trim();
      }
    } catch (_) {
    }

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
      iconesHora[key] = item.icon;
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
