import 'package:atmus/viewmodels/configuracao/configuracao_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atmus/ui/routes/app_pages.dart';
import 'package:atmus/ui/theme/app_colors.dart';

class AtmusApp extends StatelessWidget {
  const AtmusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Atmus',
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeController.themeMode.value,
    ));
  }
}
