import 'package:get/get.dart';
import 'package:atmus/data/models/city_model.dart';
import 'package:atmus/data/services/api_service.dart';

class LocaisViewModel extends GetxController {
  final RxList<CityModel> _cities = <CityModel>[
    // name, min, max, lat, lon
    CityModel(name: 'Garanhuns',   minTemp: 17, maxTemp: 27, lat:  -8.8829, lon: -36.4960),
    CityModel(name: 'Recife',      minTemp: 23, maxTemp: 30, lat: -8.0476, lon: -34.8770),
    CityModel(name: 'Salvador',    minTemp: 24, maxTemp: 31, lat: -12.9777, lon: -38.5016),
    CityModel(name: 'Fortaleza',   minTemp: 24, maxTemp: 30, lat:  -3.7319, lon: -38.5267),
  ].obs;  // Exposta para a UI (lista filtrada)
  final RxList<CityModel> filteredCities = <CityModel>[].obs;

  // Cidade selecionada atualmente (drawer / gps pode sobrescrever via Home)
  final Rxn<CityModel> selectedCity = Rxn<CityModel>();

  @override
  void onInit() {
    super.onInit();
    // Inicial: lista completa
    filteredCities.assignAll(_cities);
    if(_cities.isNotEmpty) {
      selectedCity.value = _cities.first;
    }
  }

  void addCity(CityModel city){
    if (!_cities.any((c) => c.name == city.name && c.country == city.country)){
      _cities.add(city);
      filteredCities(); //Atualiza a lista de cidades filtradas
    }
  }


  void filterCities(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filteredCities.assignAll(_cities);
    } else {
      filteredCities.assignAll(
        _cities.where((c) => c.name.toLowerCase().contains(q)),
      );
    }
  }

  void selectCity(CityModel city) {
    selectedCity.value = city;
  }

  void toggleFavorite(CityModel city) {
    final index = _cities.indexWhere((c) => c.name == city.name);
    if (index != -1) {
      final updatedCity = city.copyWith(isFavorite: !city.isFavorite);
      _cities[index] = updatedCity;
      // Also update the filtered list if the city is present there
      final filteredIndex = filteredCities.indexWhere((c) => c.name == city.name);
      if (filteredIndex != -1) {
        filteredCities[filteredIndex] = updatedCity;
      }
    }
  }

  List<CityModel> get cities => _cities;
  List<CityModel> get favoriteCities => _cities.where((c) => c.isFavorite).toList();
}
