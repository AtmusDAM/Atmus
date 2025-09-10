import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/data/services/openweather_service.dart';

class WeatherController extends GetxController {
  final error = RxnString();

  final _home = Get.find<HomeViewModel>();
  final _ow = OpenWeatherService();

  /// Usado pelo botão "Usar minha localização"
  Future<void> fetchByCurrentLocation() async {
    error.value = null;
    try {
      final ok = await _ensureLocationPermission();
      if (!ok) {
        error.value = 'Permissão de localização negada ou serviço desativado.';
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String cityName = 'Minha localização';
      try {
        final rev = await _ow.reverseGeocode(pos.latitude, pos.longitude);
        if (rev.isNotEmpty) {
          final first = rev.first;
          final n = (first['name'] ?? '') as String;
          final st = (first['state'] ?? '') as String? ?? '';
          final co = (first['country'] ?? '') as String? ?? '';
          final parts = <String>[];
          if (n.isNotEmpty) parts.add(n);
          if (st.isNotEmpty) parts.add(st);
          if (co.isNotEmpty) parts.add(co);
          if (parts.isNotEmpty) cityName = parts.join(', ');
        }
      } catch (_) {}

      await _home.applyGpsPosition(
        lat: pos.latitude,
        lon: pos.longitude,
        resolvedCityName: cityName,
      );
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> fetchByCoordinates(double lat, double lon) async {
    error.value = null;
    try {
      await _home.applyGpsPosition(lat: lat, lon: lon);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> fetchByCityName(String city) async {
    error.value = null;
    try {
      await _home.fetchByCityName(city);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) return false;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return false;
      }
    }
    return true;
  }
}
