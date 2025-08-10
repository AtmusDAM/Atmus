import 'package:get/get.dart';

class PrevisaoController extends GetxController {
  var temperaturas = <String, List<int>>{
    "Ontem": [19, 23],
    "Hoje": [28, 23],
    "Segunda": [20, 23],
    "Terça-feira": [28, 23],
    "Quarta-feira": [28, 23],
    "Sábado": [28, 23],
  }.obs;

  var temperaturasHora = <String, int>{
    "11:00h": 25,
    "12:00h": 25,
    "13:00h": 25,
    "14:00h": 25,
    "15:00h": 25,
    "16:00h": 25,
    "17:00h": 25,
    "18:00h": 25,
    "19:00h": 25,
    "20:00h": 25,
  }.obs;

  var resumo = "Pancadas de chuva à tarde. Máxima de 26 a 28 C".obs;
}
