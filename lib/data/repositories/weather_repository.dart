import '../models/forecast_model.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';

class WeatherRepository {
  final ApiService _apiService;

  WeatherRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<Weather?> getCurrentWeather(String city) async {
    final data = await _apiService.fetchCurrentWeather(city);
    if (data != null) {
      return Weather.fromJson(data);
    }
    return null;
  }

  Future<Forecast?> getWeatherForecast(String city) async {
    final data = await _apiService.fetchWeatherForecast(city);
    if (data != null) {
      return Forecast.fromJson(data);
    }
    return null;
  }
}
