// lib/data/models/location.dart
import 'package:latlong2/latlong.dart';

class Location {
  final String id;
  final String name;
  final String address;
  final LatLng latLng;
  final Map<String, dynamic>? additionalInfo;

  Location({
    required this.id,
    required this.name,
    required this.address,
    required this.latLng,
    this.additionalInfo,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latLng: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
      'additionalInfo': additionalInfo,
    };
  }
}