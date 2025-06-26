// lib/data/models/air_quality.dart
class AirQuality {
  final int aqi;
  final String category;
  final Map<String, Pollutant> pollutants;
  final Weather weather;
  final List<HourlyForecast> hourlyForecast;

  AirQuality({
    required this.aqi,
    required this.category,
    required this.pollutants,
    required this.weather,
    required this.hourlyForecast,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    Map<String, Pollutant> pollutantMap = {};
    
    if (json['pollutants'] != null) {
      json['pollutants'].forEach((key, value) {
        pollutantMap[key] = Pollutant.fromJson(value);
      });
    }

    List<HourlyForecast> forecasts = [];
    if (json['forecast'] != null && json['forecast']['next_hours'] != null) {
      forecasts = List<HourlyForecast>.from(
        json['forecast']['next_hours'].map((hour) => HourlyForecast.fromJson(hour))
      );
    }
    
    return AirQuality(
      aqi: json['aqi']['value'] ?? 0,
      category: json['aqi']['category'] ?? 'Unknown',
      pollutants: pollutantMap,
      weather: Weather.fromJson(json['weather'] ?? {}),
      hourlyForecast: forecasts,
    );
  }
}

class Pollutant {
  final String code;
  final String name;
  final double value;
  final String unit;
  final String category;
  final String color;
  final double percentage;

  Pollutant({
    required this.code,
    required this.name,
    required this.value,
    required this.unit,
    required this.category,
    required this.color,
    this.percentage = 0.0,
  });

  factory Pollutant.fromJson(Map<String, dynamic> json) {
    // Calculate percentage based on value and standard
    double calculatePercentage() {
      switch (json['code']) {
        case 'PM2_5':
          return (json['value'] / 35.0).clamp(0.0, 1.0); // 35 µg/m³ is considered unhealthy
        case 'PM10':
          return (json['value'] / 150.0).clamp(0.0, 1.0); // 150 µg/m³ is considered unhealthy
        case 'O3':
          return (json['value'] / 150.0).clamp(0.0, 1.0); // 150 µg/m³ is considered unhealthy
        case 'NO2':
          return (json['value'] / 200.0).clamp(0.0, 1.0); // 200 µg/m³ is considered unhealthy
        default:
          return (json['value'] / 100.0).clamp(0.0, 1.0); // Default
      }
    }

    return Pollutant(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'µg/m³',
      category: json['category'] ?? 'Unknown',
      color: json['color'] ?? '#FFFF00',
      percentage: calculatePercentage(),
    );
  }
}

class Weather {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final String conditions;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.conditions,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['wind_speed'] ?? 0).toDouble(),
      windDirection: json['wind_direction'] ?? 'N',
      conditions: json['conditions'] ?? 'Unknown',
    );
  }
}

class HourlyForecast {
  final String hour;
  final int aqi;
  final String primaryPollutant;
  final String trend;

  HourlyForecast({
    required this.hour,
    required this.aqi,
    required this.primaryPollutant,
    required this.trend,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      hour: json['hour'] ?? '',
      aqi: json['aqi'] ?? 0,
      primaryPollutant: json['primaryPollutant'] ?? 'Unknown',
      trend: json['trend'] ?? 'stable',
    );
  }
}