import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/location_service.dart';


class LocationController extends GetxController {
  final LocationService _locationService;
  LocationController(this._locationService);


  final isLoading = false.obs;
  final error = RxnString();
  final position = Rxn<Position>();


  Future<void> fetchLocation({bool highAccuracy = false}) async {
    isLoading.value = true;
    error.value = null;
    try {
      final pos = await _locationService.getCurrentPosition(highAccuracy: highAccuracy);
      position.value = pos;
    } on LocationFailure catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Falha ao obter localização: $e';
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> openSettings() async {
    await _locationService.openSettings();
  }
}