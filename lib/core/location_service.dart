import 'package:geolocator/geolocator.dart';


class LocationFailure implements Exception {
  final String message;
  LocationFailure(this.message);
  @override
  String toString() => message;
}


class LocationService {
  Future<void> _ensureReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationFailure(
        'Serviço de localização desativado. Ative o GPS (Localização) e tente novamente.',
      );
    }


    LocationPermission permission = await Geolocator.checkPermission();


    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }


    if (permission == LocationPermission.denied) {
      throw LocationFailure('Permissão de localização negada. Conceda a permissão para continuar.');
    }


    if (permission == LocationPermission.deniedForever) {
      throw LocationFailure(
        'Permissão negada permanentemente. Vá às configurações do app e habilite a localização.',
      );
    }
  }


  /// Obtém a última posição conhecida (rápida) ou a posição atual (precisa).
  Future<Position> getCurrentPosition({bool highAccuracy = false}) async {
    await _ensureReady();


    final last = await Geolocator.getLastKnownPosition();
    if (last != null && !highAccuracy) {
      return last;
    }


    return Geolocator.getCurrentPosition(
      desiredAccuracy: highAccuracy ? LocationAccuracy.best : LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );
  }


  /// Abrir configurações do app/localização quando necessário
  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
    await Geolocator.openLocationSettings();
  }
}