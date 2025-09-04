import 'package:get/get.dart';
import '../../data/weather_service.dart';
import '../../core/location_service.dart';

// >>> para empurrar dados ao seu HomeViewModel
import 'package:atmus/viewmodels/home/home_viewmodel.dart';

import '../../presentation/controllers/location_controller.dart';

class WeatherController extends GetxController {
  final WeatherService _service;
  WeatherController(this._service);

  final isLoading = false.obs;
  final error = RxnString();
  final weather = Rxn<Weather>(); // estado interno (opcional para debug/others)

  Future<void> fetchByCity(String city) async {
    isLoading.value = true;
    error.value = null;
    try {
      final w = await _service.getByCity(city);
      weather.value = w;

      // >>> Atualiza o HomeViewModel (se estiver registrado)
      if (Get.isRegistered<HomeViewModel>()) {
        Get.find<HomeViewModel>().applyWeather(w);
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
      // 1) Obter posição
      final loc = Get.find<LocationController>();
      await loc.fetchLocation(highAccuracy: false);
      if (loc.error.value != null) {
        error.value = loc.error.value;
        return;
      }
      final pos = loc.position.value!;

      // 2) Chamar OpenWeather
      final w = await _service.getCurrentByLatLon(pos.latitude, pos.longitude);
      weather.value = w;

      // 3) Empurrar para HomeViewModel
      if (Get.isRegistered<HomeViewModel>()) {
        Get.find<HomeViewModel>().applyWeather(w);
      }
    } catch (e) {
      error.value = 'Falha ao buscar clima por localização atual: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
