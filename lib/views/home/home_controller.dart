import 'package:atmus/services/api_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  var temperaturaAtual = 0.0.obs;
  var temperaturaMin = 0.0.obs;
  var temperaturaMax = 0.0.obs;
  var sensacaoSol   = 0.0.obs;
  var sensacaoChuva = 0.0.obs;
  var descricaoTempo = 'Carregando...'.obs;

  @override
  void onInit() {
    super.onInit();
    getWeather();
  }

  Future<void> getWeather() async {
    final api = ApiService();
    final data = await api.fetchCurrentWeather('Recife,BR');

    if (data == null) {
      print('Falha ao carregar dados do tempo.');
      return;
    }

    final main = (data['main'] ?? {}) as Map;
    temperaturaAtual.value = (main['temp'] as num?)?.toDouble() ?? 0.0;
    temperaturaMin.value   = (main['temp_min'] as num?)?.toDouble() ?? 0.0;
    temperaturaMax.value   = (main['temp_max'] as num?)?.toDouble() ?? 0.0;
    sensacaoSol.value      = (main['feels_like'] as num?)?.toDouble() ?? 0.0;

    final rain = (data['rain'] ?? {}) as Map;
    sensacaoChuva.value    = (rain['1h'] as num?)?.toDouble() ?? 0.0;

    final weatherList = (data['weather'] as List?) ?? const [];
    descricaoTempo.value =
        (weatherList.isNotEmpty ? weatherList.first['description'] : null) ?? 'Sem dados';

    print('Temperatura atual: ${temperaturaAtual.value}°C');
  }
}
