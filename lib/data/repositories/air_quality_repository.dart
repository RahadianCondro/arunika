// lib/data/repositories/air_quality_repository.dart
import 'dart:math';
import '../models/air_quality.dart';

class AirQualityRepository {
  final Random _random = Random();

  Future<AirQuality> getCurrentAirQuality() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Create pollutant data
    final Map<String, Pollutant> pollutants = {
      'PM2_5': Pollutant(
        code: 'PM2_5',
        name: 'Particulate Matter < 2.5μm',
        value: 15.0 + _random.nextDouble() * 10.0,
        unit: 'μg/m³',
        category: 'Sedang',
        color: '#FFA500',
        percentage: 0.42,
      ),
      'PM10': Pollutant(
        code: 'PM10',
        name: 'Particulate Matter < 10μm',
        value: 30.0 + _random.nextDouble() * 15.0,
        unit: 'μg/m³',
        category: 'Sedang',
        color: '#FFA500',
        percentage: 0.35,
      ),
      'O3': Pollutant(
        code: 'O3',
        name: 'Ozone',
        value: 40.0 + _random.nextDouble() * 20.0,
        unit: 'ppb',
        category: 'Baik',
        color: '#00FF00',
        percentage: 0.25,
      ),
      'NO2': Pollutant(
        code: 'NO2',
        name: 'Nitrogen Dioxide',
        value: 20.0 + _random.nextDouble() * 10.0,
        unit: 'ppb',
        category: 'Baik',
        color: '#00FF00',
        percentage: 0.18,
      ),
    };
    
    // Create weather data
    final Weather weather = Weather(
      temperature: 28.0 + _random.nextDouble() * 4.0,
      humidity: 65 + _random.nextInt(15),
      windSpeed: 2.0 + _random.nextDouble() * 3.0,
      windDirection: 'SE',
      conditions: 'Partly Cloudy',
    );
    
    // Create hourly forecast
    final List<HourlyForecast> forecast = [];
    final int baseAqi = 65 + _random.nextInt(10);
    final List<String> trends = ['improving', 'stable', 'worsening'];
    
    for (int i = 0; i < 6; i++) {
      final now = DateTime.now();
      final hour = now.add(Duration(hours: i + 1));
      final String formattedHour = '${hour.hour.toString().padLeft(2, '0')}:00';
      
      forecast.add(
        HourlyForecast(
          hour: formattedHour,
          aqi: baseAqi + (_random.nextInt(20) - 10),
          primaryPollutant: 'PM2_5',
          trend: trends[_random.nextInt(trends.length)],
        ),
      );
    }
    
    // Return constructed AirQuality object
    return AirQuality(
      aqi: baseAqi,
      category: _getAqiCategory(baseAqi),
      pollutants: pollutants,
      weather: weather,
      hourlyForecast: forecast,
    );
  }
  
  // Helper to get category based on AQI
  String _getAqiCategory(int aqi) {
    if (aqi <= 50) {
      return 'Baik';
    } else if (aqi <= 100) {
      return 'Sedang';
    } else if (aqi <= 150) {
      return 'Tidak Sehat untuk Kelompok Sensitif';
    } else if (aqi <= 200) {
      return 'Tidak Sehat';
    } else if (aqi <= 300) {
      return 'Sangat Tidak Sehat';
    } else {
      return 'Berbahaya';
    }
  }
  
  // Get air quality forecast for specific locations
  Future<Map<String, AirQuality>> getAirQualityForLocations(List<dynamic> locations) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final Map<String, AirQuality> results = {};
    
    // Generate air quality data for each location
    for (final location in locations) {
      final String locationName = location['name'] as String;
      
      // Use the location's coordinates to seed the random generator
      // for consistent but varied results
      final double lat = location['lat'] as double;
      final double lon = location['lon'] as double;
      final int seed = ((lat * 100).round() + (lon * 100).round()) % 100000;
      final Random locationRandom = Random(seed);
      
      final int locationAqi = 40 + locationRandom.nextInt(60);
      
      // Create consistent but varied air quality data for this location
      results[locationName] = AirQuality(
        aqi: locationAqi,
        category: _getAqiCategory(locationAqi),
        pollutants: {
          'PM2_5': Pollutant(
            code: 'PM2_5',
            name: 'Particulate Matter < 2.5μm',
            value: 10.0 + locationRandom.nextDouble() * 20.0,
            unit: 'μg/m³',
            category: 'Sedang',
            color: '#FFA500',
            percentage: 0.3 + locationRandom.nextDouble() * 0.3,
          ),
          'PM10': Pollutant(
            code: 'PM10',
            name: 'Particulate Matter < 10μm',
            value: 20.0 + locationRandom.nextDouble() * 30.0,
            unit: 'μg/m³',
            category: 'Sedang',
            color: '#FFA500',
            percentage: 0.2 + locationRandom.nextDouble() * 0.4,
          ),
        },
        weather: Weather(
          temperature: 27.0 + locationRandom.nextDouble() * 5.0,
          humidity: 60 + locationRandom.nextInt(20),
          windSpeed: 1.5 + locationRandom.nextDouble() * 4.0,
          windDirection: 'SE',
          conditions: 'Sunny',
        ),
        hourlyForecast: [],  // No hourly forecast for location-specific data
      );
    }
    
    return results;
  }
}