import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:atmus/ui/splash/splash_page.dart';

part 'routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: Routes.splash, page: () => const SplashPage()),
    GetPage(name: Routes.home, page: () => const _HomePlaceholder()),
    // adicione suas outras páginas aqui
  ];
}

// Apenas um placeholder pra navegação funcionar
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Conteúdo da Home')),
    );
  }
}
