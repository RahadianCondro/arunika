// lib/features/maps/favorite_locations_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/location.dart';
import '../../data/repositories/location_repository.dart';
import '../../routes.dart';

class FavoriteLocationsScreen extends StatefulWidget {
  const FavoriteLocationsScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteLocationsScreen> createState() => _FavoriteLocationsScreenState();
}

class _FavoriteLocationsScreenState extends State<FavoriteLocationsScreen> {
  final LocationRepository _locationRepository = LocationRepository();
  late Future<List<Location>> _favoriteLocationsFuture;
  final MapController _mapController = MapController();
  Location? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _favoriteLocationsFuture = _locationRepository.getFavoriteLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lokasi Favorit',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddLocationDialog(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Location>>(
        future: _favoriteLocationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat lokasi favorit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _favoriteLocationsFuture = _locationRepository.getFavoriteLocations();
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 80,
                    color: AppColors.gray40,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Belum ada lokasi favorit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tambahkan lokasi favorit untuk akses cepat dan pemantauan kualitas udara',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.gray60,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddLocationDialog(context);
                    },
                    icon: const Icon(Icons.add_location),
                    label: const Text('Tambah Lokasi'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing4,
                        vertical: AppDimensions.spacing3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final locations = snapshot.data!;
          return Column(
            children: [
              // Map preview
              Expanded(
                flex: 1,
                child: _buildMapPreview(locations),
              ),
              // Location list
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: _buildLocationsList(locations),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Karena ini related dengan Map tab
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, AppRoutes.dashboard);
          } else if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.map);
          } else if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.routePlanning);
          } else {
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

  Widget _buildMapPreview(List<Location> locations) {
    // Default ke lokasi pertama jika ada dan tidak ada lokasi terpilih
    if (_selectedLocation == null && locations.isNotEmpty) {
      _selectedLocation = locations.first;
    }

    // Default ke Yogyakarta jika tidak ada lokasi
    final LatLng center = _selectedLocation?.latLng ?? LatLng(-7.797068, 110.370529);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.yourcompany.arunika',
          tileProvider: NetworkTileProvider(),
        ),
        MarkerLayer(
          markers: locations.map((location) {
            final bool isSelected = _selectedLocation?.id == location.id;
            
return Marker(
  point: location.latLng,
  width: isSelected ? 120 : 40, // Much wider to accommodate text
  height: isSelected ? 80 : 40,  // Taller to accommodate text underneath
  alignment: isSelected ? Alignment.topCenter : Alignment.center, // This alignment is important
  child: GestureDetector(
    onTap: () {
      setState(() {
        _selectedLocation = location;
      });
      
      _mapController.move(location.latLng, 15);
    },
    child: isSelected
      ? Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start, // Align to top
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 40,
            ),
            const SizedBox(height: 2), // Small spacing
            Container(
              constraints: BoxConstraints(maxWidth: 100), // Control text container width
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing2,
                vertical: 2, // Smaller vertical padding
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                location.name,
                style: TextStyle(
                  fontSize: 9, // Smaller font size
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
      : Icon(
          Icons.location_on_outlined,
          color: AppColors.gray60,
          size: 30,
        ),
  ),
);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationsList(List<Location> locations) {
    return ListView.separated(
      padding: EdgeInsets.all(AppDimensions.spacing4),
      itemCount: locations.length + 1, // +1 for add button
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        if (index == locations.length) {
          // Add button at the end
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_location_alt,
                color: AppColors.primary,
              ),
            ),
            title: const Text('Tambah Lokasi Baru'),
            onTap: () {
              _showAddLocationDialog(context);
            },
          ).animate().fade().slideX(begin: 0.05, end: 0);
        }

        final location = locations[index];
        final bool isSelected = _selectedLocation?.id == location.id;

        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.gray20,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: isSelected ? AppColors.primary : AppColors.gray60,
            ),
          ),
          title: Text(
            location.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(location.address),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showLocationOptions(context, location);
            },
          ),
          onTap: () {
            setState(() {
              _selectedLocation = location;
            });
            
            _mapController.move(location.latLng, 15);
          },
          selected: isSelected,
          selectedTileColor: AppColors.primary.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
        ).animate().fade().slideX(begin: 0.05, end: 0, delay: Duration(milliseconds: 50 * index));
      },
    );
  }

  void _showLocationOptions(BuildContext context, Location location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Lihat di Peta'),
                onTap: () {
                  Navigator.pop(context);
                  
                  // Navigate to map screen with this location
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.map,
                    arguments: location,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.route),
                title: const Text('Rute ke Lokasi Ini'),
                onTap: () {
                  Navigator.pop(context);
                  
                  // Navigate to route planning with this location as destination
                  Navigator.pushNamed(
                    context,
                    AppRoutes.routePlanning,
                    arguments: {'destination': location},
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Lokasi'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditLocationDialog(context, location);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.danger),
                title: Text(
                  'Hapus dari Favorit',
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, location);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddLocationDialog(BuildContext context) {
    // Implementasi dialog untuk menambah lokasi
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Lokasi Favorit'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: LocationSearchWidget(
                    onLocationSelected: (location) {
                      Navigator.pop(context);
                      // Simulasi penambahan ke favorit
                      _locationRepository.saveFavoriteLocation(location).then((_) {
                        setState(() {
                          _favoriteLocationsFuture = _locationRepository.getFavoriteLocations();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${location.name} ditambahkan ke favorit'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      });
                    },
                    hintText: 'Cari lokasi untuk ditambahkan...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _showEditLocationDialog(BuildContext context, Location location) {
    // Implementasi dialog untuk edit lokasi
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Lokasi'),
          content: const Text(
            'Fitur ini akan segera tersedia pada update berikutnya.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Location location) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Lokasi'),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${location.name}" dari lokasi favorit?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implementasi hapus lokasi
                _deleteLocation(location);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
  
  void _deleteLocation(Location location) {
    // Simulasi penghapusan lokasi
    // Dalam aplikasi sebenarnya, ini akan memanggil repository untuk menghapus lokasi
    setState(() {
      _favoriteLocationsFuture = _favoriteLocationsFuture.then((locations) {
        final updatedLocations = locations.where((loc) => loc.id != location.id).toList();
        if (updatedLocations.isEmpty) {
          _selectedLocation = null;
        } else if (_selectedLocation?.id == location.id) {
          _selectedLocation = updatedLocations.first;
        }
        return updatedLocations;
      });
    });
    
    // Tampilkan snackbar konfirmasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${location.name} telah dihapus dari lokasi favorit'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () {
            // Implementasi undo
            setState(() {
              _favoriteLocationsFuture = _favoriteLocationsFuture.then((locations) {
                final updatedLocations = List<Location>.from(locations)..add(location);
                return updatedLocations;
              });
            });
          },
        ),
      ),
    );
  }
}

// Tambahkan widget LocationSearchWidget di file terpisah:
// lib/features/maps/widgets/location_search_widget.dart
class LocationSearchWidget extends StatefulWidget {
  final Function(Location) onLocationSelected;
  final String hintText;

  const LocationSearchWidget({
    Key? key,
    required this.onLocationSelected,
    this.hintText = 'Cari lokasi...',
  }) : super(key: key);

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final LocationRepository _locationRepository = LocationRepository();
  List<Location> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await _locationRepository.searchLocations(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mencari lokasi: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search input
        Container(
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
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                        _hasSearched = false;
                      });
                    },
                  )
                : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: AppDimensions.spacing2,
                horizontal: AppDimensions.spacing3,
              ),
            ),
            onChanged: (value) {
              // Gunakan debounce untuk menghindari terlalu banyak API call
              Future.delayed(const Duration(milliseconds: 500), () {
                if (value == _searchController.text) {
                  _searchLocation(value);
                }
              });
            },
          ),
        ),
        
        // Results list
        if (_isLoading)
          Container(
            margin: EdgeInsets.only(top: AppDimensions.spacing3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_hasSearched && _searchResults.isEmpty)
          Container(
            margin: EdgeInsets.only(top: AppDimensions.spacing3),
            padding: EdgeInsets.all(AppDimensions.spacing4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: const Center(
              child: Text(
                'Tidak ditemukan hasil. Coba kata kunci lain.',
                style: TextStyle(color: AppColors.gray60),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (_searchResults.isNotEmpty)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: AppDimensions.spacing2),
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
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: AppColors.gray20,
                ),
                itemBuilder: (context, index) {
                  final location = _searchResults[index];
                  return ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                    ),
                    title: Text(location.name),
                    subtitle: Text(location.address),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing4,
                      vertical: AppDimensions.spacing1,
                    ),
                    onTap: () {
                      widget.onLocationSelected(location);
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                        _hasSearched = false;
                      });
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}