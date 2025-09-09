import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/city_model.dart';
import '../../../data/services/api_service.dart';

class CitySearchController extends GetxController {
  final ApiService apiService;

  CitySearchController({required this.apiService});

  final TextEditingController citySearchController = TextEditingController();
  final RxList<CityModel> searchResults = <CityModel>[].obs;
  final RxBool isLoading = false.obs;

  void search(String cityName) async {
    if (cityName.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;
    try {
      final results = await apiService.searchCities(cityName);
      searchResults.assignAll(results);
    } catch (e) {
      print('[Search] Erro na busca: $e');

      Get.snackbar('Erro', 'Falha ao buscar cidades. Verifique sua conexão',
      snackPosition: SnackPosition.BOTTOM,
      );
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCity(CityModel city) {
    Get.back(result: city);
  }
}
