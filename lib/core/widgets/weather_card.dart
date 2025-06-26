// lib/core/widgets/weather_card.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class WeatherCard extends StatelessWidget {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final String condition;
  
  const WeatherCard({
    Key? key,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.condition,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacing4),
        child: Row(
          children: [
            _getWeatherIcon(),
            SizedBox(width: AppDimensions.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF303030),
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacing2),
                      Text(
                        '| ${humidity}%',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF505050),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacing1),
                  Text(
                    condition,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF505050),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing1),
                  Text(
                    'Wind: ${windSpeed.toStringAsFixed(1)} m/s ${windDirection}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _getWeatherIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (condition.toLowerCase()) {
      case 'sunny':
        iconData = Icons.wb_sunny;
        iconColor = Colors.orange;
        break;
      case 'partly cloudy':
        iconData = Icons.wb_cloudy;
        iconColor = Colors.orange;
        break;
      case 'cloudy':
        iconData = Icons.cloud;
        iconColor = Colors.grey;
        break;
      case 'rainy':
      case 'rain':
        iconData = Icons.water_drop;
        iconColor = Colors.blue;
        break;
      case 'thunderstorm':
        iconData = Icons.flash_on;
        iconColor = Colors.amber;
        break;
      case 'snowy':
      case 'snow':
        iconData = Icons.ac_unit;
        iconColor = Colors.lightBlue;
        break;
      case 'foggy':
      case 'fog':
        iconData = Icons.cloud;
        iconColor = Colors.blueGrey;
        break;
      default:
        iconData = Icons.wb_sunny;
        iconColor = Colors.orange;
    }
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 30,
      ),
    );
  }
}