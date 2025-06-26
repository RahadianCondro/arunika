// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const primary = Color(0xFF3366CC);     // Biru
  static const secondary = Color(0xFFFF9900);   // Oranye
  static const tertiary = Color(0xFF33CC99);    // Teal

  // AQI Colors
  static const aqiGood = Color.fromARGB(255, 0, 88, 0);     // Hijau
  static const aqiModerate = Color.fromARGB(255, 255, 208, 0); // Kuning
  static const aqiUnhealthySensitive = Color(0xFFFF7E00); // Oranye
  static const aqiUnhealthy = Color(0xFFFF0000); // Merah
  static const aqiVeryUnhealthy = Color(0xFF99004C); // Ungu
  static const aqiHazardous = Color(0xFF7E0023); // Marun

  // UI Grays - Penting! Pastikan nama-nama ini sesuai dengan yang dipakai di kode
  static const gray10 = Color(0xFFF8F9FA);
  static const gray20 = Color(0xFFE9ECEF);
  static const gray30 = Color(0xFFDEE2E6);
  static const gray40 = Color(0xFFCED4DA);
  static const gray50 = Color(0xFFADB5BD);
  static const gray60 = Color(0xFF6C757D);
  static const gray70 = Color(0xFF495057);
  static const gray80 = Color(0xFF343A40);
  static const gray90 = Color(0xFF212529);

  // Semantic Colors
  static const success = Color(0xFF28A745);
  static const warning = Color(0xFFFFC107);
  static const danger = Color(0xFFDC3545);
  static const info = Color(0xFF17A2B8);

  // Background Colors
  static const background = Color(0xFFF8F9FA);
  static const surface = Colors.white;
  static const cardBg = Colors.white;
  
  // Text Colors
  static const textPrimary = Color(0xFF303030);
  static const textSecondary = Color(0xFF606060);
  static const textMuted = Color(0xFF909090);
  static const textLight = Color(0xFFFAFAFA);
}