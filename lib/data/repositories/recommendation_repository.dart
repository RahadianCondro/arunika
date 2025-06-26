// lib/data/repositories/recommendation_repository.dart
import 'package:flutter/material.dart';
import '../models/recommendation.dart';

class RecommendationRepository {
  Future<List<Recommendation>> getRecommendations() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Return hardcoded recommendations instead of trying to load from assets
    // This avoids file loading issues and ensures data is always available
    return [
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
      Recommendation(
        id: '2',
        title: 'Perhatian untuk Penderita Asma',
        description: 'Level PM2.5 saat ini (4) dapat memicu gejala asma. Hindari area dengan traffic tinggi antara jam 12:00-15:00.',
        type: 'health',
        severity: 'High',
        iconData: Icons.health_and_safety,
        actions: [
          'Siapkan inhaler/obat asma sebagai tindakan pencegahan',
          'Gunakan masker N95 saat berada di luar ruangan',
          'Hindari area Malioboro Mall dan sekitarnya sore ini',
          'Pertimbangkan untuk menggunakan air purifier di ruangan',
        ],
        appliesTo: ['Penderita asma', 'Kondisi pernapasan sensitif'],
      ),
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
    ];
  }
}