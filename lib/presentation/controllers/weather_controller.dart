import 'package:get/get.dart';

// Aliases para separar DTO (service) do model do app
import 'package:atmus/data/weather_service.dart' as ws;      // DTOs do serviço HTTP
import 'package:atmus/data/models/weather_model.dart' as wm; // Model oficial do app

import 'package:atmus/presentation/controllers/location_controller.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';

class WeatherController extends GetxController {
  final ws.WeatherService _service;
  WeatherController(this._service);

  final isLoading = false.obs;
  final error = RxnString();

  /// Estado interno (usa o MODEL do app, não o DTO)
  final Rxn<wm.Weather> weather = Rxn<wm.Weather>();

  // ---------- helpers seguros ----------

  T? _safe<T>(T Function() getter) {
    try {
      return getter();
    } catch (_) {
      return null;
    }
  }

  double _toD(dynamic v) => (v is num) ? v.toDouble() : 0.0;
  int _toI(dynamic v) => (v is num) ? v.toInt() : 0;

  double _pickD(dynamic d, List<dynamic Function()> getters, {double def = 0}) {
    for (final g in getters) {
      final v = _safe(g);
      if (v != null) return _toD(v);
    }
    return def;
  }

  int _pickI(dynamic d, List<dynamic Function()> getters, {int def = 0}) {
    for (final g in getters) {
      final v = _safe(g);
      if (v != null) return _toI(v);
    }
    return def;
  }

  String _pickS(dynamic d, List<dynamic Function()> getters, {String def = ''}) {
    for (final g in getters) {
      final v = _safe(g);
      if (v != null) return v.toString();
    }
    return def;
  }

  // ---------- mapeamento tolerante ----------

  wm.Weather _toModel(ws.Weather src) {
    final d = src as dynamic;

    final temp        = _pickD(d, [() => d.temp, () => d.tempC, () => d.temperature], def: 0);
    final tempMin     = _pickD(d, [() => d.tempMin, () => d.temp_min, () => d.minTemp], def: temp);
    final tempMax     = _pickD(d, [() => d.tempMax, () => d.temp_max, () => d.maxTemp], def: temp);
    final feelsLike   = _pickD(d, [() => d.feelsLike, () => d.feels_like], def: temp);
    final pressure    = _pickI(d, [() => d.pressure, () => d.pressure_hpa], def: 0);
    final humidity    = _pickI(d, [() => d.humidity, () => d.rh], def: 0);
    final windSpeed   = _pickD(d, [() => d.windSpeed, () => d.wind_ms, () => d.wind], def: 0);
    final rain1h      = _pickD(d, [() => d.rain1h, () => d.rain, () => d.rain_mm], def: 0);
    final description = _pickS(d, [() => d.description, () => d.condition, () => d.weatherDesc], def: '');
    // aceita código (“10d”) ou URL completa
    final icon        = _pickS(d, [() => d.icon, () => d.iconCode, () => d.iconUrl], def: '');

    return wm.Weather(
      temp: temp,
      tempMin: tempMin,
      tempMax: tempMax,
      feelsLike: feelsLike,
      pressure: pressure,
      humidity: humidity,
      windSpeed: windSpeed,
      rain1h: rain1h,
      description: description,
      icon: icon,
    );
  }

  /// Extrai nome da cidade direto do DTO (sem depender do model ter `city`).
  String _extractCityName(ws.Weather src) {
    final d = src as dynamic;
    return _pickS(d, [() => d.city, () => d.name, () => d.cityName, () => d.location], def: '');
  }

  // ---------- ações ----------

  Future<void> fetchByCity(String city) async {
    isLoading.value = true;
    error.value = null;
    try {
      final ws.Weather dto = await _service.getByCity(city);
      final wm.Weather model = _toModel(dto);
      weather.value = model;

      if (Get.isRegistered<HomeViewModel>()) {
        Get.find<HomeViewModel>().applyWeather(model);
      }
    } catch (e) {
      error.value = 'Falha ao buscar clima por cidade: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchByCurrentLocation() async {
    isLoading.value = true;
    error.value = null;
    try {
      final loc = Get.find<LocationController>();
      await loc.fetchLocation(highAccuracy: false);
      if (loc.error.value != null) {
        error.value = loc.error.value;
        return;
      }

      final pos = loc.position.value!;
      final ws.Weather dto =
      await _service.getCurrentByLatLon(pos.latitude, pos.longitude);

      final wm.Weather model = _toModel(dto);
      weather.value = model;

      final String cityName = _extractCityName(dto);

      if (Get.isRegistered<HomeViewModel>()) {
        final home = Get.find<HomeViewModel>();
        home.setGpsCityAndCoord(cityName, pos.latitude, pos.longitude);
        home.applyWeather(model);
      }
    } catch (e) {
      // Aqui pegamos inclusive NoSuchMethodError e mostramos no UI
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
