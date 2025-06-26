// lib/features/maps/route_planning_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/location.dart';
import '../../data/models/route.dart';
import '../../data/repositories/route_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../../routes.dart';
import '../../core/widgets/location_search_widget.dart';
import '../../core/widgets/app_bottom_navigation_bar.dart';

class RoutePlanningScreen extends StatefulWidget {
  const RoutePlanningScreen({Key? key}) : super(key: key);

  @override
  State<RoutePlanningScreen> createState() => _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends State<RoutePlanningScreen> {
  final RouteRepository _routeRepository = RouteRepository();
  final LocationRepository _locationRepository = LocationRepository(); // Tambahkan repository lokasi
  
  bool _isLoading = false;
  bool _hasRoutes = false;
  List<OptimizedRoute> _routes = [];
  
  // Form controllers
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  
  // Default locations
  final LatLng _currentLocation = LatLng(-7.797068, 110.370529); // Malioboro, Yogyakarta
  LatLng? _startLocation;
  LatLng? _destinationLocation;
  
  // Selected transport mode
  String _transportMode = 'walking'; // walking, cycling, driving
  
  // Selected optimization type
  String _optimizationType = 'lowestExposure'; // lowestExposure, shortestTime, balanced
  
  late final MapController _mapController;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _startLocation = _currentLocation;
    _startController.text = 'Lokasi Saat Ini';
    
    // Periksa jika ada argumen dari navigasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        if (args.containsKey('destination') && args['destination'] is Location) {
          final destination = args['destination'] as Location;
          setState(() {
            _destinationLocation = destination.latLng;
            _destinationController.text = destination.name;
          });
        }
      }
    });
  }
  
  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
  
  void _findRoutes() async {
    if (_startLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan pilih titik awal dan tujuan'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final routes = await _routeRepository.getOptimizedRoutes(
        _startLocation!,
        _destinationLocation!,
        transportMode: _transportMode,
        optimizationType: _optimizationType,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      // Navigasi ke halaman hasil rute
      AppRoutes.navigateToRouteResults(
        context,
        routes: routes,
        startLocation: _startLocation!,
        destinationLocation: _destinationLocation!,
        startName: _startController.text,
        destinationName: _destinationController.text,
      );
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error mencari rute: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
  
  void _fitRoutesToMap() {
    if (_routes.isEmpty) return;
    
    // Collect all coordinates from all routes
    List<LatLng> allPoints = [];
    for (var route in _routes) {
      allPoints.addAll(route.path);
    }
    
    // Find bounds
    double minLat = allPoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = allPoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = allPoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = allPoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    
    // Add padding
    minLat -= 0.005;
    maxLat += 0.005;
    minLng -= 0.005;
    maxLng += 0.005;
    
    // Updated to use proper fitBounds method
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
  
  void _selectStartLocation() async {
    // Tampilkan dialog pencarian lokasi
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pilih Lokasi Awal'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: LocationSearchWidget(
              onLocationSelected: (location) {
                setState(() {
                  _startLocation = location.latLng;
                  _startController.text = location.name;
                });
                Navigator.pop(context);
              },
              hintText: 'Cari lokasi awal...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Gunakan lokasi saat ini
                setState(() {
                  _startLocation = _currentLocation;
                  _startController.text = 'Lokasi Saat Ini';
                });
                Navigator.pop(context);
              },
              child: Text('Gunakan Lokasi Saat Ini'),
            ),
          ],
        );
      },
    );
  }
  
  void _selectDestinationLocation() async {
    // Tampilkan dialog pencarian lokasi
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pilih Lokasi Tujuan'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: LocationSearchWidget(
              onLocationSelected: (location) {
                setState(() {
                  _destinationLocation = location.latLng;
                  _destinationController.text = location.name;
                });
                Navigator.pop(context);
              },
              hintText: 'Cari lokasi tujuan...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perencanaan Rute'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: _hasRoutes ? 3 : 2,
            child: _buildMap(),
          ),
          Expanded(
            flex: _hasRoutes ? 4 : 5,
            child: _hasRoutes ? _buildRouteOptions() : _buildRoutePlanner(),
          ),
        ],
      ),
     bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }
  
  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.arunika',
          tileProvider: NetworkTileProvider(),
        ),
        MarkerLayer(
          markers: [
            if (_startLocation != null)
              Marker(
                point: _startLocation!,
                width: 40,
                height: 40,
                child: Icon(
                  Icons.trip_origin,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
            if (_destinationLocation != null)
              Marker(
                point: _destinationLocation!,
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
        if (_hasRoutes)
          PolylineLayer(
            polylines: _routes.map((route) {
              Color color;
              if (route.type == 'lowest_exposure') {
                color = AppColors.success;
              } else if (route.type == 'fastest') {
                color = AppColors.secondary;
              } else {
                color = AppColors.tertiary;
              }
              
              return Polyline(
                points: route.path,
                strokeWidth: 4.0,
                color: color,
              );
            }).toList(),
          ),
      ],
    );
  }
  
  Widget _buildRoutePlanner() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perencanaan Rute',
              style: TextStyle(
                fontSize: AppDimensions.heading3,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppDimensions.spacing4),
            Text(
              'Dari:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.gray70,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            TextFormField(
              controller: _startController,
              decoration: InputDecoration(
                hintText: 'Pilih titik awal',
                suffixIcon: Icon(Icons.my_location),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
              readOnly: true,
              onTap: _selectStartLocation,
            ),
            SizedBox(height: AppDimensions.spacing4),
            Text(
              'Ke:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.gray70,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            TextFormField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: 'Pilih tujuan',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
              readOnly: true,
              onTap: _selectDestinationLocation,
            ),
            
            SizedBox(height: AppDimensions.spacing4),
            Text(
              'Mode:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.gray70,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeButton('walking', Icons.directions_walk, 'Jalan Kaki'),
                _buildModeButton('cycling', Icons.directions_bike, 'Sepeda'),
                _buildModeButton('driving', Icons.directions_car, 'Berkendara'),
              ],
            ),
            SizedBox(height: AppDimensions.spacing4),
            Text(
              'Optimasi untuk:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.gray70,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            RadioListTile<String>(
              title: Text('Paparan Terendah'),
              subtitle: Text('Rute dengan paparan polusi minimal'),
              value: 'lowestExposure',
              groupValue: _optimizationType,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _optimizationType = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Waktu Tercepat'),
              subtitle: Text('Rute tercepat ke tujuan'),
              value: 'shortestTime',
              groupValue: _optimizationType,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _optimizationType = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Seimbang'),
              subtitle: Text('Keseimbangan antara paparan dan waktu'),
              value: 'balanced',
              groupValue: _optimizationType,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _optimizationType = value!;
                });
              },
            ),
            SizedBox(height: AppDimensions.spacing4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _findRoutes,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing4),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text('CARI RUTE'),
              ),
            ),
            SizedBox(height: AppDimensions.spacing4),
            Text(
              'Rute Terbaru:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.gray70,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            _buildRecentRouteCard(
              'Rumah → Kampus UGM',
              '3.2 km | AQI 58',
              Icons.home,
            ),
            _buildRecentRouteCard(
              'Rumah → Malioboro Mall',
              '1.5 km | AQI 75',
              Icons.shopping_bag,
            ),
          ],
        ),
      ).animate().fade().slideY(begin: 0.1, end: 0),
    );
  }
  
  Widget _buildModeButton(String mode, IconData icon, String label) {
    final bool isSelected = _transportMode == mode;
    
    return InkWell(
      onTap: () {
        setState(() {
          _transportMode = mode;
        });
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        padding: EdgeInsets.symmetric(
          vertical: AppDimensions.spacing3,
          horizontal: AppDimensions.spacing2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray30,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.gray60,
              size: 28,
            ),
            SizedBox(height: AppDimensions.spacing1),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.gray70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: AppDimensions.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentRouteCard(String title, String subtitle, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.spacing2),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // Load this route
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fitur ini akan tersedia segera!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRouteOptions() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
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
                    '${_startController.text} → ${_destinationController.text}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _hasRoutes = false;
                    });
                  },
                  child: Text('Ubah'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                final route = _routes[index];
                return _buildRouteCard(route, index);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRouteCard(OptimizedRoute route, int index) {
    final isHealthiest = route.type == 'lowest_exposure';
    final isFastest = route.type == 'fastest';
    
    Color routeColor;
    String routeTitle;
    IconData routeIcon;
    
    if (isHealthiest) {
      routeColor = AppColors.success;
      routeTitle = 'RUTE TERSEHAT';
      routeIcon = Icons.favorite;
    } else if (isFastest) {
      routeColor = AppColors.secondary;
      routeTitle = 'RUTE TERCEPAT';
      routeIcon = Icons.speed;
    } else {
      routeColor = AppColors.tertiary;
      routeTitle = 'RUTE SEIMBANG';
      routeIcon = Icons.balance;
    }
    
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing4,
        vertical: AppDimensions.spacing2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: routeColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: AppDimensions.spacing2,
              horizontal: AppDimensions.spacing4,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: routeColor.withOpacity(0.1),
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
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacing4),
            child: Column(
              children: [
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
                if (isHealthiest && _routes.length > 1)
                  Container(
                    margin: EdgeInsets.only(top: AppDimensions.spacing3),
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.spacing2,
                      horizontal: AppDimensions.spacing3,
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
                          '38% paparan lebih rendah',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimensions.small,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: AppDimensions.spacing3),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Show details
                        },
                        icon: Icon(Icons.info_outline),
                        label: Text('Detail'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacing3),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Start navigation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Memulai navigasi...'),
                              backgroundColor: AppColors.success,
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
    ).animate().fade().scale(delay: Duration(milliseconds: 100 * index));
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