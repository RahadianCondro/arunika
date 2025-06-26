// lib/data/models/route.dart
import 'package:latlong2/latlong.dart';

class OptimizedRoute {
  final String id;
  final String type; // "lowest_exposure", "fastest", "balanced"
  List<LatLng> path; // Changed from final to mutable
  final double distance; // dalam kilometer
  int duration; // Changed from final to mutable for duration adjustments
  final Map<String, dynamic> exposure; // misalnya {'aqi_avg': 50, 'pm25_avg': 15}
  
  OptimizedRoute({
    String? id,
    required this.type,
    required this.path,
    required this.distance,
    required this.duration,
    required this.exposure,
  }) : id = id ?? 'route-${DateTime.now().millisecondsSinceEpoch}';
  
  factory OptimizedRoute.fromJson(Map<String, dynamic> json) {
    return OptimizedRoute(
      id: json['id'],
      type: json['type'],
      path: (json['path'] as List).map((point) {
        return LatLng(
          point['lat'].toDouble(),
          point['lng'].toDouble(),
        );
      }).toList(),
      distance: json['distance'].toDouble(),
      duration: json['duration'],
      exposure: json['exposure'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'path': path.map((point) => {
        'lat': point.latitude,
        'lng': point.longitude,
      }).toList(),
      'distance': distance,
      'duration': duration,
      'exposure': exposure,
    };
  }
}