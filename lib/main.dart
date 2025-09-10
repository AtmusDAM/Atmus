import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:atmus/ui/theme/app_colors.dart';
import 'package:atmus/ui/pages/home/home_page.dart';

// ViewModels
import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/viewmodels/dados/dados_viewmodel.dart';
// import 'package:atmus/viewmodels/previsao/previsao_viewmodel.dart';

// Core/Controllers/Services
import 'package:atmus/viewmodels/configuracao/configuracao_viewmodel.dart';
import 'package:atmus/presentation/controllers/location_controller.dart';
import 'package:atmus/presentation/controllers/weather_controller.dart';
import 'package:atmus/data/weather_service.dart';
import 'package:atmus/core/location_service.dart';
import 'package:atmus/secrets.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting('pt_BR', null).then((_) {
    Get.put<LocaisViewModel>(LocaisViewModel());
    Get.put<HomeViewModel>(HomeViewModel());
    Get.put<LocationController>(LocationController(LocationService()));
    Get.put<WeatherService>(WeatherService(apiKey: Secrets.weatherApiKey));
    Get.put<WeatherController>(WeatherController());
    Get.put<DadosViewModel>(DadosViewModel(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    return Obx(
          () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Atmus',
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: themeController.themeMode.value,
        home: HomePage(),
      ),
    );
  }
}
