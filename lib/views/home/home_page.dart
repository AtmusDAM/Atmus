import 'package:atmus/views/previsao/previsao_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'home_page_content.dart';
import '../dados/dados_page.dart';
// import '../mapa/mapa_page.dart'; // quando existir

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final controller = Get.put(HomeController());

  final List<Widget> pages = [
    HomePageContent(),
    PrevisaoPage(),
    DadosPage(),
    // MapaPage(), // comente até criar
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Obx(() => BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          onTap: (index) {
            controller.selectedIndex.value = index;
          },
          iconSize: 30,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
          ],
        )),
      ),

      body: Obx(() => pages[controller.selectedIndex.value]),
    );
  }
}
