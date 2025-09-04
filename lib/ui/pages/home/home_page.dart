import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:atmus/ui/pages/mapa/mapa_page.dart';
import 'package:atmus/ui/pages/previsao/previsao_page.dart';
import 'package:atmus/ui/pages/locais/locais_page.dart';
import 'package:atmus/ui/pages/home/home_page_content.dart';
import 'package:atmus/ui/pages/dados/dados_page.dart';

import 'package:atmus/viewmodels/home/home_viewmodel.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Use a instância já registrada no main.dart
  final HomeViewModel controller = Get.find<HomeViewModel>();

  // NÃO use "const [ ... ]" aqui. Marque const só nos que permitem.
  final List<Widget> pages = [
    HomePageContent(),          // não const
    const PrevisaoPage(),       // const OK
    DadosPage(),                // não const
    const MapaPage(),           // const OK
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),

      drawer: LocaisPage(), // não const

      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Obx(
              () => BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
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
      ),

      body: Obx(() => pages[controller.selectedIndex.value]),
    );
  }
}
