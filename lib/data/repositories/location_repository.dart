// lib/data/repositories/location_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/location.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart'; // Tambahkan import ini untuk LatLng

class LocationRepository {
  // Ini adalah mock repository. Dalam aplikasi sebenarnya, kita akan menggunakan
  // API seperti Google Places API untuk pencarian lokasi

  // Cache hasil pencarian sebelumnya untuk mengurangi API calls
  final Map<String, List<Location>> _searchCache = {};

  // Fungsi ini mensimulasikan pencarian lokasi
  Future<List<Location>> searchLocations(String query) async {
    // Check cache dulu
    if (_searchCache.containsKey(query)) {
      return _searchCache[query]!;
    }

    // Pada aplikasi sebenarnya, kita akan memanggil API di sini
    // Untuk contoh, kita akan mensimulasikan delay network
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulasi respons API dengan data dummy
    final List<Location> results = await _getMockLocations(query);
    
    // Simpan ke cache
    _searchCache[query] = results;
    
    return results;
  }

  // Mendapatkan data mock untuk simulasi
  Future<List<Location>> _getMockLocations(String query) async {
    try {
      // Baca data JSON mock dari aset
      final String jsonData = await rootBundle.loadString('assets/mock_data/locations.json');
      final List<dynamic> data = json.decode(jsonData);
      
      // Filter berdasarkan query
      final filteredData = data.where((location) {
        final name = location['name'].toString().toLowerCase();
        final address = location['address'].toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        
        return name.contains(searchQuery) || address.contains(searchQuery);
      }).toList();
      
      // Convert ke List<Location>
      return filteredData.map((json) => Location.fromJson(json)).toList();
    } catch (e) {
      // Jika file tidak ada, gunakan data hardcoded untuk contoh
      if (query.toLowerCase().contains('mall')) {
        return [
          Location(
            id: 'loc1',
            name: 'Malioboro Mall',
            address: 'Jl. Malioboro No. 52-58, Yogyakarta',
            latLng: LatLng(-7.7956, 110.3695),
          ),
          Location(
            id: 'loc2',
            name: 'Ambarrukmo Plaza',
            address: 'Jl. Laksda Adisucipto, Yogyakarta',
            latLng: LatLng(-7.7827, 110.4021),
          ),
        ];
      } else if (query.toLowerCase().contains('campus') || query.toLowerCase().contains('kampus')) {
        return [
          Location(
            id: 'loc3',
            name: 'UGM Campus',
            address: 'Bulaksumur, Yogyakarta',
            latLng: LatLng(-7.7713, 110.3774),
          ),
          Location(
            id: 'loc4',
            name: 'UNY Campus',
            address: 'Jl. Colombo, Yogyakarta',
            latLng: LatLng(-7.7742, 110.3871),
          ),
        ];
      } else {
        return [
          Location(
            id: 'loc5',
            name: 'Tugu Yogyakarta',
            address: 'Jl. Jenderal Sudirman, Yogyakarta',
            latLng: LatLng(-7.7830, 110.3670),
          ),
          Location(
            id: 'loc6',
            name: 'Keraton Yogyakarta',
            address: 'Jl. Rotowijayan Blok No. 1, Yogyakarta',
            latLng: LatLng(-7.8050, 110.3640),
          ),
        ];
      }
    }
  }

  // Menyimpan lokasi favorit
  Future<void> saveFavoriteLocation(Location location) async {
    // Pada implementasi sebenarnya, kita akan menyimpan ke database lokal atau cloud
    // Untuk contoh ini, kita hanya mensimulasikan dengan delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Di sini akan ada kode untuk menyimpan lokasi ke storage persistent
    print('Lokasi disimpan: ${location.name}');
  }

  // Mendapatkan lokasi favorit
  Future<List<Location>> getFavoriteLocations() async {
    // Pada implementasi sebenarnya, kita akan mengambil dari database lokal atau cloud
    // Untuk contoh ini, kita mengembalikan data dummy
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Location(
        id: 'fav1',
        name: 'Rumah',
        address: 'Jl. Kaliurang Km 7, Yogyakarta',
        latLng: LatLng(-7.7450, 110.3780),
      ),
      Location(
        id: 'fav2',
        name: 'Kantor',
        address: 'Jl. Affandi No. 23, Yogyakarta',
        latLng: LatLng(-7.7680, 110.3880),
      ),
      Location(
        id: 'fav3',
        name: 'Kampus',
        address: 'Bulaksumur, Yogyakarta',
        latLng: LatLng(-7.7713, 110.3774),
      ),
    ];
  }
}