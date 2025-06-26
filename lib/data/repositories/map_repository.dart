// lib/data/repositories/map_repository.dart
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import '../models/map_data.dart';

class MapRepository {
  // In a real app, this would make API calls to a backend server
  // For now, we'll use mock data
  
  Future<MapData> getMapData() async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data for air quality map
    final mapPoints = [
      {
        'lat': -7.797068,
        'lon': 110.370529,
        'aqi': 68,
        'pollutants': {
          'PM2_5': 20.5,
          'PM10': 45.2,
          'O3': 35.8,
          'NO2': 15.3,
        }
      },
      {
        'lat': -7.782900,
        'lon': 110.367032,
        'aqi': 42,
        'pollutants': {
          'PM2_5': 12.1,
          'PM10': 30.5,
          'O3': 28.6,
          'NO2': 10.2,
        }
      },
      {
        'lat': -7.803500,
        'lon': 110.378800,
        'aqi': 85,
        'pollutants': {
          'PM2_5': 28.3,
          'PM10': 62.1,
          'O3': 40.5,
          'NO2': 22.8,
        }
      },
      {
        'lat': -7.790000,
        'lon': 110.380000,
        'aqi': 110,
        'pollutants': {
          'PM2_5': 35.6,
          'PM10': 78.3,
          'O3': 55.2,
          'NO2': 30.5,
        }
      },
      {
        'lat': -7.775800,
        'lon': 110.355600,
        'aqi': 35,
        'pollutants': {
          'PM2_5': 8.2,
          'PM10': 22.7,
          'O3': 25.1,
          'NO2': 7.8,
        }
      },
    ];
    
    final stations = [
      {
        'id': 'station-1',
        'name': 'Malioboro Monitoring Station',
        'latitude': -7.797068,
        'longitude': 110.370529,
        'aqi': 68,
        'pollutants': {
          'PM2_5': 20.5,
          'PM10': 45.2,
          'O3': 35.8,
          'NO2': 15.3,
          'SO2': 8.2,
          'CO': 1.2,
        },
        'device_type': 'Government',
        'last_updated': '2025-05-01T09:30:00Z',
      },
      {
        'id': 'station-2',
        'name': 'UGM Campus Monitoring Station',
        'latitude': -7.782900,
        'longitude': 110.367032,
        'aqi': 42,
        'pollutants': {
          'PM2_5': 12.1,
          'PM10': 30.5,
          'O3': 28.6,
          'NO2': 10.2,
          'SO2': 5.5,
          'CO': 0.8,
        },
        'device_type': 'Academic',
        'last_updated': '2025-05-01T09:45:00Z',
      },
      {
        'id': 'station-3',
        'name': 'East Ringroad Junction Station',
        'latitude': -7.790000,
        'longitude': 110.380000,
        'aqi': 110,
        'pollutants': {
          'PM2_5': 35.6,
          'PM10': 78.3,
          'O3': 55.2,
          'NO2': 30.5,
          'SO2': 18.3,
          'CO': 2.5,
        },
        'device_type': 'Government',
        'last_updated': '2025-05-01T09:15:00Z',
      },
    ];
    
    final mapData = {
      'map_points': mapPoints,
      'stations': stations,
    };
    
    return MapData.fromJson(mapData);
  }
}