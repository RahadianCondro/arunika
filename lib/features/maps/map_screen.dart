// lib/features/maps/map_screen.dart - PART 1: Main Class and Core Structure
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/skeleton_loading.dart';
import '../../data/models/air_quality.dart';
import '../../data/models/map_data.dart';
import '../../data/repositories/air_quality_repository.dart';
import '../../data/repositories/map_repository.dart';
import 'map_controller.dart'; // This now imports AqiMapController
import '../../routes.dart';
import '../../core/widgets/app_bottom_navigation_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  // This is the flutter_map MapController, distinct from our AqiMapController
  late final MapController _mapController;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    // Request location permission here if needed
    
    // Load data - using AqiMapController from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AqiMapController>().loadData();
    });
  }
  
@override
Widget build(BuildContext context) {
  return Consumer<AqiMapController>(
    builder: (context, controller, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Peta Kualitas Udara'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildMapControlPanel(controller),
            Expanded(
              child: Stack(
                children: [
                  _buildMap(controller),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: _buildMapControls(),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: _buildLegend(),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
      );
    },
  );
}
  
  Widget _buildMapControlPanel(AqiMapController controller) { // Changed type from MapController to AqiMapController
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing4,
        vertical: AppDimensions.spacing3,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Air Quality Map',
            style: TextStyle(
              fontSize: AppDimensions.heading3,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.spacing2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('AQI', 'AQI', controller),
                SizedBox(width: AppDimensions.spacing2),
                _buildFilterChip('PM2_5', 'PM2.5', controller),
                SizedBox(width: AppDimensions.spacing2),
                _buildFilterChip('PM10', 'PM10', controller),
                SizedBox(width: AppDimensions.spacing2),
                _buildFilterChip('O3', 'Ozone', controller),
                SizedBox(width: AppDimensions.spacing2),
                _buildFilterChip('NO2', 'NO₂', controller),
              ],
            ),
          ),
          Wrap(
            spacing: AppDimensions.spacing2,
            runSpacing: AppDimensions.spacing2,
            children: [
              _buildToggleChip(
                'Stations', 
                controller.showStations, 
                (value) => controller.toggleStations(value),
              ),
              _buildToggleChip(
                'Heatmap', 
                controller.showHeatmap, 
                (value) => controller.toggleHeatmap(value),
              ),
              _buildToggleChip(
                'Hotspots', 
                controller.showHotspots, 
                (value) => controller.toggleHotspots(value),
              ),
              _buildToggleChip(
                'Safe Zones', 
                controller.showSafeZones, 
                (value) => controller.toggleSafeZones(value),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade().slideY(begin: -0.2, end: 0);
  }
  
  Widget _buildFilterChip(String value, String label, AqiMapController controller) { // Changed type
    final bool isSelected = controller.selectedPollutant == value;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.selectPollutant(value);
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  
  Widget _buildToggleChip(String label, bool isSelected, Function(bool) onToggle) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onToggle,
      selectedColor: AppColors.primary.withOpacity(0.2),
      backgroundColor: Colors.grey[200],
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  // lib/features/maps/map_screen.dart - PART 2: Map Layers and Controls
  Widget _buildMap(AqiMapController controller) {
  if (controller.isLoading) {
    return Center(child: CircularProgressIndicator(color: AppColors.primary));
  }
  
  final mapPoints = controller.mapPoints;
  final stations = controller.stations;
  
  return FlutterMap(
    mapController: _mapController,
    options: MapOptions(
      initialCenter: controller.center,
      initialZoom: controller.initialZoom,
      maxZoom: 18.0,
      minZoom: 10.0,
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.yourcompany.arunika',
        tileProvider: NetworkTileProvider(),
      ),
      if (controller.showHeatmap)
        _buildHeatmapLayer(mapPoints, controller),
      if (controller.showStations)
        _buildStationsLayer(stations, controller),
      if (controller.showHotspots)
        _buildHotspotsLayer(),
      if (controller.showSafeZones)
        _buildSafeZonesLayer(),
    ],
  );
}
  
// Find the _buildHeatmapLayer function in your code and replace it with this updated version
Widget _buildHeatmapLayer(List<AqiMapPoint> mapPoints, AqiMapController controller) {
  // Updated to use the correct MarkerLayer syntax
  return MarkerLayer(
    markers: mapPoints.map((point) {
      return Marker(
        point: LatLng(point.lat, point.lon),
        width: 30,
        height: 30,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: controller.getAqiColor(point.aqi).withOpacity(0.7),
          ),
        ),
      );
    }).toList(),
  );
}

// Also check and update _buildStationsLayer function
Widget _buildStationsLayer(List<MonitoringStation> stations, AqiMapController controller) {
  return MarkerLayer(
    markers: stations.map((station) {
      return Marker(
        point: station.latLng,
        width: 60,
        height: 60,
        child: FittedBox(  // Tambahkan FittedBox di sini untuk memastikan konten muat
          fit: BoxFit.scaleDown,
          child: GestureDetector(
            onTap: () => _showStationDetails(station),
            child: Column(
              mainAxisSize: MainAxisSize.min,  // Pastikan Column menggunakan ukuran minimum
              children: [
                Container(
                  padding: EdgeInsets.all(2),  // Kurangi padding dari 4 ke 2
                  decoration: BoxDecoration(
                    color: controller.getAqiColor(station.aqi),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),  // Kurangi border width dari 2 ke 1
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),  // Kurangi opacity dari 0.2 ke 0.1
                        blurRadius: 2,  // Kurangi blur radius dari 4 ke 2
                        offset: const Offset(0, 1),  // Kurangi offset dari (0, 2) ke (0, 1)
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      station.aqi.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,  // Kurangi ukuran font dari 12 ke 10
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1),  // Kurangi jarak vertikal
                if (station.name.isNotEmpty)  // Hanya tampilkan label jika nama tidak kosong
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),  // Kurangi padding
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),  // Kurangi radius dari 4 ke 2
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),  // Kurangi opacity
                          blurRadius: 1,  // Kurangi blur radius
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      station.name.split(' ')[0],  // Ambil kata pertama saja
                      style: TextStyle(
                        fontSize: 8,  // Kurangi ukuran font dari 10 ke 8
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}

// Also update _buildHotspotsLayer and _buildSafeZonesLayer
Widget _buildHotspotsLayer() {
  // Placeholder for hotspots layer
  return MarkerLayer(
    markers: [
      Marker(
        point: LatLng(-7.790000, 110.380000), // East Ringroad Junction
        width: 80,
        height: 80,
        child: FittedBox(  // Tambahkan FittedBox
          fit: BoxFit.contain,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.3),
              border: Border.all(
                color: Colors.red,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
      Marker(
        point: LatLng(-7.801500, 110.364800), // Central Bus Terminal
        width: 70,
        height: 70,
        child: FittedBox(  // Tambahkan FittedBox
          fit: BoxFit.contain,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.3),
              border: Border.all(
                color: Colors.red,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildSafeZonesLayer() {
  // Placeholder for safe zones layer
  return MarkerLayer(
    markers: [
      Marker(
        point: LatLng(-7.765000, 110.345000), // Prambanan Temple Area
        width: 120,
        height: 120,
        child: FittedBox(  // Tambahkan FittedBox
          fit: BoxFit.contain,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.2),
              border: Border.all(
                color: Colors.green,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
      Marker(
        point: LatLng(-7.775800, 110.355600), // City Forest Park
        width: 90,
        height: 90,
        child: FittedBox(  // Tambahkan FittedBox
          fit: BoxFit.contain,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.2),
              border: Border.all(
                color: Colors.green,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
  
  Widget _buildMapControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
      SizedBox(height: AppDimensions.spacing2),
      FloatingActionButton(
        heroTag: 'favorites',
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        child: Icon(Icons.bookmark),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.favoriteLocations);
        },
      ),
        FloatingActionButton(
          heroTag: 'zoomIn',
          mini: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          child: Icon(Icons.add),
          onPressed: () {
            // Updated to use the correct API
            final currentZoom = _mapController.camera.zoom;
            _mapController.move(
              _mapController.camera.center,
              currentZoom + 1.0
            );
          },
        ),
        SizedBox(height: AppDimensions.spacing2),
        FloatingActionButton(
          heroTag: 'zoomOut',
          mini: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          child: Icon(Icons.remove),
          onPressed: () {
            // Updated to use the correct API
            final currentZoom = _mapController.camera.zoom;
            _mapController.move(
              _mapController.camera.center,
              currentZoom - 1.0
            );
          },
        ),
        SizedBox(height: AppDimensions.spacing2),
        FloatingActionButton(
          heroTag: 'locate',
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          child: Icon(Icons.my_location),
          onPressed: () {
            // In a real app, this would get the user's current location
            _mapController.move(
              context.read<AqiMapController>().center, // Changed to AqiMapController
              context.read<AqiMapController>().initialZoom
            );
          },
        ),

      ],
    ).animate().fade().slideX(begin: 1, end: 0);
  }
  
  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacing3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AQI Legend',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.small,
            ),
          ),
          SizedBox(height: AppDimensions.spacing2),
          _buildLegendItem('Good (0-50)', AppColors.aqiGood),
          SizedBox(height: AppDimensions.spacing1),
          _buildLegendItem('Moderate (51-100)', AppColors.aqiModerate),
          SizedBox(height: AppDimensions.spacing1),
          _buildLegendItem('Unhealthy for Sensitive (101-150)', AppColors.aqiUnhealthySensitive),
          SizedBox(height: AppDimensions.spacing1),
          _buildLegendItem('Unhealthy (151-200)', AppColors.aqiUnhealthy),
          SizedBox(height: AppDimensions.spacing1),
          _buildLegendItem('Very Unhealthy (201-300)', AppColors.aqiVeryUnhealthy),
          SizedBox(height: AppDimensions.spacing1),
          _buildLegendItem('Hazardous (301+)', AppColors.aqiHazardous),
        ],
      ),
    ).animate().fade().slideX(begin: -1, end: 0);
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppDimensions.spacing2),
        Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.caption,
          ),
        ),
      ],
    );
  }
// lib/features/maps/map_screen.dart - PART 3: Station Details and Supporting Methods
  void _showStationDetails(MonitoringStation station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildStationDetailsSheet(station),
    );
  }
  
  Widget _buildStationDetailsSheet(MonitoringStation station) {
    // Use Consumer to get the AqiMapController
    return Consumer<AqiMapController>( // Changed from MapController to AqiMapController
      builder: (context, controller, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
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
              // Station header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppDimensions.spacing2),
                      decoration: BoxDecoration(
                        color: controller.getAqiColor(station.aqi).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sensors,
                        color: controller.getAqiColor(station.aqi),
                        size: 28,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacing3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.name,
                            style: TextStyle(
                              fontSize: AppDimensions.heading3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Monitoring Station',
                            style: TextStyle(
                              fontSize: AppDimensions.small,
                              color: AppColors.gray60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing3,
                        vertical: AppDimensions.spacing1,
                      ),
                      decoration: BoxDecoration(
                        color: controller.getAqiColor(station.aqi).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                        border: Border.all(
                          color: controller.getAqiColor(station.aqi),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'AQI: ${station.aqi}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: controller.getAqiColor(station.aqi),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spacing4),
              // Mini map
              Container(
                height: 150,
                margin: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.gray30),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: station.latLng,
                      initialZoom: 15.0,
                      interactiveFlags: InteractiveFlag.none,
                    ),
                    children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      // Remove the subdomains parameter completely
                      userAgentPackageName: 'com.yourcompany.arunika', // Add your actual package name
                    ),
                      MarkerLayer(
                      markers: [
                        Marker(
                          point: station.latLng,
                          width: 30,
                          height: 30,
                          child: FittedBox(  // Tambahkan FittedBox
                            fit: BoxFit.contain,
                            child: Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spacing4),
              // Pollutant readings
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                child: Text(
                  'Pollutant Readings',
                  style: TextStyle(
                    fontSize: AppDimensions.heading4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spacing3),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                  child: ListView(
                    children: [
                      if (station.pollutants.containsKey('PM2_5'))
                        _buildPollutantItem('PM2.5', station.pollutants['PM2_5']!, 'µg/m³', 35.0),
                      if (station.pollutants.containsKey('PM10'))
                        _buildPollutantItem('PM10', station.pollutants['PM10']!, 'µg/m³', 150.0),
                      if (station.pollutants.containsKey('O3'))
                        _buildPollutantItem('Ozone (O₃)', station.pollutants['O3']!, 'µg/m³', 180.0),
                      if (station.pollutants.containsKey('NO2'))
                        _buildPollutantItem('Nitrogen Dioxide (NO₂)', station.pollutants['NO2']!, 'µg/m³', 200.0),
                      if (station.pollutants.containsKey('SO2'))
                        _buildPollutantItem('Sulfur Dioxide (SO₂)', station.pollutants['SO2']!, 'µg/m³', 350.0),
                      if (station.pollutants.containsKey('CO'))
                        _buildPollutantItem('Carbon Monoxide (CO)', station.pollutants['CO']!, 'mg/m³', 10.0),
                    ],
                  ),
                ),
              ),
// Action buttons
              Padding(
                padding: EdgeInsets.all(AppDimensions.spacing4),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.history),
                        label: Text('View History'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacing3),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Save this location
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Location saved to favorites'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        icon: Icon(Icons.bookmark_add),
                        label: Text('Save Location'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPollutantItem(String name, double value, String unit, double max) {
    // Calculate percentage for progress bar (capped at 100%)
    final percentage = (value / max * 100).clamp(0, 100);
    
    // Determine status color based on percentage
    Color statusColor;
    String statusText;
    
    if (percentage <= 50) {
      statusColor = AppColors.aqiGood;
      statusText = 'Good';
    } else if (percentage <= 100) {
      statusColor = AppColors.aqiModerate;
      statusText = 'Moderate';
    } else if (percentage <= 150) {
      statusColor = AppColors.aqiUnhealthySensitive;
      statusText = 'Unhealthy for Sensitive';
    } else {
      statusColor = AppColors.aqiUnhealthy;
      statusText = 'Unhealthy';
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacing3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$value $unit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing1),
          Stack(
            children: [
              // Background
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.gray20,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
              // Progress
              Container(
                height: 8,
                width: MediaQuery.of(context).size.width * (percentage / 100) * 0.8, // 80% of width
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: AppDimensions.caption,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'WHO limit: $max $unit',
                style: TextStyle(
                  color: AppColors.gray60,
                  fontSize: AppDimensions.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}