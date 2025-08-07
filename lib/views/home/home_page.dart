import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),

      // menu inferior
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
          onTap: (index) => controller.selectedIndex.value = index,
          iconSize: 30,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
          ],
        )),
      ),

      // corpo principal
      body: Obx(() => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: cidade, temperatura, descrição, nav e config
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.settings, color: Colors.white),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.location_on, color: Colors.white),
                            SizedBox(width: 4),
                            Text("Recife, PE", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("${controller.temperaturaAtual.value.toStringAsFixed(0)} ºC",
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(controller.descricaoTempo.value,
                            style: TextStyle(color: Colors.grey[300])),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      // TODO: abrir drawer ou menu lateral
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Cartão: Agora
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade800,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // PARTE DE CIMA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Agora", style: TextStyle(color: Colors.white)),
                            SizedBox(height: 4),
                            Text("Atualizado há 5min",
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const Icon(Icons.cloud, color: Colors.white, size: 48),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // PARTE DE BAIXO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Máxima",
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("${controller.temperaturaMax.value} ºC",
                                style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Mínima",
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("${controller.temperaturaMin.value} ºC",
                                style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // sensação e precipitação
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B263B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade800,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.wb_sunny, color: Colors.white),
                          const SizedBox(height: 8),
                          Text("Sensação",
                              style:
                              TextStyle(color: Colors.grey[400], fontSize: 12)),
                          Text("${controller.sensacaoSol.value} ºC",
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B263B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade800,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.water_drop, color: Colors.white),
                          const SizedBox(height: 8),
                          Text("Precipitação",
                              style:
                              TextStyle(color: Colors.grey[400], fontSize: 12)),
                          Text("${controller.sensacaoChuva.value} ºC",
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Mapa
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/mapa_exemplo.png',
                  fit: BoxFit.cover,
                  height: 150,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
