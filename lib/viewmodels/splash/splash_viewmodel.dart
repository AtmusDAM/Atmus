import 'dart:async';
import 'package:get/get.dart';
import '/ui/routes/app_pages.dart';

class SplashViewModel extends GetxController {
  final isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 900));

    isReady.value = true;

    Get.offAllNamed(Routes.home);
  }
}
