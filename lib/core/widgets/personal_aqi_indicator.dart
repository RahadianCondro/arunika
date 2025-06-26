// lib/core/widgets/personal_aqi_indicator.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class PersonalAqiIndicator extends StatelessWidget {
  final int aqiValue;
  final int personalRisk; // 1-5: 1 = low risk, 5 = high risk
  final double size;
  final bool showLabel;

  const PersonalAqiIndicator({
    Key? key,
    required this.aqiValue,
    required this.personalRisk,
    this.size = 120,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // AQI base circle
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _getAqiColor(aqiValue).withOpacity(0.7),
                    _getAqiColor(aqiValue),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getAqiColor(aqiValue).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      aqiValue.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'AQI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Personal risk indicator
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: _getRiskColor(personalRisk),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    personalRisk.toString(),
                    style: TextStyle(
                      color: _getRiskColor(personalRisk),
                      fontSize: size * 0.14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showLabel) ...[
          SizedBox(height: 10),
          Text(
            _getAqiCategory(aqiValue),
            style: TextStyle(
              color: _getAqiColor(aqiValue),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Risiko Personal: ${_getRiskText(personalRisk)}',
            style: TextStyle(
              color: _getRiskColor(personalRisk),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) {
      return AppColors.aqiGood;
    } else if (aqi <= 100) {
      return AppColors.aqiModerate;
    } else if (aqi <= 150) {
      return AppColors.aqiUnhealthySensitive;
    } else if (aqi <= 200) {
      return AppColors.aqiUnhealthy;
    } else if (aqi <= 300) {
      return AppColors.aqiVeryUnhealthy;
    } else {
      return AppColors.aqiHazardous;
    }
  }

  String _getAqiCategory(int aqi) {
    if (aqi <= 50) {
      return 'Baik';
    } else if (aqi <= 100) {
      return 'Sedang';
    } else if (aqi <= 150) {
      return 'Tidak Sehat untuk Sensitif';
    } else if (aqi <= 200) {
      return 'Tidak Sehat';
    } else if (aqi <= 300) {
      return 'Sangat Tidak Sehat';
    } else {
      return 'Berbahaya';
    }
  }

  Color _getRiskColor(int risk) {
    switch (risk) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.success.withGreen(180); // Slightly less green
      case 3:
        return AppColors.warning;
      case 4:
        return AppColors.danger.withRed(220); // Slightly less red
      case 5:
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  String _getRiskText(int risk) {
    switch (risk) {
      case 1:
        return 'Sangat Rendah';
      case 2:
        return 'Rendah';
      case 3:
        return 'Sedang';
      case 4:
        return 'Tinggi';
      case 5:
        return 'Sangat Tinggi';
      default:
        return 'Tidak Diketahui';
    }
  }
}