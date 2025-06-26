// lib/data/models/map_data.dart
import 'package:latlong2/latlong.dart';

class MapData {
  final List<AqiMapPoint> mapPoints;
  final List<MonitoringStation> stations;
  
  MapData({
    required this.mapPoints,
    required this.stations,
  });
  
  factory MapData.fromJson(Map<String, dynamic> json) {
    return MapData(
      mapPoints: (json['map_points'] as List)
          .map((point) => AqiMapPoint.fromJson(point))
          .toList(),
      stations: (json['stations'] as List)
          .map((station) => MonitoringStation.fromJson(station))
          .toList(),
    );
  }
}

class AqiMapPoint {
  final double lat;
  final double lon;
  final int aqi;
  final Map<String, double> pollutants;
  
  AqiMapPoint({
    required this.lat,
    required this.lon,
    required this.aqi,
    required this.pollutants,
  });
  
  factory AqiMapPoint.fromJson(Map<String, dynamic> json) {
    final Map<String, double> pollutantMap = {};
    if (json['pollutants'] != null) {
      (json['pollutants'] as Map<String, dynamic>).forEach((key, value) {
        pollutantMap[key] = value.toDouble();
      });
    }
    
    return AqiMapPoint(
      lat: json['lat'].toDouble(),
      lon: json['lon'].toDouble(),
      aqi: json['aqi'],
      pollutants: pollutantMap,
    );
  }
}

class MonitoringStation {
  final String id;
  final String name;
  final LatLng latLng;
  final int aqi;
  final Map<String, double> pollutants;
  final String deviceType;
  final DateTime lastUpdated;
  
  MonitoringStation({
    required this.id,
    required this.name,
    required this.latLng,
    required this.aqi,
    required this.pollutants,
    required this.deviceType,
    required this.lastUpdated,
  });
  
  factory MonitoringStation.fromJson(Map<String, dynamic> json) {
    final Map<String, double> pollutantMap = {};
    if (json['pollutants'] != null) {
      (json['pollutants'] as Map<String, dynamic>).forEach((key, value) {
        pollutantMap[key] = value.toDouble();
      });
    }
    
    return MonitoringStation(
      id: json['id'],
      name: json['name'],
      latLng: LatLng(
        json['latitude'].toDouble(),
        json['longitude'].toDouble(),
      ),
      aqi: json['aqi'],
      pollutants: pollutantMap,
      deviceType: json['device_type'] ?? 'Standard',
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}