import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:atmus/ui/pages/home/home_page.dart';

// ViewModels
import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/viewmodels/dados/dados_viewmodel.dart';
// (Se quiser registrar a Previsão globalmente também, importe:)
// import 'package:atmus/viewmodels/previsao/previsao_viewmodel.dart';

// Core/Controllers/Services
import 'package:atmus/secrets.dart';
import 'package:atmus/core/location_service.dart';
import 'package:atmus/presentation/controllers/location_controller.dart';
import 'package:atmus/presentation/controllers/weather_controller.dart';
import 'package:atmus/data/weather_service.dart';

void main() {
  initializeDateFormatting('pt_BR', null).then((_) {
    // Ordem importa por causa das dependências:

    // 1) Locais (usado por Home/Dados/Previsão)
    Get.put<LocaisViewModel>(LocaisViewModel());

    // 2) Home (depende de Locais)
    Get.put<HomeViewModel>(HomeViewModel());

    // 3) Infra de localização/clima
    Get.put<LocationController>(LocationController(LocationService()));
    Get.put<WeatherService>(WeatherService(apiKey: Secrets.weatherApiKey));
    Get.put<WeatherController>(WeatherController(Get.find<WeatherService>()));

    // 4) Dados+ (depende de Locais e Home)
    Get.put<DadosViewModel>(DadosViewModel(), permanent: true);

    // (Opcional) Registrar Previsão globalmente também:
    // Get.put<PrevisaoViewModel>(PrevisaoViewModel(), permanent: true);

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Atmus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
