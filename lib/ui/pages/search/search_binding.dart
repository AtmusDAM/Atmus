import 'package:get/get.dart';
import 'package:atmus/data/services/api_service.dart';

import 'city_search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiService());
    Get.lazyPut(() => CitySearchController(apiService: Get.find()));
  }
}
