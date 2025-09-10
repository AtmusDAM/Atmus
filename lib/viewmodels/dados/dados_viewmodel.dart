import 'package:get/get.dart';

import 'package:atmus/data/repositories/weather_repository.dart';
import 'package:atmus/data/models/forecast_model.dart';
import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/data/models/city_model.dart';

class DadosViewModel extends GetxController {
  final WeatherRepository _repository = WeatherRepository();
  final LocaisViewModel _locais = Get.find<LocaisViewModel>();
  final HomeViewModel _home = Get.find<HomeViewModel>();

  LocaisViewModel get locaisController => _locais;

  final isLoading = false.obs;
  final error = RxnString();

  final pressao = 0.obs;     // hPa
  final umidade = 0.obs;     // %
  final ventoMs = 0.0.obs;   // m/s
  final uv = 'N/D'.obs;

  final chuvaManha = 0.obs;  // %
  final chuvaTarde = 0.obs;  // %
  final chuvaNoite = 0.obs;  // %

  final vento = 0.0.obs;       // alias de ventoMs (double)
  final ventoInt = 0.obs;      // versão inteira para UIs que esperam RxInt
  final indiceUV = 'N/D'.obs;  // alias de uv
  final precipitacaoManha = 0.obs; // alias de chuvaManha
  final precipitacaoTarde = 0.obs; // alias de chuvaTarde
  final precipitacaoNoite = 0.obs; // alias de chuvaNoite

  @override
  void onInit() {
    super.onInit();

    _run();

    ever<CityModel?>(_locais.selectedCity, (_) => _run());

    ever<String>(_home.lastQuery, (_) => _run());
  }

  void refreshFromSelection() {
    _run();
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
        error.value = 'Falha ao carregar dados.';
        isLoading.value = false;
        return;
      }

      final now = DateTime.now();
      ForecastItem current = f.items.first;
      for (final it in f.items) {
        final curDiff = (current.dateTime.difference(now)).inMinutes.abs();
        final itDiff = (it.dateTime.difference(now)).inMinutes.abs();
        if (itDiff < curDiff) current = it;
      }

      pressao.value = current.pressure;
      umidade.value = current.humidity;

      ventoMs.value = current.windMs;
      vento.value   = current.windMs;
      ventoInt.value = current.windMs.round();

      uv.value = 'N/D';
      indiceUV.value = 'N/D';

      double manhaSum = 0.0, tardeSum = 0.0, noiteSum = 0.0;
      int manhaCount = 0, tardeCount = 0, noiteCount = 0;

      for (final item in f.items) {
        if (item.dateTime.isAfter(now) &&
            item.dateTime.isBefore(now.add(const Duration(hours: 24)))) {
          final h = item.dateTime.hour;
          if (h >= 6 && h < 12) {
            manhaSum += item.pop;
            manhaCount++;
          } else if (h >= 12 && h < 18) {
            tardeSum += item.pop;
            tardeCount++;
          } else {
            // noite (18–24) e madrugada (0–6)
            noiteSum += item.pop;
            noiteCount++;
          }
        }
      }

      int _avgPct(double s, int c) => (c == 0) ? 0 : ((s / c) * 100).round();

      chuvaManha.value = _avgPct(manhaSum, manhaCount);
      chuvaTarde.value = _avgPct(tardeSum, tardeCount);
      chuvaNoite.value = _avgPct(noiteSum, noiteCount);

      precipitacaoManha.value = chuvaManha.value;
      precipitacaoTarde.value = chuvaTarde.value;
      precipitacaoNoite.value = chuvaNoite.value;
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
}
