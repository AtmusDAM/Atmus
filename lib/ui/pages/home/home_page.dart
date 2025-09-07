import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:atmus/ui/pages/mapa/mapa_page.dart';
import 'package:atmus/ui/pages/previsao/previsao_page.dart';
import 'package:atmus/ui/pages/locais/locais_page.dart';
import 'package:atmus/ui/pages/home/home_page_content.dart';
import 'package:atmus/ui/pages/dados/dados_page.dart';

import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/viewmodels/configuracao/configuracao_viewmodel.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeViewModel controller = Get.find<HomeViewModel>();
  final ThemeController themeController = Get.find<ThemeController>();

  // NÃO use "const [ ... ]" aqui. Marque const só nos que permitem.
  final List<Widget> pages = [
    HomePageContent(),
    const PrevisaoPage(),
    DadosPage(),
    const MapaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark;

      final bgColor = isDark ? const Color(0xFF0D1B2A) : Colors.white;
      final bottomBarColor = isDark ? const Color(0xFF1B263B) : Colors.grey[200]!;
      final drawerColor = isDark ? const Color(0xFF0D1B2A) : Colors.white;

      return Scaffold(
        backgroundColor: bgColor,
        drawer: Drawer(
          child: Container(
            color: drawerColor,
            child: LocaisPage(),
          ),
        ),

        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bottomBarColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: isDark ? Colors.white : Colors.black,
            unselectedItemColor: isDark ? Colors.grey : Colors.grey[700],
            type: BottomNavigationBarType.fixed,
            currentIndex: controller.selectedIndex.value,
            onTap: (index) => controller.selectedIndex.value = index,
            iconSize: 30,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
            ],
          ),
        ),

        body: pages[controller.selectedIndex.value],
      );
    });
  }
}
