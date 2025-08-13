import 'package:get/get.dart';
import 'package:atmus/services/api_service.dart';

class DadosController extends GetxController {
  final ApiService apiService = ApiService();

  // Índice da navegação inferior
  var selectedIndex = 0.obs;

  // Dados principais
  var pressao = 0.0.obs;
  var umidade = 0.obs;
  var vento = 0.obs;
  var indiceUV = "".obs;

  // Precipitação
  var precipitacaoManha = 0.obs;
  var precipitacaoTarde = 0.obs;
  var precipitacaoNoite = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final data = await apiService.fetchCurrentWeather("Recife,BR");

    if (data != null) {
      pressao.value = (data['main']['pressure'] ?? 0).toDouble();
      umidade.value = data['main']['humidity'] ?? 0;
      vento.value = ((data['wind']['speed'] ?? 0) as num).round();

      indiceUV.value = "N/D";

      precipitacaoManha.value = 0;
      precipitacaoTarde.value = 0;
      precipitacaoNoite.value = 0;
    } else {
      print("[DadosController] Falha ao carregar dados do tempo.");
    }
  }
}
