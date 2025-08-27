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
    // Simulações de inicialização (prefs, auth, DI, APIs, etc.)
    await Future.delayed(const Duration(milliseconds: 900));
    // TODO: inicializações reais aqui (ex.: await AuthService.checkSession())

    isReady.value = true;

    // Decisão de rota (exemplo simples)
    // final logged = await AuthService.isLogged();
    // Get.offAllNamed(logged ? Routes.home : Routes.login);
    Get.offAllNamed(Routes.home);
  }
}
