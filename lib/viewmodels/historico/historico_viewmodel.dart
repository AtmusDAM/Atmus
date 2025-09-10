// lib/viewmodels/historico/historico_viewmodel.dart
import 'package:get/get.dart';

import '../../data/models/openweather_history.dart';
import '../../data/services/openweather_service.dart';
import '../../secrets_openweather.dart';

class HistoricoViewModel extends GetxController {
  final _service = OpenWeatherService(preferOneCall3: openWeatherPreferV3);

  final isLoading = false.obs;
  final error = RxnString();
  final histories = <OwDayHistory>[].obs;

  Future<void> loadPast5Days({required double lat, required double lon}) async {
    isLoading.value = true;
    error.value = null;
    try {
      final data = await _service.getPast5DaysHistory(lat: lat, lon: lon);
      histories.assignAll(data);
    } on OpenWeatherAuthError catch (e) {
      error.value =
      'Sua chave não tem acesso ao One Call necessário para histórico.\n'
          '${e.message}\n\nOpções:\n'
          '• Ative "One Call by Call" no painel da OpenWeather para esta API key;\n'
          '• Ou defina openWeatherPreferV3=false em secrets_openweather.dart para tentar o endpoint 2.5 (se sua conta permitir).';
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
