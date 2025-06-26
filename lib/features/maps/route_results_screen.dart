// lib/features/maps/route_results_screen.dart
// Screen untuk menampilkan perbandingan rute

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/route.dart';
import '../../routes.dart';

class RouteResultsScreen extends StatefulWidget {
  final List<OptimizedRoute> routes;
  final LatLng startLocation;
  final LatLng destinationLocation;
  final String startName;
  final String destinationName;

  const RouteResultsScreen({
    Key? key,
    required this.routes,
    required this.startLocation,
    required this.destinationLocation,
    required this.startName,
    required this.destinationName,
  }) : super(key: key);

  @override
  State<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends State<RouteResultsScreen> {
  late final MapController _mapController;
  int _selectedRouteIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    // Default, pilih rute dengan exposure terendah jika ada
    final lowestExposureIndex = widget.routes
        .indexWhere((route) => route.type == 'lowest_exposure');
    if (lowestExposureIndex != -1) {
      _selectedRouteIndex = lowestExposureIndex;
    }
    
    // Schedule fitBounds setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitRouteBounds();
    });
  }
  
  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
  
  void _fitRouteBounds() {
    if (widget.routes.isEmpty) return;
    
    final route = widget.routes[_selectedRouteIndex];
    if (route.path.isEmpty) return;
    
    // Find bounding box
    double minLat = route.path.first.latitude;
    double maxLat = route.path.first.latitude;
    double minLng = route.path.first.longitude;
    double maxLng = route.path.first.longitude;
    
    for (final point in route.path) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }
    
    // Add padding
    minLat -= 0.01;
    maxLat += 0.01;
    minLng -= 0.01;
    maxLng += 0.01;
    
    // Fit bounds
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat, minLng),
          LatLng(maxLat, maxLng),
        ),
        padding: const EdgeInsets.all(50.0),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hasil Optimasi Rute',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.gray30,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppDimensions.spacing2),
                Expanded(
                  child: Text(
                    '${widget.startName} → ${widget.destinationName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Map view
          Expanded(
            flex: 1,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  (widget.startLocation.latitude + widget.destinationLocation.latitude) / 2,
                  (widget.startLocation.longitude + widget.destinationLocation.longitude) / 2,
                ),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.yourcompany.arunika',
                  tileProvider: NetworkTileProvider(),
                ),
                // Route polylines
                ...widget.routes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final route = entry.value;
                  
                  Color color;
                  if (route.type == 'lowest_exposure') {
                    color = AppColors.success;
                  } else if (route.type == 'fastest') {
                    color = AppColors.secondary;
                  } else {
                    color = AppColors.tertiary;
                  }
                  
                  return PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route.path,
                        strokeWidth: _selectedRouteIndex == index ? 5.0 : 3.0,
                        color: _selectedRouteIndex == index
                            ? color
                            : color.withOpacity(0.5),
                      ),
                    ],
                  );
                }).toList(),
                // Start and destination markers
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.startLocation,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.trip_origin,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    Marker(
                      point: widget.destinationLocation,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.secondary,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Route options
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                padding: EdgeInsets.all(AppDimensions.spacing3),
                itemCount: widget.routes.length,
                itemBuilder: (context, index) {
                  final route = widget.routes[index];
                  return _buildRouteCard(route, index);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Route tab
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRoutes.dashboard,
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRoutes.map,
              (route) => false,
            );
          } else if (index != 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur ini akan tersedia segera!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray60,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Peta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: 'Rute',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Kesehatan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
  
  Widget _buildRouteCard(OptimizedRoute route, int index) {
    final isSelected = index == _selectedRouteIndex;
    
    // Tentukan warna dan judul berdasarkan tipe rute
    Color routeColor;
    String routeTitle;
    IconData routeIcon;
    
    if (route.type == 'lowest_exposure') {
      routeColor = AppColors.success;
      routeTitle = 'RUTE TERSEHAT';
      routeIcon = Icons.favorite;
    } else if (route.type == 'fastest') {
      routeColor = AppColors.secondary;
      routeTitle = 'RUTE TERCEPAT';
      routeIcon = Icons.speed;
    } else {
      routeColor = AppColors.tertiary;
      routeTitle = 'RUTE SEIMBANG';
      routeIcon = Icons.balance;
    }
    
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.spacing3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: isSelected 
              ? routeColor 
              : routeColor.withOpacity(0.3),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRouteIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                vertical: AppDimensions.spacing2,
                horizontal: AppDimensions.spacing4,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isSelected 
                    ? routeColor.withOpacity(0.2) 
                    : routeColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusMedium),
                  topRight: Radius.circular(AppDimensions.radiusMedium),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    routeIcon,
                    color: routeColor,
                    size: 16,
                  ),
                  SizedBox(width: AppDimensions.spacing2),
                  Text(
                    routeTitle,
                    style: TextStyle(
                      color: routeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimensions.small,
                    ),
                  ),
                  if (isSelected) ...[
                    SizedBox(width: AppDimensions.spacing2),
                    Icon(
                      Icons.check_circle,
                      color: routeColor,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(AppDimensions.spacing3),
              child: Column(
                children: [
                  // Info metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRouteInfoItem(
                        'AQI rata-rata',
                        route.exposure['aqi_avg'].toString(),
                        _getAqiColor(route.exposure['aqi_avg'] as int),
                      ),
                      _buildRouteInfoItem(
                        'Jarak',
                        '${route.distance} km',
                        AppColors.gray70,
                      ),
                      _buildRouteInfoItem(
                        'Waktu',
                        '${route.duration} menit',
                        AppColors.gray70,
                      ),
                    ],
                  ),
                  
                  // Comparison label (hanya untuk rute dengan paparan terendah)
                  if (route.type == 'lowest_exposure' && widget.routes.length > 1) ...[
                    SizedBox(height: AppDimensions.spacing3),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing3,
                        vertical: AppDimensions.spacing2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.eco,
                            color: AppColors.success,
                            size: 16,
                          ),
                          SizedBox(width: AppDimensions.spacing2),
                          Text(
                            '40% paparan lebih rendah',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: AppDimensions.small,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Action buttons
                  SizedBox(height: AppDimensions.spacing3),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Tampilkan detail rute
                            _showRouteDetails(context, route);
                          },
                          icon: Icon(Icons.info_outline),
                          label: Text('Detail'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
                            foregroundColor: isSelected 
                                ? routeColor 
                                : AppColors.gray60,
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacing3),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Pilih rute ini dan mulai navigasi
                            setState(() {
                              _selectedRouteIndex = index;
                            });
                            
                            // Dalam aplikasi sebenarnya, ini akan memulai navigasi
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Memulai navigasi...'),
                                backgroundColor: routeColor,
                              ),
                            );
                          },
                          icon: Icon(Icons.navigation),
                          label: Text('Mulai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: routeColor,
                            padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: Duration(milliseconds: 100 * index));
  }
  
  Widget _buildRouteInfoItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.gray60,
            fontSize: AppDimensions.small,
          ),
        ),
        SizedBox(height: AppDimensions.spacing1),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.paragraph,
          ),
        ),
      ],
    );
  }
  
  void _showRouteDetails(BuildContext context, OptimizedRoute route) {
    String _formatNumericValue(dynamic value) {
  if (value is double) {
    return value.toStringAsFixed(1); // Show only 1 decimal place
  } else if (value is int) {
    return value.toString();
  } else {
    try {
      // Try to parse as double first
      return double.parse(value.toString()).toStringAsFixed(1);
    } catch (e) {
      return value.toString();
    }
  }
}
    // Buat box chart untuk perbandingan polutan
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusLarge),
              topRight: Radius.circular(AppDimensions.radiusLarge),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray40,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Rute',
                      style: TextStyle(
                        fontSize: AppDimensions.heading3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing1),
                    Text(
                      _getRouteTitle(route.type),
                      style: TextStyle(
                        fontSize: AppDimensions.paragraph,
                        color: _getRouteColor(route.type),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppDimensions.spacing3),
              
              // Route metrics
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                child: Container(
                  padding: EdgeInsets.all(AppDimensions.spacing3),
                  decoration: BoxDecoration(
                    color: AppColors.gray10,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Column(
                    children: [
                      _buildMetricRow(
                        'Jarak Total', 
                        '${route.distance} km', 
                        Icons.straighten
                      ),
                      SizedBox(height: AppDimensions.spacing2),
                      _buildMetricRow(
                        'Waktu Tempuh Estimasi', 
                        '${route.duration} menit', 
                        Icons.access_time
                      ),
                      SizedBox(height: AppDimensions.spacing2),
                      _buildMetricRow(
                        'AQI Rata-rata', 
                        '${route.exposure['aqi_avg']}', 
                        Icons.air,
                        valueColor: _getAqiColor(route.exposure['aqi_avg'] as int),
                      ),
                      if (route.exposure.containsKey('pm25_avg')) ...[
                        SizedBox(height: AppDimensions.spacing2),
                        _buildMetricRow(
                          'PM2.5 Rata-rata', 
                          '${_formatNumericValue(route.exposure['pm25_avg'])} µg/m³', 
                          Icons.blur_on
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: AppDimensions.spacing4),
              
              // Details title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                child: Text(
                  'Perbandingan Polutan',
                  style: TextStyle(
                    fontSize: AppDimensions.heading4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(height: AppDimensions.spacing3),
              
              // AQI comparison
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                child: _buildComparisonChart(route),
              ),
              
              SizedBox(height: AppDimensions.spacing4),
              
              // Recommendation title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                child: Text(
                  'Rekomendasi',
                  style: TextStyle(
                    fontSize: AppDimensions.heading4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(height: AppDimensions.spacing2),
              
              // Recommendations
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppDimensions.spacing4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecommendationItem(
                        'Sesuaikan Waktu Perjalanan',
                        'Kualitas udara cenderung lebih baik pada pagi hari antara pukul 5-7 pagi.',
                        Icons.access_time,
                      ),
                      SizedBox(height: AppDimensions.spacing3),
                      _buildRecommendationItem(
                        'Gunakan Masker',
                        'Paparan polutan pada rute ini bisa dikurangi dengan menggunakan masker N95.',
                        Icons.masks,
                      ),
                      if (route.type == 'fastest') ...[
                        SizedBox(height: AppDimensions.spacing3),
                        _buildRecommendationItem(
                          'Pertimbangkan Rute Alternatif',
                          'Rute ini memiliki paparan polutan yang lebih tinggi. Pertimbangkan rute dengan udara lebih bersih.',
                          Icons.shuffle,
                          color: AppColors.warning,
                        ),
                      ],
                      if (route.type == 'lowest_exposure') ...[
                        SizedBox(height: AppDimensions.spacing3),
                        _buildRecommendationItem(
                          'Rute Terbaik untuk Kesehatan',
                          'Rute ini meminimalkan paparan polutan dan direkomendasikan untuk pengguna dengan kondisi pernapasan sensitif.',
                          Icons.verified,
                          color: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildMetricRow(String label, String value, IconData icon, {Color? valueColor}) {
    String _formatNumericValue(dynamic value) {
  if (value is double) {
    return value.toStringAsFixed(1); // Show only 1 decimal place
  } else if (value is int) {
    return value.toString();
  } else {
    try {
      // Try to parse as double first
      return double.parse(value.toString()).toStringAsFixed(1);
    } catch (e) {
      return value.toString();
    }
  }
}

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppDimensions.spacing2),
          decoration: BoxDecoration(
            color: AppColors.gray20,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.gray70,
          ),
        ),
        SizedBox(width: AppDimensions.spacing3),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.paragraph,
              color: AppColors.gray70,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppDimensions.paragraph,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildComparisonChart(OptimizedRoute route) {
    // Dalam aplikasi sebenarnya, akan menggunakan chart library seperti fl_chart
    // Untuk MVP, kita gunakan representasi visual sederhana
    
    final aqiValue = route.exposure['aqi_avg'] as int;
    final aqiColor = _getAqiColor(aqiValue);
    final aqiPercentage = (aqiValue / 300 * 100).clamp(0, 100);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Indeks Kualitas Udara (AQI)',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: AppDimensions.small,
          ),
        ),
        SizedBox(height: AppDimensions.spacing2),
        Stack(
          children: [
            // Background bar
            Container(
              height: 24,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.gray20,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
            // Value bar
            Container(
              height: 24,
              width: MediaQuery.of(context).size.width * (aqiPercentage / 100) * 0.8, // 80% of width
              decoration: BoxDecoration(
                color: aqiColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: AppDimensions.spacing2),
              child: Text(
                aqiValue.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.small,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAqiLegendItem('Baik', AppColors.aqiGood),
            _buildAqiLegendItem('Sedang', AppColors.aqiModerate),
            _buildAqiLegendItem('Tidak Sehat', AppColors.aqiUnhealthySensitive),
            _buildAqiLegendItem('Berbahaya', AppColors.aqiUnhealthy),
          ],
        ),
      ],
    );
  }
  
  Widget _buildAqiLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.gray70,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecommendationItem(String title, String description, IconData icon, {Color? color}) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacing3),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: (color ?? AppColors.primary).withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color ?? AppColors.primary,
          ),
          SizedBox(width: AppDimensions.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimensions.paragraph,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppDimensions.spacing1),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: AppDimensions.small,
                    color: AppColors.gray70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getRouteTitle(String type) {
    switch (type) {
      case 'lowest_exposure':
        return 'Rute dengan Paparan Polutan Terendah';
      case 'fastest':
        return 'Rute Tercepat';
      case 'balanced':
        return 'Rute Seimbang';
      default:
        return 'Rute Umum';
    }
  }
  
  Color _getRouteColor(String type) {
    switch (type) {
      case 'lowest_exposure':
        return AppColors.success;
      case 'fastest':
        return AppColors.secondary;
      case 'balanced':
        return AppColors.tertiary;
      default:
        return AppColors.primary;
    }
  }
  
  Color _getAqiColor(int aqi) {
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