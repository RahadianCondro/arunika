// lib/core/widgets/route_recommendation_card.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class RouteRecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final Map<String, dynamic> routeInfo;
  final List<String> healthFactors;
  final VoidCallback onViewRoute;
  final VoidCallback onNavigate;

  const RouteRecommendationCard({
    Key? key,
    required this.title,
    required this.description,
    required this.routeInfo,
    required this.healthFactors,
    required this.onViewRoute,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: _getRouteTypeColor().withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
              vertical: AppDimensions.spacing2,
              horizontal: AppDimensions.spacing4,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _getRouteTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusMedium),
                topRight: Radius.circular(AppDimensions.radiusMedium),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getRouteTypeIcon(),
                  color: _getRouteTypeColor(),
                  size: 16,
                ),
                SizedBox(width: AppDimensions.spacing2),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: _getRouteTypeColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimensions.small,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacing3),
            child: Column(
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray70,
                  ),
                ),
                
                SizedBox(height: AppDimensions.spacing3),
                
                // Route metrics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRouteInfoItem(
                      'AQI rata-rata',
                      routeInfo['aqi_avg'].toString(),
                      _getAqiColor(routeInfo['aqi_avg'] as int),
                    ),
                    _buildRouteInfoItem(
                      'Jarak',
                      '${routeInfo['distance']} km',
                      AppColors.gray70,
                    ),
                    _buildRouteInfoItem(
                      'Waktu',
                      '${routeInfo['duration']} menit',
                      AppColors.gray70,
                    ),
                  ],
                ),
                
                SizedBox(height: AppDimensions.spacing3),
                
                // Health factors
                if (healthFactors.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppDimensions.spacing2),
                    decoration: BoxDecoration(
                      color: AppColors.gray10,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Faktor Kesehatan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spacing1),
                        ...healthFactors.map((factor) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  factor,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: AppDimensions.spacing3),
                ],
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewRoute,
                        icon: Icon(Icons.info_outline),
                        label: Text('Detail'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
                          foregroundColor: _getRouteTypeColor(),
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacing3),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onNavigate,
                        icon: Icon(Icons.navigation),
                        label: Text('Mulai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getRouteTypeColor(),
                          padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildRouteInfoItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.gray60,
            fontSize: AppDimensions.small,
          ),
        ),
        SizedBox(height: AppDimensions.spacing1),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.paragraph,
          ),
        ),
      ],
    );
  }

  Color _getRouteTypeColor() {
    final routeType = routeInfo['type'] as String? ?? 'balanced';
    
    if (routeType == 'lowest_exposure') {
      return AppColors.success;
    } else if (routeType == 'fastest') {
      return AppColors.secondary;
    } else {
      return AppColors.tertiary;
    }
  }

  IconData _getRouteTypeIcon() {
    final routeType = routeInfo['type'] as String? ?? 'balanced';
    
    if (routeType == 'lowest_exposure') {
      return Icons.favorite;
    } else if (routeType == 'fastest') {
      return Icons.speed;
    } else {
      return Icons.balance;
    }
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
}