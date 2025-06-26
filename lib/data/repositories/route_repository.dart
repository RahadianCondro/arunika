// lib/data/repositories/route_repository.dart
import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/route.dart';
import '../models/air_quality.dart';
import '../repositories/air_quality_repository.dart';

class RouteRepository {
  final AirQualityRepository _airQualityRepository = AirQualityRepository();
  final Random _random = Random();
  
  Future<List<OptimizedRoute>> getEnhancedOptimizedRoutes(
    LatLng startLocation,
    LatLng destinationLocation, {
    Map<String, dynamic>? options,
  }) async {
    // Simulasi penundaan jaringan
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Ekstrak opsi untuk personalisasi rute
    final String transportMode = options?['transportMode'] ?? 'walking';
    final String optimizationType = options?['optimizationType'] ?? 'lowestExposure';
    final bool avoidSteepInclines = options?['avoidSteepInclines'] ?? false;
    final bool preferShadedRoutes = options?['preferShadedRoutes'] ?? false;
    final bool avoidHighTrafficAreas = options?['avoidHighTrafficAreas'] ?? false;
    final bool considerHealthSensitivities = options?['considerHealthSensitivities'] ?? false;
    
    // Opsi kesehatan yang dipersonalisasi
    final List<String> healthConditions = options?['healthConditions'] ?? [];
    final Map<String, double> pollutantSensitivity = options?['pollutantSensitivity'] ?? {};
    
    // Menghasilkan rute yang dioptimalkan berdasarkan parameter
    List<OptimizedRoute> routes = [];
    
    // Rute dengan paparan terendah
routes.add(
  OptimizedRoute(
    id: 'route-lowest-exposure-${DateTime.now().millisecondsSinceEpoch}',  // Explicitly provide id
    type: 'lowest_exposure',
    path: _generateRoutePath(startLocation, destinationLocation, 'lowest_exposure'),
    distance: 3.8, // Dalam km
    duration: 48, // Dalam menit
    exposure: {
      'aqi_avg': 42,
      'pm25_avg': 12.5,
      'o3_avg': 38.2,
      'shade_percentage': preferShadedRoutes ? 72.0 : 58.0,
      'incline_avoided': avoidSteepInclines,
      'traffic_reduction': avoidHighTrafficAreas ? 65.0 : 30.0,
    },
  ),
);
    
    // Rute tercepat
routes.add(
  OptimizedRoute(
    id: 'route-fastest-${DateTime.now().millisecondsSinceEpoch}',  // Explicitly provide id
    type: 'fastest',
    path: _generateRoutePath(startLocation, destinationLocation, 'fastest'),
    distance: 2.9, // Dalam km
    duration: 35, // Dalam menit
    exposure: {
      'aqi_avg': 75,
      'pm25_avg': 28.6,
      'o3_avg': 52.8,
      'shade_percentage': 25.0,
      'incline_avoided': false,
      'traffic_reduction': 0.0,
    },
  ),
);
    
    // Rute seimbang
      routes.add(
        OptimizedRoute(
          id: 'route-balanced-${DateTime.now().millisecondsSinceEpoch}',  // Explicitly provide id
          type: 'balanced',
          path: _generateRoutePath(startLocation, destinationLocation, 'balanced'),
          distance: 3.3, // Dalam km
          duration: 42, // Dalam menit
          exposure: {
            'aqi_avg': 58,
            'pm25_avg': 19.5,
            'o3_avg': 45.3,
            'shade_percentage': preferShadedRoutes ? 45.0 : 35.0,
            'incline_avoided': avoidSteepInclines,
            'traffic_reduction': avoidHighTrafficAreas ? 35.0 : 15.0,
          },
        ),
      );
    
    // Menyesuaikan rute berdasarkan kondisi kesehatan jika diperlukan
    if (considerHealthSensitivities && healthConditions.isNotEmpty) {
      // Jika ada kondisi pernapasan, sesuaikan paparan AQI
      if (healthConditions.any((condition) => 
          condition.toLowerCase().contains('asma') || 
          condition.toLowerCase().contains('alergi') ||
          condition.toLowerCase().contains('paru'))) {
        
        // Memprioritaskan rute dengan paparan rendah
        var lowestExposureRoute = routes.firstWhere(
          (route) => route.type == 'lowest_exposure',
          orElse: () => routes.first,
        );
        
        // Memperbaiki jalur untuk menghindari area dengan polusi tinggi
        lowestExposureRoute.path = _generateOptimizedHealthPath(
          startLocation, 
          destinationLocation,
          healthConditions,
          pollutantSensitivity,
        );
        
        // Mengurangi paparan yang disimulasikan
        int adjustedAqi = (lowestExposureRoute.exposure['aqi_avg'] as int) - 8;
        lowestExposureRoute.exposure['aqi_avg'] = adjustedAqi > 0 ? adjustedAqi : 1;
      }
      
      // Jika aktivitas rendah atau masalah kardiovaskular, hindari tanjakan
      if (avoidSteepInclines) {
        for (var route in routes) {
          route.exposure['incline_avoided'] = true;
          
          // Tambahkan sedikit waktu tambahan untuk rute yang menghindari tanjakan
          if (route.type != 'fastest') {
            route.duration += 3; // Tambah 3 menit
          }
        }
      }
    }
    
    // Urutkan rute berdasarkan tipe optimasi yang dipilih
    if (optimizationType == 'lowestExposure') {
      routes.sort((a, b) => 
        (a.exposure['aqi_avg'] as int).compareTo(b.exposure['aqi_avg'] as int));
    } else if (optimizationType == 'shortestTime') {
      routes.sort((a, b) => a.duration.compareTo(b.duration));
    } else {
      // Untuk 'balanced', gunakan formula khusus untuk mengurutkan
      routes.sort((a, b) {
        double aScore = a.duration * 0.5 + (a.exposure['aqi_avg'] as int) * 0.5;
        double bScore = b.duration * 0.5 + (b.exposure['aqi_avg'] as int) * 0.5;
        return aScore.compareTo(bScore);
      });
    }
    
    return routes;
  }

  // Helper method for generating route paths
  List<LatLng> _generateRoutePath(LatLng start, LatLng end, String routeType) {
    // Implementation for generating route paths based on route type
    // This method is missing in your original code
    final List<LatLng> path = [];
    
    // Add start point
    path.add(start);
    
    // Calculate midpoints based on route type
    double latDiff = end.latitude - start.latitude;
    double lngDiff = end.longitude - start.longitude;
    
    // Different route patterns based on type
    if (routeType == 'lowest_exposure') {
      // More waypoints for the "healthiest" route
      path.add(LatLng(start.latitude + latDiff * 0.2, start.longitude + lngDiff * 0.1));
      path.add(LatLng(start.latitude + latDiff * 0.3, start.longitude + lngDiff * 0.35));
      path.add(LatLng(start.latitude + latDiff * 0.5, start.longitude + lngDiff * 0.4));
      path.add(LatLng(start.latitude + latDiff * 0.6, start.longitude + lngDiff * 0.6));
      path.add(LatLng(start.latitude + latDiff * 0.75, start.longitude + lngDiff * 0.8));
    } else if (routeType == 'fastest') {
      // Fewer waypoints for the fastest route
      path.add(LatLng(start.latitude + latDiff * 0.3, start.longitude + lngDiff * 0.3));
      path.add(LatLng(start.latitude + latDiff * 0.7, start.longitude + lngDiff * 0.7));
    } else { // balanced
      // Medium number of waypoints for balanced route
      path.add(LatLng(start.latitude + latDiff * 0.25, start.longitude + lngDiff * 0.2));
      path.add(LatLng(start.latitude + latDiff * 0.5, start.longitude + lngDiff * 0.5));
      path.add(LatLng(start.latitude + latDiff * 0.7, start.longitude + lngDiff * 0.65));
    }
    
    // Add end point
    path.add(end);
    
    return path;
  }
  
  // Add this method that was referenced but not defined in your code
  List<LatLng> _generateOptimizedHealthPath(
    LatLng startLocation,
    LatLng destinationLocation,
    List<String> healthConditions,
    Map<String, double> pollutantSensitivity,
  ) {
    // Membuat jalur yang lebih optimal dari titik awal ke tujuan
    // Simulasi jalur yang menghindari area dengan polusi tinggi
    
    // Mengembalikan jalur dasar dengan beberapa titik tambahan untuk menghindari area polusi
    List<LatLng> path = _generateRoutePath(startLocation, destinationLocation, 'lowest_exposure');
    
    // Tambahkan sedikit variasi untuk menghindari area polusi yang disimulasikan
    // Pada implementasi nyata, ini akan menggunakan data polusi sebenarnya
    if (path.length > 3) {
      // Modifikasi beberapa titik di tengah jalur untuk menghindari area polusi
      int midIndex = path.length ~/ 2;
      
      // Geser sedikit ke arah yang lebih bersih (simulasi)
      path[midIndex] = LatLng(
        path[midIndex].latitude + 0.0015,
        path[midIndex].longitude - 0.0012,
      );
      
      // Tambahkan beberapa titik untuk membuat rute yang lebih halus
      path.insert(midIndex, LatLng(
        path[midIndex-1].latitude + 0.0008,
        path[midIndex-1].longitude - 0.0006,
      ));
      
      path.insert(midIndex+1, LatLng(
        path[midIndex+1].latitude + 0.0008,
        path[midIndex+1].longitude - 0.0006,
      ));
    }
    
    return path;
  }

  // Mendapatkan beberapa rute optimasi berdasarkan kriteria yang berbeda
  Future<List<OptimizedRoute>> getOptimizedRoutes(
    LatLng start,
    LatLng destination,
    {String? transportMode, String? optimizationType}
  ) async {
    // Existing implementation...
    // Rest of the code remains the same...
    
    // Dalam aplikasi sebenarnya, akan memanggil API seperti Google Directions API
    // dan menggunakan data kualitas udara untuk optimasi
    
    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Dapatkan data kualitas udara untuk simulasi
    final airQualityData = await _airQualityRepository.getCurrentAirQuality();
    
    // Generate 3 rute alternatif:
    // 1. Rute dengan paparan polutan minimal
    // 2. Rute tercepat (shortest)
    // 3. Rute seimbang (kompromi antara waktu dan paparan)
    
    final lowestExposureRoute = await _generateRouteWithLowestExposure(
      start, destination, airQualityData);
    
    final fastestRoute = await _generateFastestRoute(
      start, destination);
    
    final balancedRoute = await _generateBalancedRoute(
      start, destination, airQualityData);
    
    return [lowestExposureRoute, fastestRoute, balancedRoute];
  }
  
  // Generate rute dengan paparan polutan terendah
  Future<OptimizedRoute> _generateRouteWithLowestExposure(
    LatLng start, 
    LatLng destination,
    AirQuality airQualityData
  ) async {
    // Pada implementasi sebenarnya, akan menggunakan algoritma pathfinding yang
    // memperhitungkan tingkat polutan pada berbagai area
    
    // Untuk simulasi, generate path yang lebih panjang tapi dengan AQI yang lebih baik
    final List<LatLng> path = _generateSimulatedPath(
      start, 
      destination,
      lengthMultiplier: 1.3, 
      jaggedness: 0.4, 
      minPoints: 10,
    );
    
    // Simulasi exposure (lebih rendah)
    final Map<String, dynamic> exposure = {
      'aqi_avg': 52 + _random.nextInt(10),
      'aqi_max': 65 + _random.nextInt(15),
      'pm25_avg': 15.2 + _random.nextDouble() * 5,
      'duration_minutes': 32 + _random.nextInt(5),
    };
    
    return OptimizedRoute(
      id: 'route-lowest-exposure-${DateTime.now().millisecondsSinceEpoch}',
      type: 'lowest_exposure',
      path: path,
      distance: _calculateDistance(path),
      duration: 32 + _random.nextInt(5),
      exposure: exposure,
    );
  }
  
  // Generate rute tercepat
  Future<OptimizedRoute> _generateFastestRoute(
    LatLng start, 
    LatLng destination
  ) async {
    // Pada implementasi sebenarnya, akan menggunakan Directions API
    
    // Untuk simulasi, generate path yang lurus dan pendek
    final List<LatLng> path = _generateSimulatedPath(
      start, 
      destination,
      lengthMultiplier: 1.0, 
      jaggedness: 0.2, 
      minPoints: 5,
    );
    
    // Simulasi exposure (lebih tinggi)
    final Map<String, dynamic> exposure = {
      'aqi_avg': 85 + _random.nextInt(15),
      'aqi_max': 110 + _random.nextInt(20),
      'pm25_avg': 25.5 + _random.nextDouble() * 8,
      'duration_minutes': 20 + _random.nextInt(5),
    };
    
    return OptimizedRoute(
      id: 'route-fastest-${DateTime.now().millisecondsSinceEpoch}',
      type: 'fastest',
      path: path,
      distance: _calculateDistance(path),
      duration: 20 + _random.nextInt(5),
      exposure: exposure,
    );
  }
  
  // Generate rute seimbang
  Future<OptimizedRoute> _generateBalancedRoute(
    LatLng start, 
    LatLng destination,
    AirQuality airQualityData
  ) async {
    // Pada implementasi sebenarnya, akan menggunakan algorithm yang
    // menimbang antara waktu tempuh dan paparan polutan
    
    // Untuk simulasi, generate path yang lebih panjang dari fastest tapi lebih pendek
    // dari lowest exposure
    final List<LatLng> path = _generateSimulatedPath(
      start, 
      destination,
      lengthMultiplier: 1.15, 
      jaggedness: 0.3, 
      minPoints: 8,
    );
    
    // Simulasi exposure (menengah)
    final Map<String, dynamic> exposure = {
      'aqi_avg': 65 + _random.nextInt(15),
      'aqi_max': 85 + _random.nextInt(15),
      'pm25_avg': 20.5 + _random.nextDouble() * 6,
      'duration_minutes': 26 + _random.nextInt(5),
    };
    
    return OptimizedRoute(
      id: 'route-balanced-${DateTime.now().millisecondsSinceEpoch}',
      type: 'balanced',
      path: path,
      distance: _calculateDistance(path),
      duration: 26 + _random.nextInt(5),
      exposure: exposure,
    );
  }
  
  // Generate path simulasi antara dua titik
  List<LatLng> _generateSimulatedPath(
    LatLng start, 
    LatLng destination, 
    {double lengthMultiplier = 1.0, 
     double jaggedness = 0.3,
     int minPoints = 6}
  ) {
    final List<LatLng> path = [start];
    
    // Menghitung titik tengah antara start dan destination
    final midLat = (start.latitude + destination.latitude) / 2;
    final midLng = (start.longitude + destination.longitude) / 2;
    
    // Menghitung offset untuk membuat rute lebih realistis
    final latOffset = (destination.latitude - start.latitude) * jaggedness;
    final lngOffset = (destination.longitude - start.longitude) * jaggedness;
    
    // Jumlah titik di path (acak, tapi setidaknya minPoints)
    final numPoints = minPoints + _random.nextInt(5);
    
    // Generate titik-titik antara start dan destination
    for (int i = 1; i < numPoints - 1; i++) {
      final ratio = i / (numPoints - 1);
      
      // Interpolasi linier antara start dan destination
      final baseLat = start.latitude + (destination.latitude - start.latitude) * ratio;
      final baseLng = start.longitude + (destination.longitude - start.longitude) * ratio;
      
      // Tambahkan randomness untuk membuat jalur terlihat natural
      final randomLat = baseLat + ((_random.nextDouble() * 2 - 1) * latOffset);
      final randomLng = baseLng + ((_random.nextDouble() * 2 - 1) * lngOffset);
      
      path.add(LatLng(randomLat, randomLng));
    }
    
    path.add(destination);
    return path;
  }
  
  // Menghitung jarak total path dalam kilometer
  double _calculateDistance(List<LatLng> path) {
    double distance = 0;
    for (int i = 0; i < path.length - 1; i++) {
      distance += _calculateDistanceBetweenPoints(path[i], path[i + 1]);
    }
    
    // Round to 1 decimal place
    return double.parse(distance.toStringAsFixed(1));
  }
  
  // Menghitung jarak antar dua titik menggunakan Haversine formula
  double _calculateDistanceBetweenPoints(LatLng point1, LatLng point2) {
    const int earthRadius = 6371; // Radius bumi dalam km
    
    final lat1 = point1.latitude * pi / 180;
    final lng1 = point1.longitude * pi / 180;
    final lat2 = point2.latitude * pi / 180;
    final lng2 = point2.longitude * pi / 180;
    
    final dLat = lat2 - lat1;
    final dLng = lng2 - lng1;
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(lat1) * cos(lat2) * 
              sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
}