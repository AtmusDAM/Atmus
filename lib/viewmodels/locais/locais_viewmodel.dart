import 'package:get/get.dart';
import 'package:atmus/data/models/city_model.dart';

class LocaisViewModel extends GetxController {
  var allCities = <CityModel>[
    CityModel(name: "Recife", minTemp: 18, maxTemp: 23),
    CityModel(name: "Salvador", minTemp: 23, maxTemp: 26),
    CityModel(name: "Fortaleza", minTemp: 23, maxTemp: 20),
    CityModel(name: "Crato", minTemp: 23, maxTemp: 26),
    CityModel(name: "Garanhuns", minTemp: 23, maxTemp: 26),
    CityModel(name: "Carpina", minTemp: 23, maxTemp: 26),
  ].obs;

  var filteredCities = <CityModel>[].obs;

  var selectedCity = Rxn<CityModel>();

  @override
  void onInit() {
    super.onInit();
    filteredCities.assignAll(allCities);
  }

  void filterCities(String query) {
    if (query.isEmpty) {
      filteredCities.assignAll(allCities);
    } else {
      filteredCities.assignAll(
        allCities.where((city) =>
            city.name.toLowerCase().contains(query.toLowerCase())),
      );
    }
  }

  void selectCity(CityModel city) {
    selectedCity.value = city;
  }
}
