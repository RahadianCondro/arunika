// lib/features/maps/widgets/location_search_widget.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/location.dart';
import '../../../data/repositories/location_repository.dart';

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