// lib/core/widgets/forecast_card.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class ForecastCard extends StatelessWidget {
  final String time;
  final int aqi;
  final String trend;

  const ForecastCard({
    Key? key,
    required this.time,
    required this.aqi,
    required this.trend,
  }) : super(key: key);

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) {
      return AppColors.aqiGood;
    } else if (aqi <= 100) {
      return AppColors.aqiModerate;
    } else if (aqi <= 150) {
      return AppColors.aqiUnhealthySensitive;
    } else {
      return AppColors.aqiUnhealthy;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color aqiColor = _getAqiColor(aqi);
    
    return Container(
      width: 80,
      height: 110, // Asegurar altura fija
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Reducir el padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Usar el tamaño mínimo necesario
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 6), // Reducir espacio
            Text(
              aqi.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: aqiColor,
              ),
            ),
            const SizedBox(height: 6), // Reducir espacio
            Icon(
              trend == 'up' ? Icons.arrow_upward : Icons.arrow_downward,
              color: trend == 'up' 
                  ? AppColors.danger
                  : AppColors.success,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}