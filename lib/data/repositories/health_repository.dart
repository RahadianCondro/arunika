import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/health_profile.dart';
import '../models/exposure_history.dart';
import '../models/recommendation.dart';
import 'package:latlong2/latlong.dart';

class HealthRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // FIRESTORE: Ambil profil kesehatan dari Firestore
  Future<HealthProfile> getHealthProfile() async {
    final doc = await _db.collection('health_profiles').doc(_uid).get();

    if (doc.exists && doc.data() != null) {
      return HealthProfile.fromJson(doc.data()!);
    } else {
      final profile = HealthProfile.empty(uid: _uid); // ✅ Pakai named argument
      await saveHealthProfile(profile);
      return profile;
    }
  }

  // FIRESTORE: Simpan profil ke Firestore
  Future<void> saveHealthProfile(HealthProfile profile) async {
    await _db
        .collection('health_profiles')
        .doc(_uid)
        .set(profile.toJson(), SetOptions(merge: true));
  }

  // MOCK: Statistik kesehatan
  Future<Map<String, dynamic>> getHealthStats() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return {
      'weeklyAverageAQI': 68,
      'aqiTrend': 'Stabil',
      'dailyExposureHours': 8.5,
      'correlations': [
        {
          'description':
              'Peningkatan gejala asma terdeteksi saat tingkat PM2.5 meningkat di atas 35 μg/m³.',
          'strength': 0.75,
          'icon': Icons.healing,
        },
        {
          'description':
              'Paparan kualitas udara buruk di pagi hari berkorelasi dengan peningkatan iritasi mata.',
          'strength': 0.6,
          'icon': Icons.remove_red_eye,
        },
      ],
    };
  }

  // MOCK: Riwayat paparan
  Future<List<ExposureHistory>> getExposureHistory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return [
      ExposureHistory(
        date: '2025-05-01',
        averageAqi: 70,
        locations: [
          LocationExposure(
            name: 'Rumah',
            lat: -7.797068,
            lon: 110.370529,
            aqi: 65,
            duration: 12.0,
          ),
          LocationExposure(
            name: 'Kantor',
            lat: -7.782900,
            lon: 110.367032,
            aqi: 78,
            duration: 8.5,
          ),
          LocationExposure(
            name: 'Commute',
            lat: -7.790000,
            lon: 110.368500,
            aqi: 85,
            duration: 1.5,
          ),
        ],
        pollutants: {
          'PM2_5': PollutantExposure(average: 25.8, peak: 42.3),
          'PM10': PollutantExposure(average: 48.2, peak: 72.1),
          'O3': PollutantExposure(average: 65.3, peak: 95.7),
        },
      ),
      ExposureHistory(
        date: '2025-04-30',
        averageAqi: 68,
        locations: [
          LocationExposure(
            name: 'Rumah',
            lat: -7.797068,
            lon: 110.370529,
            aqi: 62,
            duration: 14.0,
          ),
          LocationExposure(
            name: 'Kantor',
            lat: -7.782900,
            lon: 110.367032,
            aqi: 75,
            duration: 8.0,
          ),
          LocationExposure(
            name: 'Taman Kota',
            lat: -7.775000,
            lon: 110.375000,
            aqi: 55,
            duration: 2.0,
          ),
        ],
        pollutants: {
          'PM2_5': PollutantExposure(average: 23.1, peak: 38.5),
          'PM10': PollutantExposure(average: 45.6, peak: 68.2),
          'O3': PollutantExposure(average: 60.8, peak: 80.3),
        },
      ),
    ];
  }

  // MOCK: Rata-rata mingguan
  Future<Map<String, double>> getWeeklyAverages() async {
    await Future.delayed(const Duration(milliseconds: 900));
    return {
      'AQI': 66.8,
      'PM2_5': 24.3,
      'PM10': 47.5,
      'O3': 62.1,
    };
  }

  // MOCK: Tren mingguan
  Future<String> getWeeklyTrend() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return 'Stabil';
  }

  // MOCK: Rekomendasi personal
  Future<List<Recommendation>> getPersonalizedRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final profile = await getHealthProfile();

    List<Recommendation> recommendations = [];

    recommendations.add(
      Recommendation(
        id: '1',
        title: 'Waktu Optimal untuk Aktivitas Outdoor',
        description:
            'Waktu terbaik untuk aktivitas outdoor hari ini adalah antara 06:00-08:00.',
        type: 'activity',
        severity: 'Informational',
        iconData: Icons.directions_run,
        actions: [
          'Jadwalkan aktivitas fisik di pagi hari',
          'Gunakan aplikasi Arunika untuk cek kualitas udara',
          'Siapkan masker N95 sebagai cadangan',
        ],
        appliesTo: ['Semua pengguna', 'Olahragawan'],
      ),
    );

    if (profile.healthConditions
        .any((condition) => condition.toLowerCase().contains('asma'))) {
      recommendations.add(
        Recommendation(
          id: '2',
          title: 'Perhatian untuk Penderita Asma',
          description:
              'Level PM2.5 saat ini (${profile.pollutantSensitivity['PM2_5']?.toInt() ?? 0}) dapat memicu gejala asma.',
          type: 'health',
          severity: profile.pollutantSensitivity['PM2_5']! > 3.0
              ? 'High'
              : 'Moderate',
          iconData: Icons.health_and_safety,
          actions: [
            'Siapkan inhaler/obat asma',
            'Gunakan masker N95 di luar ruangan',
            'Hindari area ramai sore hari',
          ],
          appliesTo: ['Penderita asma', 'Kondisi pernapasan sensitif'],
        ),
      );
    }

    if (profile.activityLevel == 'Tinggi') {
      recommendations.add(
        Recommendation(
          id: '3',
          title: 'Rekomendasi untuk Aktivitas Tinggi',
          description:
              'Hindari olahraga intensitas tinggi saat kualitas udara buruk (AQI > 100).',
          type: 'activity',
          severity: 'Moderate',
          iconData: Icons.fitness_center,
          actions: [
            'Gunakan ruang indoor',
            'Lakukan pemanasan lebih lama',
            'Minum air lebih banyak',
          ],
          appliesTo: ['Aktivitas tinggi'],
        ),
      );
    }

    if ((profile.pollutantSensitivity['O3'] ?? 0) > 2.5) {
      recommendations.add(
        Recommendation(
          id: '4',
          title: 'Perhatian terhadap Ozon (O₃)',
          description:
              'Anda sensitif terhadap Ozon, yang puncaknya terjadi siang hari.',
          type: 'environment',
          severity: 'Moderate',
          iconData: Icons.wb_sunny,
          actions: [
            'Hindari aktivitas luar siang hari',
            'Cek peringatan kualitas udara',
          ],
          appliesTo: ['Sensitif ozon'],
        ),
      );
    }

    return recommendations;
  }
}
