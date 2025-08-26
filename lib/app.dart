import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atmus/ui/routes/app_pages.dart';
import 'package:atmus/ui/theme/app_colors.dart';

class AtmusApp extends StatelessWidget {
  const AtmusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Atmus',
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: null, // defina caso use fonte custom
      ),
    );
  }
}
