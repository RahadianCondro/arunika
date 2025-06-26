// lib/data/models/exposure_history.dart
import 'package:latlong2/latlong.dart';

class ExposureHistory {
  final String date;
  final int averageAqi;
  final List<LocationExposure> locations;
  final Map<String, PollutantExposure> pollutants;

  ExposureHistory({
    required this.date,
    required this.averageAqi,
    required this.locations,
    required this.pollutants,
  });

  // Create from JSON
  factory ExposureHistory.fromJson(Map<String, dynamic> json) {
    // Parse locations
    final locationsList = (json['locations'] as List)
        .map((loc) => LocationExposure.fromJson(loc))
        .toList();

    // Parse pollutants
    final Map<String, PollutantExposure> pollutantsMap = {};
    (json['pollutants'] as Map<String, dynamic>).forEach((key, value) {
      pollutantsMap[key] = PollutantExposure.fromJson(value);
    });

    return ExposureHistory(
      date: json['date'],
      averageAqi: json['averageAqi'],
      locations: locationsList,
      pollutants: pollutantsMap,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    // Convert locations to JSON
    final locationsJson = locations.map((loc) => loc.toJson()).toList();

    // Convert pollutants to JSON
    final Map<String, dynamic> pollutantsJson = {};
    pollutants.forEach((key, value) {
      pollutantsJson[key] = value.toJson();
    });

    return {
      'date': date,
      'averageAqi': averageAqi,
      'locations': locationsJson,
      'pollutants': pollutantsJson,
    };
  }

  // Get category based on AQI
  String getAqiCategory() {
    if (averageAqi <= 50) {
      return 'Baik';
    } else if (averageAqi <= 100) {
      return 'Sedang';
    } else if (averageAqi <= 150) {
      return 'Tidak Sehat untuk Kelompok Sensitif';
    } else if (averageAqi <= 200) {
      return 'Tidak Sehat';
    } else if (averageAqi <= 300) {
      return 'Sangat Tidak Sehat';
    } else {
      return 'Berbahaya';
    }
  }

  // Get total exposure duration across all locations
  double getTotalExposureDuration() {
    return locations.fold(0, (total, loc) => total + loc.duration);
  }
}

class LocationExposure {
  final String name;
  final double lat;
  final double lon;
  final int aqi;
  final double duration; // in hours

  LocationExposure({
    required this.name,
    required this.lat,
    required this.lon,
    required this.aqi,
    required this.duration,
  });

  // Create from JSON
  factory LocationExposure.fromJson(Map<String, dynamic> json) {
    return LocationExposure(
      name: json['name'],
      lat: json['lat'],
      lon: json['lon'],
      aqi: json['aqi'],
      duration: json['duration'].toDouble(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lon': lon,
      'aqi': aqi,
      'duration': duration,
    };
  }
  
  // Get LatLng representation
  LatLng get latLng => LatLng(lat, lon);
}

class PollutantExposure {
  final double average;
  final double peak;
  final double? duration;

  PollutantExposure({
    required this.average,
    required this.peak,
    this.duration,
  });

  // Create from JSON
  factory PollutantExposure.fromJson(Map<String, dynamic> json) {
    return PollutantExposure(
      average: json['average'].toDouble(),
      peak: json['peak'].toDouble(),
      duration: json['duration']?.toDouble(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'peak': peak,
      if (duration != null) 'duration': duration,
    };
  }
}

// This class is an alias for PollutantExposure to maintain compatibility with old code
// that might be using ExposureData
class ExposureData extends PollutantExposure {
  ExposureData({
    required double average,
    required double peak,
    double? duration,
  }) : super(
    average: average,
    peak: peak,
    duration: duration,
  );
  
  factory ExposureData.fromJson(Map<String, dynamic> json) {
    return ExposureData(
      average: json['average'].toDouble(),
      peak: json['peak'].toDouble(),
      duration: json['duration']?.toDouble(),
    );
  }
}