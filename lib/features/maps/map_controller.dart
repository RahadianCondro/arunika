// lib/features/maps/map_controller.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/map_data.dart';
import '../../data/repositories/map_repository.dart';

// Renamed to AqiMapController to avoid name conflict with flutter_map's MapController
class AqiMapController extends ChangeNotifier {
  final MapRepository _mapRepository = MapRepository();
  
  bool _isLoading = true;
  bool _showStations = true;
  bool _showHeatmap = true;
  bool _showHotspots = false;
  bool _showSafeZones = false;
  String _selectedPollutant = 'AQI';
  
  LatLng _center = LatLng(-7.797068, 110.370529); // Malioboro, Yogyakarta as default
  double _initialZoom = 14.0;
  
  List<AqiMapPoint> _mapPoints = [];
  List<MonitoringStation> _stations = [];
  
  // Getters
  bool get isLoading => _isLoading;
  bool get showStations => _showStations;
  bool get showHeatmap => _showHeatmap;
  bool get showHotspots => _showHotspots;
  bool get showSafeZones => _showSafeZones;
  String get selectedPollutant => _selectedPollutant;
  LatLng get center => _center;
  double get initialZoom => _initialZoom;
  List<AqiMapPoint> get mapPoints => _mapPoints;
  List<MonitoringStation> get stations => _stations;
  
  // Methods
  void loadData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final mapData = await _mapRepository.getMapData();
      _mapPoints = mapData.mapPoints;
      _stations = mapData.stations;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Handle error
    }
  }
  
  void toggleStations(bool value) {
    _showStations = value;
    notifyListeners();
  }
  
  void toggleHeatmap(bool value) {
    _showHeatmap = value;
    notifyListeners();
  }
  
  void toggleHotspots(bool value) {
    _showHotspots = value;
    notifyListeners();
  }
  
  void toggleSafeZones(bool value) {
    _showSafeZones = value;
    notifyListeners();
  }
  
  void selectPollutant(String pollutant) {
    _selectedPollutant = pollutant;
    notifyListeners();
  }
  
  Color getAqiColor(int aqi) {
    if (aqi <= 50) {
      return AppColors.aqiGood;
    } else if (aqi <= 100) {
      return AppColors.aqiModerate;
    } else if (aqi <= 150) {
      return AppColors.aqiUnhealthySensitive;
    } else if (aqi <= 200) {
      return AppColors.aqiUnhealthy;
    } else if (aqi <= 300) {
      return AppColors.aqiVeryUnhealthy;
    } else {
      return AppColors.aqiHazardous;
    }
  }
}