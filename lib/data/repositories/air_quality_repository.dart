import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/air_quality.dart';

class ApiService {
  final String baseUrl = 'http://api.airvisual.com/v2';
  final String apiKey = '58c8d12d-5f33-43d6-80a0-a6ac89a8d2ec';

  Future<Map<String, dynamic>> getCityAirQuality({
    required String city,
    required String state,
    required String country,
  }) async {
    final uri = Uri.parse('$baseUrl/city?city=$city&state=$state&country=$country&key=$apiKey');
    try {
      final response = await http.get(uri).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal mengambil data kualitas udara: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil data kualitas udara: $e');
    }
  }
}

class AirQualityRepository {
  final ApiService _apiService = ApiService();

  Future<AirQuality> getCurrentAirQuality({
    String city = 'Yogyakarta',
    String state = 'Yogyakarta',
    String country = 'Indonesia',
  }) async {
    try {
      final json = await _apiService.getCityAirQuality(
        city: city,
        state: state,
        country: country,
      );
      
      if (json['status'] != 'success' || json['data'] == null) {
        throw Exception('Respons API tidak valid');
      }

      final data = json['data'];
      final pollution = data['current']['pollution'];
      final weather = data['current']['weather'];

      // Memetakan respons API ke model AirQuality
      return AirQuality(
        aqi: pollution['aqius'] ?? 0,
        category: _mapAqiCategory(pollution['aqius'] ?? 0),
        pollutants: {
          'PM2_5': Pollutant(
            code: 'PM2_5',
            name: 'PM 2.5',
            value: pollution['aqius'].toDouble(), // Catatan: API mungkin tidak menyediakan nilai polutan spesifik
            unit: 'µg/m³',
            category: _mapAqiCategory(pollution['aqius'] ?? 0),
            color: _mapAqiColor(pollution['aqius'] ?? 0),
            percentage: _calculatePercentage('PM2_5', pollution['aqius'] ?? 0),
          ),
          // Tambahkan polutan lain jika API menyediakan datanya
        },
        weather: Weather(
          temperature: (weather['tp'] ?? 0).toDouble(),
          humidity: weather['hu'] ?? 0,
          windSpeed: (weather['ws'] ?? 0).toDouble(),
          windDirection: _mapWindDirection(weather['wd'] ?? 0),
          conditions: _mapWeatherCondition(weather['ic'] ?? '01d'),
        ),
        hourlyForecast: [], // Catatan: API mungkin tidak menyediakan prakiraan; sesuaikan jika tersedia
      );
    } catch (e) {
      throw Exception('Gagal memuat data kualitas udara: $e');
    }
  }

  String _mapAqiCategory(int aqi) {
    if (aqi <= 50) return 'Baik';
    if (aqi <= 100) return 'Sedang';
    if (aqi <= 150) return 'Tidak Sehat untuk Kelompok Sensitif';
    if (aqi <= 200) return 'Tidak Sehat';
    if (aqi <= 300) return 'Sangat Tidak Sehat';
    return 'Berbahaya';
  }

  String _mapAqiColor(int aqi) {
    if (aqi <= 50) return '#00E400'; // Hijau
    if (aqi <= 100) return '#FFFF00'; // Kuning
    if (aqi <= 150) return '#FF7E00'; // Oranye
    if (aqi <= 200) return '#FF0000'; // Merah
    if (aqi <= 300) return '#8F3F97'; // Ungu
    return '#7E0023'; // Maroon
  }

  String _mapWindDirection(int degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'U';
    if (degrees < 67.5) return 'TL';
    if (degrees < 112.5) return 'T';
    if (degrees < 157.5) return 'TG';
    if (degrees < 202.5) return 'S';
    if (degrees < 247.5) return 'BD';
    if (degrees < 292.5) return 'B';
    return 'BL';
  }

  String _mapWeatherCondition(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return 'Cerah';
      case '02d':
      case '02n':
        return 'Sedikit Berawan';
      case '03d':
      case '03n':
        return 'Berawan Sebagian';
      case '04d':
      case '04n':
        return 'Berawan';
      default:
        return 'Tidak Diketahui';
    }
  }

  double _calculatePercentage(String pollutantType, dynamic value) {
    double numValue = value is double ? value : (value is int ? value.toDouble() : 0.0);
    switch (pollutantType) {
      case 'PM2_5':
        return (numValue / 35.0).clamp(0.0, 1.0); // 35 µg/m³ dianggap tidak sehat
      case 'PM10':
        return (numValue / 150.0).clamp(0.0, 1.0); // 150 µg/m³ dianggap tidak sehat
      case 'O3':
        return (numValue / 150.0).clamp(0.0, 1.0); // 150 µg/m³ dianggap tidak sehat
      case 'NO2':
        return (numValue / 200.0).clamp(0.0, 1.0); // 200 µg/m³ dianggap tidak sehat
      default:
        return (numValue / 100.0).clamp(0.0, 1.0); // Default
    }
  }
}