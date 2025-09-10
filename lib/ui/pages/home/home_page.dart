import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:atmus/ui/pages/mapa/mapa_page.dart';
import 'package:atmus/ui/pages/previsao/previsao_page.dart';
import 'package:atmus/ui/pages/locais/locais_page.dart';
import 'package:atmus/ui/pages/home/home_page_content.dart';
import 'package:atmus/ui/pages/dados/dados_page.dart';
import 'package:atmus/viewmodels/historico/historico_page.dart';

import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/viewmodels/configuracao/configuracao_viewmodel.dart';
import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';

import 'package:atmus/data/models/city_model.dart';
// ajuste este import se seu serviço estiver em outro lugar
import '../../../services/gps_location_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeViewModel controller = Get.find<HomeViewModel>();
  final ThemeController themeController = Get.find<ThemeController>();

  LocaisViewModel _ensureLocaisVM() {
    if (Get.isRegistered<LocaisViewModel>()) return Get.find<LocaisViewModel>();
    return Get.put<LocaisViewModel>(LocaisViewModel(), permanent: true);
  }

  final List<Widget> pages = [
    HomePageContent(),
    const PrevisaoPage(),
    DadosPage(),
    const MapaPage(),
  ];

  ({double lat, double lon})? _tryHvCoords() {
    final dynamic hv = controller;
    try {
      final candidates = [
        hv.coords,
        hv.position,
        hv.currentPosition,
        hv.gps,
        hv.gpsPosition,
        hv.location,
        hv.currentLocation,
      ];
      for (final c in candidates) {
        if (c == null) continue;
        try {
          final double? lat =
              (c.lat as num?)?.toDouble() ?? (c.latitude as num?)?.toDouble();
          final double? lon = (c.lon as num?)?.toDouble() ??
              (c.lng as num?)?.toDouble() ??
              (c.longitude as num?)?.toDouble();
          if (lat != null && lon != null) return (lat: lat, lon: lon);
        } catch (_) {}
      }
    } catch (_) {}
    return null;
  }

  Future<void> _openHistoricoSelected(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) async {
    final locaisVM = _ensureLocaisVM();
    final sel = locaisVM.selectedLatLon;
    if (sel != null) {
      final CityModel? c = locaisVM.currentCity;
      final titulo =
      (c?.name?.isNotEmpty ?? false) ? c!.name! : 'Local selecionado';
      Get.to(() => HistoricoPage(
        lat: sel.lat,
        lon: sel.lon,
        titulo: 'Histórico - $titulo',
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Nenhum local selecionado. Escolha um na gaveta.')));
    scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _openHistoricoGps(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) async {
    // 1) Se o HomeViewModel já tem coords ativas (GPS obtido), usa direto
    final hvPair = _tryHvCoords();
    if (hvPair != null) {
      Get.to(() => HistoricoPage(
        lat: hvPair.lat,
        lon: hvPair.lon,
        titulo: 'Histórico - Minha localização',
      ));
      return;
    }

    // 2) Tenta capturar o GPS agora
    try {
      final pos = await GpsLocationService().getCurrentPosition();
      // Importante: não alteramos selectedCity aqui — só abrimos o histórico por GPS.
      Get.to(() => HistoricoPage(
        lat: pos.latitude,
        lon: pos.longitude,
        titulo: 'Histórico - Minha localização',
      ));
      return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GPS indisponível: $e')),
      );
    }
  }

  void _showHistoricoChooser(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('Histórico - Local selecionado'),
              subtitle:
              const Text('Usa a cidade escolhida na gaveta/favoritos'),
              onTap: () {
                Navigator.of(ctx).pop();
                _openHistoricoSelected(context, scaffoldKey);
              },
            ),
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Histórico - Minha localização (GPS)'),
              subtitle: const Text('Usa o ponto do GPS agora'),
              onTap: () {
                Navigator.of(ctx).pop();
                _openHistoricoGps(context, scaffoldKey);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark;

      final bgColor = isDark ? const Color(0xFF0D1B2A) : Colors.white;
      final bottomBarColor =
      isDark ? const Color(0xFF1B263B) : Colors.grey[200]!;
      final drawerColor = isDark ? const Color(0xFF0D1B2A) : Colors.white;

      return Scaffold(
        key: scaffoldKey,
        backgroundColor: bgColor,
        drawer: Drawer(
          child: Container(color: drawerColor, child: LocaisPage()),
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
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
            ],
          ),
        ),
        body: pages[controller.selectedIndex.value],
        floatingActionButton: controller.selectedIndex.value == 2
            ? FloatingActionButton.extended(
          heroTag: 'fab_historico_5dias',
          onPressed: () => _showHistoricoChooser(context, scaffoldKey),
          icon: const Icon(Icons.history),
          label: const Text('Histórico (5 dias)'),
          tooltip: 'Escolha entre Local selecionado ou GPS',
        )
            : null,
      );
    });
  }
}
