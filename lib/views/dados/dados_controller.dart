import 'package:get/get.dart';

class DadosController extends GetxController {
  // Índice da navegação inferior
  var selectedIndex = 0.obs;

  // Dados principais
  var pressao = 1018.0.obs;
  var umidade = 76.obs;
  var vento = 16.obs;
  var indiceUV = "Alto".obs;

  // Precipitação
  var precipitacaoManha = 61.obs;
  var precipitacaoTarde = 41.obs;
  var precipitacaoNoite = 70.obs;
}
