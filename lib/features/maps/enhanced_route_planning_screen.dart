// lib/features/maps/enhanced_route_planning_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_bottom_navigation_bar.dart';
import '../../core/widgets/route_recommendation_card.dart';
// Update the import path for LocationSearchWidget
import '../../core/widgets/location_search_widget.dart'; // This is the correct path
import '../../data/models/location.dart';
import '../../data/models/route.dart';
import '../../data/models/health_profile.dart';
import '../../data/repositories/route_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/health_repository.dart';
import '../../routes.dart';

class EnhancedRoutePlanningScreen extends StatefulWidget {
  const EnhancedRoutePlanningScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedRoutePlanningScreen> createState() => _EnhancedRoutePlanningScreenState();
}

class _EnhancedRoutePlanningScreenState extends State<EnhancedRoutePlanningScreen> {
  final RouteRepository _routeRepository = RouteRepository();
  final LocationRepository _locationRepository = LocationRepository();
  final HealthRepository _healthRepository = HealthRepository();
  
  bool _isLoading = false;
  bool _hasRoutes = false;
  List<OptimizedRoute> _routes = [];
  late HealthProfile _healthProfile;
  
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
  
  // Health-specific options
  bool _avoidSteepInclines = false;
  bool _preferShadedRoutes = false;
  bool _avoidHighTrafficAreas = true;
  bool _considerHealthSensitivities = true;
  
  late final MapController _mapController;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _startLocation = _currentLocation;
    _startController.text = 'Lokasi Saat Ini';
    
    // Load health profile
    _loadHealthProfile();
    
    // Check if there are arguments from navigation
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
  
  Future<void> _loadHealthProfile() async {
    try {
      _healthProfile = await _healthRepository.getHealthProfile();
      
      // Adjust settings based on health profile
      if (_healthProfile.healthConditions.any((condition) => 
          condition.toLowerCase().contains('asma') || 
          condition.toLowerCase().contains('paru'))) {
        setState(() {
          _avoidHighTrafficAreas = true;
          _considerHealthSensitivities = true;
        });
      }
      
      if (_healthProfile.activityLevel.toLowerCase() == 'rendah') {
        setState(() {
          _avoidSteepInclines = true;
        });
      }
    } catch (e) {
      // Fallback to default profile
      _healthProfile = HealthProfile.empty();
    }
  }
  
  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    _mapController.dispose();
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
      // Generate enhanced route options
      Map<String, dynamic> options = {
        'transportMode': _transportMode,
        'optimizationType': _optimizationType,
        'avoidSteepInclines': _avoidSteepInclines,
        'preferShadedRoutes': _preferShadedRoutes,
        'avoidHighTrafficAreas': _avoidHighTrafficAreas,
        'considerHealthSensitivities': _considerHealthSensitivities,
      };
      
      // Add health profile if considering sensitivities
      if (_considerHealthSensitivities) {
        options['healthConditions'] = _healthProfile.healthConditions;
        options['pollutantSensitivity'] = _healthProfile.pollutantSensitivity;
      }
      
      final routes = await _routeRepository.getEnhancedOptimizedRoutes(
        _startLocation!,
        _destinationLocation!,
        options: options,
      );
      
      setState(() {
        _isLoading = false;
        _hasRoutes = true;
        _routes = routes;
      });
      
      _fitRoutesToMap();
      
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
  
  void _selectStartLocation() async {
    // Show location search dialog
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
                // Use current location
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
    // Show location search dialog
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
            flex: _hasRoutes ? 2 : 1,
            child: _buildMap(),
          ),
          Expanded(
            flex: _hasRoutes ? 3 : 4,
            child: _hasRoutes ? _buildRouteResults() : _buildRoutePlanner(),
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
        // Start and destination markers
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
        // Route polylines for found routes
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
              'Mode Transportasi:',
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
            
            // Advanced health options
            SizedBox(height: AppDimensions.spacing4),
            ExpansionTile(
              title: Text(
                'Opsi Kesehatan Lanjutan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              children: [
                CheckboxListTile(
                  title: Text('Hindari jalan menanjak curam'),
                  subtitle: Text('Untuk kondisi kardiovaskular atau mobilitas terbatas'),
                  value: _avoidSteepInclines,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _avoidSteepInclines = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Utamakan rute teduh'),
                  subtitle: Text('Untuk mengurangi paparan sinar UV dan panas'),
                  value: _preferShadedRoutes,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _preferShadedRoutes = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Hindari area lalu lintas padat'),
                  subtitle: Text('Untuk mengurangi paparan polutan kendaraan'),
                  value: _avoidHighTrafficAreas,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _avoidHighTrafficAreas = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Sesuaikan dengan sensitivitas kesehatan'),
                  subtitle: Text('Optimasi berdasarkan kondisi kesehatan Anda'),
                  value: _considerHealthSensitivities,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _considerHealthSensitivities = value!;
                    });
                  },
                ),
              ],
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
          ],
        ),
      ).animate().fade().slideY(begin: 0.1, end: 0),
    );
  }
  
  Widget _buildRouteResults() {
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
                    overflow: TextOverflow.ellipsis,
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
              padding: EdgeInsets.all(AppDimensions.spacing3),
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                final route = _routes[index];
                
                // Generate health factors based on profile and route
                List<String> healthFactors = _generateHealthFactors(route);
                
                return RouteRecommendationCard(
                  title: _getRouteTitle(route.type),
                  description: _getRouteDescription(route),
                  routeInfo: {
                    'type': route.type,
                    'aqi_avg': route.exposure['aqi_avg'],
                    'distance': route.distance,
                    'duration': route.duration,
                  },
                  healthFactors: healthFactors,
                  onViewRoute: () {
                    // Navigate to route details screen
                    AppRoutes.navigateToRouteResults(
                      context, 
                      routes: [route],
                      startLocation: _startLocation!,
                      destinationLocation: _destinationLocation!,
                      startName: _startController.text,
                      destinationName: _destinationController.text,
                    );
                  },
                  onNavigate: () {
                    // Start navigation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Memulai navigasi...'),
                        backgroundColor: _getRouteColor(route.type),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
  
  List<String> _generateHealthFactors(OptimizedRoute route) {
    List<String> factors = [];
    
    // Add factors based on route type
    if (route.type == 'lowest_exposure') {
      factors.add('Mengurangi paparan polutan hingga ${_calculateExposureReduction(route)}% dibanding rute tercepat');
      
      // Add specific factors based on health conditions
      if (_healthProfile.healthConditions.any((condition) => condition.toLowerCase().contains('asma'))) {
        factors.add('Optimal untuk kondisi asma dengan menghindari area paparan PM2.5 tinggi');
      }
      if (_healthProfile.healthConditions.any((condition) => condition.toLowerCase().contains('alergi'))) {
        factors.add('Mengurangi kemungkinan pemicu alergi di sepanjang rute');
      }
    } else if (route.type == 'balanced') {
      factors.add('Mengurangi paparan polutan ${_calculateExposureReduction(route)}% dengan tambahan waktu minimal');
    }
    
    // Add factors based on health options
    if (_avoidSteepInclines && route.exposure.containsKey('incline_avoided')) {
      factors.add('Menghindari tanjakan curam untuk mengurangi beban kardiovaskular');
    }
    
    if (_preferShadedRoutes && route.exposure.containsKey('shade_percentage')) {
      int shadePercentage = (route.exposure['shade_percentage'] as double).toInt();
      factors.add('${shadePercentage}% rute berada di area teduh untuk mengurangi paparan panas');
    }
    
    if (_avoidHighTrafficAreas && route.exposure.containsKey('traffic_reduction')) {
      factors.add('Menghindari area lalu lintas padat untuk mengurangi paparan CO dan NOx');
    }
    
    return factors;
  }
  
  int _calculateExposureReduction(OptimizedRoute route) {
    // Find the "fastest" route to compare with
    OptimizedRoute? fastestRoute = _routes.firstWhere(
      (r) => r.type == 'fastest',
      orElse: () => route, // Default to same route if no "fastest" found
    );
    
    if (fastestRoute.type == route.type) {
      return 0; // Same route, no reduction
    }
    
    // Calculate the percentage reduction
    int fastestAqi = fastestRoute.exposure['aqi_avg'] as int;
    int currentAqi = route.exposure['aqi_avg'] as int;
    
    if (fastestAqi <= 0) return 0; // Avoid division by zero
    
    int reduction = ((fastestAqi - currentAqi) / fastestAqi * 100).round();
    return reduction > 0 ? reduction : 0; // Ensure non-negative
  }
  
  String _getRouteTitle(String type) {
    switch (type) {
      case 'lowest_exposure':
        return 'RUTE TERSEHAT';
      case 'fastest':
        return 'RUTE TERCEPAT';
      case 'balanced':
        return 'RUTE SEIMBANG';
      default:
        return 'RUTE UMUM';
    }
  }
  
  String _getRouteDescription(OptimizedRoute route) {
    switch (route.type) {
      case 'lowest_exposure':
        return 'Rute dengan paparan polutan minimal, dipersonalisasi untuk profil kesehatan Anda.';
      case 'fastest':
        return 'Rute tercepat ke tujuan dengan waktu tempuh minimum.';
      case 'balanced':
        return 'Rute dengan keseimbangan optimal antara paparan polutan dan waktu tempuh.';
      default:
        return 'Rute alternatif ke tujuan Anda.';
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
}