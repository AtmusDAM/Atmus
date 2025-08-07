import 'package:get/get.dart';

class HomeController extends GetxController {
  var temperaturaAtual = 25.0.obs;
  var temperaturaMin = 18.0.obs;
  var temperaturaMax = 28.0.obs;
  var sensacaoSol = 27.0.obs;
  var sensacaoChuva = 27.0.obs;
  var descricaoTempo = "Parcialmente nublado".obs;

  var selectedIndex = 0.obs;
}
