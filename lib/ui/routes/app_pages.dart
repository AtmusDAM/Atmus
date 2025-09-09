import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:atmus/ui/splash/splash_page.dart';
import 'package:atmus/ui/pages/search/search_binding.dart';
import 'package:atmus/ui/pages/search/search_page.dart';

part 'routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: Routes.splash, page: () => const SplashPage()),
    GetPage(name: Routes.home, page: () => const _HomePlaceholder()),
    GetPage(
      name: Routes.search,
      page: () => const SearchPage(),
      binding: SearchBinding(),
    )
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
