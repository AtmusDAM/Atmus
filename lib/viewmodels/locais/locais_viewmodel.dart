import 'package:get/get.dart';
import '../../../data/models/city_model.dart';

class LocaisViewModel extends GetxController {
  var currentCity = City(name: "Recife\nPernambuco", temperature: "22°").obs;

  var favoriteCities = <City>[
    City(name: "Recife", temperature: "19° 22°"),
    City(name: "Salvador", temperature: "28° 23°"),
    City(name: "Fortaleza", temperature: "20° 23°"),
    City(name: "Crato", temperature: "28° 23°"),
    City(name: "Garanhuns", temperature: "28° 23°"),
    City(name: "Carpina", temperature: "28° 23°"),
  ].obs;

  void addFavorite(City city) {
    if (!favoriteCities.contains(city)) {
      favoriteCities.add(city);
    }
  }

  void removeFavorite(City city) {
    favoriteCities.remove(city);
  }
}
