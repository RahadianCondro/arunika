// lib/data/repositories/health_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; // Add this import for Icons
import '../models/health_profile.dart';
import '../models/exposure_history.dart';
import '../models/recommendation.dart';
import 'package:latlong2/latlong.dart';

class HealthRepository {
  // Dalam implementasi sebenarnya, ini akan mengakses API
  // Untuk MVP, kita menggunakan data mock

  Future<HealthProfile> getHealthProfile() async {
    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Load mock data
    return HealthProfile(
      id: '1',
      name: 'Joko_Thingkir',
      age: 28,
      healthConditions: ['Asma Ringan', 'Rhinitis Alergi'],
      activityLevel: 'Tinggi',
      pollutantSensitivity: {
        'PM2_5': 4.0,
        'O3': 3.0,
        'NO2': 2.0,
        'SO2': 2.0,
      },
    );
  }

  Future<Map<String, dynamic>> getHealthStats() async {
    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Mock data untuk statistik kesehatan
    return {
      'weeklyAverageAQI': 68,
      'aqiTrend': 'Stabil',
      'dailyExposureHours': 8.5,
      'correlations': [
        {
          'description': 'Peningkatan gejala asma terdeteksi saat tingkat PM2.5 meningkat di atas 35 μg/m³.',
          'strength': 0.75,
          'icon': Icons.healing,
        },
        {
          'description': 'Paparan kualitas udara buruk di pagi hari berkorelasi dengan peningkatan iritasi mata.',
          'strength': 0.6,
          'icon': Icons.remove_red_eye,
        },
      ],
    };
  }

// lib/data/repositories/health_repository.dart (lanjutan)
Future<List<ExposureHistory>> getExposureHistory(
  DateTime startDate,
  DateTime endDate,
) async {
  // Simulasi network delay
  await Future.delayed(const Duration(milliseconds: 1200));
  
  // Mock data untuk exposure history
  return [
    ExposureHistory(
      date: '2025-05-01',
      averageAqi: 70,
      locations: [
        LocationExposure(
          name: 'Rumah',
          lat: -7.797068,  // Added lat coordinate
          lon: 110.370529, // Added lon coordinate
          aqi: 65, 
          duration: 12.0,
        ),
        LocationExposure(
          name: 'Kantor',
          lat: -7.782900,  // Added lat coordinate
          lon: 110.367032, // Added lon coordinate
          aqi: 78,
          duration: 8.5,
        ),
        LocationExposure(
          name: 'Commute',
          lat: -7.790000,  // Added lat coordinate
          lon: 110.368500, // Added lon coordinate
          aqi: 85,
          duration: 1.5,
        ),
      ],
      pollutants: {
        'PM2_5': PollutantExposure(
          average: 25.8,
          peak: 42.3,
        ),
        'PM10': PollutantExposure(
          average: 48.2,
          peak: 72.1,
        ),
        'O3': PollutantExposure(
          average: 65.3,
          peak: 95.7,
        ),
      },
    ),
    ExposureHistory(
      date: '2025-04-30',
      averageAqi: 68,
      locations: [
        LocationExposure(
          name: 'Rumah',
          lat: -7.797068,  // Added lat coordinate
          lon: 110.370529, // Added lon coordinate
          aqi: 62, 
          duration: 14.0,
        ),
        LocationExposure(
          name: 'Kantor',
          lat: -7.782900,  // Added lat coordinate
          lon: 110.367032, // Added lon coordinate
          aqi: 75,
          duration: 8.0,
        ),
        LocationExposure(
          name: 'Taman Kota',
          lat: -7.775000,  // Added lat coordinate
          lon: 110.375000, // Added lon coordinate
          aqi: 55,
          duration: 2.0,
        ),
      ],
      pollutants: {
        'PM2_5': PollutantExposure(
          average: 23.1,
          peak: 38.5,
        ),
        'PM10': PollutantExposure(
          average: 45.6,
          peak: 68.2,
        ),
        'O3': PollutantExposure(
          average: 60.8,
          peak: 80.3,
        ),
      },
    ),
  ];
}

  Future<Map<String, double>> getWeeklyAverages() async {
    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 900));
    
    // Mock data untuk rata-rata mingguan
    return {
      'AQI': 66.8,
      'PM2_5': 24.3,
      'PM10': 47.5,
      'O3': 62.1,
    };
  }

  Future<String> getWeeklyTrend() async {
    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 700));
    
    // Mock data untuk tren mingguan
    return 'Stabil';
  }

  Future<List<Recommendation>> getPersonalizedRecommendations() async {
    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Membuat rekomendasi personal berdasarkan profil kesehatan
    final profile = await getHealthProfile();
    
    // Logika personalisasi yang sebenarnya akan lebih kompleks
    // Ini hanya contoh sederhana
    List<Recommendation> recommendations = [];
    
    // Rekomendasi dasar untuk semua pengguna
    recommendations.add(
      Recommendation(
        id: '1',
        title: 'Waktu Optimal untuk Aktivitas Outdoor',
        description: 'Berdasarkan data kualitas udara, waktu terbaik untuk aktivitas outdoor hari ini adalah antara 06:00-08:00 pagi.',
        type: 'activity',
        severity: 'Informational',
        iconData: Icons.directions_run,
        actions: [
          'Jadwalkan aktivitas fisik di pagi hari',
          'Gunakan aplikasi Arunika untuk memeriksa kualitas udara sebelum beraktivitas',
          'Pastikan membawa masker N95 sebagai cadangan',
        ],
        appliesTo: ['Semua pengguna', 'Olahragawan'],
      ),
    );
    
    // Rekomendasi khusus untuk kondisi asma
    if (profile.healthConditions.any((condition) => condition.toLowerCase().contains('asma'))) {
      recommendations.add(
        Recommendation(
          id: '2',
          title: 'Perhatian untuk Penderita Asma',
          description: 'Level PM2.5 saat ini (${profile.pollutantSensitivity['PM2_5']?.toInt() ?? 0}) dapat memicu gejala asma. Hindari area dengan traffic tinggi antara jam 12:00-15:00.',
          type: 'health',
          severity: profile.pollutantSensitivity['PM2_5']! > 3.0 ? 'High' : 'Moderate',
          iconData: Icons.health_and_safety,
          actions: [
            'Siapkan inhaler/obat asma sebagai tindakan pencegahan',
            'Gunakan masker N95 saat berada di luar ruangan',
            'Hindari area Malioboro Mall dan sekitarnya sore ini',
            'Pertimbangkan untuk menggunakan air purifier di ruangan',
          ],
          appliesTo: ['Penderita asma', 'Kondisi pernapasan sensitif'],
        ),
      );
    }
    
    // Rekomendasi berdasarkan tingkat aktivitas
    if (profile.activityLevel == 'Tinggi') {
      recommendations.add(
        Recommendation(
          id: '3',
          title: 'Rekomendasi untuk Aktivitas Tinggi',
          description: 'Hindari olahraga intensitas tinggi di outdoor saat kualitas udara dalam kategori "Tidak Sehat" (AQI>100).',
          type: 'activity',
          severity: 'Moderate',
          iconData: Icons.fitness_center,
          actions: [
            'Pertimbangkan olahraga indoor saat kualitas udara buruk',
            'Lakukan pemanasan lebih lama saat olahraga di udara dingin',
            'Minum air lebih banyak saat berolahraga di kondisi panas',
            'Monitor gejala pernapasan selama dan setelah olahraga',
          ],
          appliesTo: ['Olahragawan', 'Aktivitas tinggi'],
        ),
      );
    }
    
    // Rekomendasi berdasarkan sensitivitas polutan
    if ((profile.pollutantSensitivity['O3'] ?? 0) > 2.5) {
      recommendations.add(
        Recommendation(
          id: '4',
          title: 'Perhatian terhadap Ozon (O₃)',
          description: 'Anda memiliki sensitivitas tinggi terhadap Ozon yang biasanya mencapai puncak di siang hari pada cuaca panas dan cerah.',
          type: 'environment',
          severity: 'Moderate',
          iconData: Icons.wb_sunny,
          actions: [
            'Hindari aktivitas outdoor berkepanjangan antara jam 12:00-15:00',
            'Perhatikan peringatan kualitas udara, terutama di hari panas',
            'Pertimbangkan untuk mengurangi waktu di luar ruangan saat level ozon tinggi',
          ],
          appliesTo: ['Sensitif ozon', 'Kondisi pernapasan'],
        ),
      );
    }
    
    return recommendations;
  }
}