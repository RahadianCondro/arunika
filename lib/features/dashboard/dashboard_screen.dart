// lib/features/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../routes.dart';
import '../../core/widgets/aqi_indicator.dart';
import '../../core/widgets/forecast_card.dart';
import '../../core/widgets/weather_card.dart';
import '../../core/widgets/recommendation_card.dart';
import '../../core/widgets/best_time_widget.dart';
import '../../core/widgets/skeleton_loading.dart';
import '../../core/utils/page_transitions.dart';
import '../../data/models/air_quality.dart';
import '../../data/models/recommendation.dart';
import '../../data/repositories/air_quality_repository.dart';
import '../../data/repositories/recommendation_repository.dart';
import 'aqi_detail_screen.dart';
import 'forecast_screen.dart';
import 'recommendation_detail_screen.dart';
import '../health/recommendations_screen.dart';
import '../../core/widgets/app_bottom_navigation_bar.dart';

import 'dart:async';                
import 'package:intl/intl.dart';    

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AirQualityRepository _airQualityRepository = AirQualityRepository();
  final RecommendationRepository _recommendationRepository = RecommendationRepository();
  DateTime _now = DateTime.now();
  Timer? _clockTimer;

  late Future<AirQuality> _airQualityFuture;
  late Future<List<Recommendation>> _recommendationsFuture;
  
  int _selectedTab = 0;
  final PageController _pageController = PageController();

  // Dummy forecast data similar to ForecastScreen
  final List<Map<String, dynamic>> _hourlyForecast = [
    {
      'hour': 'Now',
      'aqi': 75,
      'trend': 'stable',
      'primary': 'PM2.5',
    },
    {
      'hour': '11:00',
      'aqi': 72,
      'trend': 'improving',
      'primary': 'PM2.5',
    },
    {
      'hour': '12:00',
      'aqi': 68,
      'trend': 'improving',
      'primary': 'O3',
    },
    {
      'hour': '13:00',
      'aqi': 65,
      'trend': 'improving',
      'primary': 'O3',
    },
    {
      'hour': '14:00',
      'aqi': 60,
      'trend': 'improving',
      'primary': 'O3',
    },
    {
      'hour': '15:00',
      'aqi': 58,
      'trend': 'improving',
      'primary': 'PM2.5',
    },
  ];
  
@override
void initState() {
  super.initState();
  // Initialize the futures
  _airQualityFuture = _airQualityRepository.getCurrentAirQuality();
  _recommendationsFuture = _recommendationRepository.getRecommendations();
  
// ⏰ update jam tiap menit
  _clockTimer = Timer.periodic(const Duration(seconds: 60), (_) {
    setState(() => _now = DateTime.now());
  });

  // Add error handling
  _airQualityFuture.catchError((error) {
    print('Error loading air quality data: $error');
  });
  
  _recommendationsFuture.catchError((error) {
    print('Error loading recommendations: $error');
  });
}
  
  @override
  void dispose() {
    _clockTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  
  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildPollutantRow(String name, dynamic value, String unit) {
    String displayValue;
    if (value is double) {
      displayValue = value.toStringAsFixed(1);
    } else {
      displayValue = value.toString();
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$name: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF505050),
          ),
        ),
        Text(
          '$displayValue $unit',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF606060),
          ),
        ),
      ],
    );
  }

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return AppColors.aqiGood;
    if (aqi <= 100) return AppColors.aqiModerate;
    if (aqi <= 150) return AppColors.aqiUnhealthySensitive;
    if (aqi <= 200) return AppColors.aqiUnhealthy;
    if (aqi <= 300) return AppColors.aqiVeryUnhealthy;
    return AppColors.aqiHazardous;
  }

  String _getAqiCategory(int aqi) {
    if (aqi <= 50) return 'GOOD';
    if (aqi <= 100) return 'MODERATE';
    if (aqi <= 150) return 'UNHEALTHY FOR SENSITIVE';
    if (aqi <= 200) return 'UNHEALTHY';
    if (aqi <= 300) return 'VERY UNHEALTHY';
    return 'HAZARDOUS';
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'improving':
        return Icons.trending_down;
      case 'worsening':
        return Icons.trending_up;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'improving':
        return AppColors.success;
      case 'worsening':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

Widget _buildForecastCard(Map<String, dynamic> forecast) {
  final hour = forecast['hour'];
  final aqi = forecast['aqi'];
  final trend = forecast['trend'];
  final primary = forecast['primary'];
  
  final aqiColor = _getAqiColor(aqi);
  final trendColor = _getTrendColor(trend);
  final trendIcon = _getTrendIcon(trend);
  
  return Container(
    width: 100,
    margin: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.all(10), // Kurangi padding dari 12 ke 10
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Ubah ke spaceEvenly
        children: [
          Text(
            hour,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF505050),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: aqiColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                aqi.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: aqiColor,
                ),
              ),
            ),
          ),
          Text(
            primary,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF757575),
            ),
          ),
          Icon(
            trendIcon,
            size: 16,
            color: trendColor,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPlaceholderTab(
    BuildContext context, 
    IconData icon, 
    String title, 
    String subtitle
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF505050),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray10,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Home Tab
            FutureBuilder<AirQuality>(
              future: _airQualityFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Location and date skeleton
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF3366CC),
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: SkeletonLoading(height: 18, borderRadius: 4),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SkeletonLoading(height: 14, width: 150, borderRadius: 4),
                          
                          const SizedBox(height: 20),
                          
                          // AQI Card skeleton
                          const SkeletonAqiCard(),
                          
                          const SizedBox(height: 24),
                          
                          // Forecast title skeleton
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SkeletonLoading(height: 20, width: 100, borderRadius: 4),
                              SkeletonLoading(height: 20, width: 80, borderRadius: 4),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Forecast cards skeleton
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 100,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
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
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SkeletonLoading(height: 12, width: 40, borderRadius: 4),
                                        const SizedBox(height: 8),
                                        SkeletonLoading(height: 40, width: 40, borderRadius: 20),
                                        const SizedBox(height: 6),
                                        SkeletonLoading(height: 10, width: 30, borderRadius: 4),
                                        const SizedBox(height: 4),
                                        SkeletonLoading(height: 16, width: 16, borderRadius: 4),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Weather title skeleton
                          SkeletonLoading(height: 20, width: 100, borderRadius: 4),
                          const SizedBox(height: 12),
                          
                          // Weather card skeleton
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
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
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  SkeletonLoading(height: 48, width: 48, borderRadius: 24),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SkeletonLoading(height: 18, width: 150, borderRadius: 4),
                                        const SizedBox(height: 8),
                                        SkeletonLoading(height: 16, width: 100, borderRadius: 4),
                                        const SizedBox(height: 8),
                                        SkeletonLoading(height: 14, width: 120, borderRadius: 4),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Recommendations title skeleton
                          SkeletonLoading(height: 20, width: 150, borderRadius: 4),
                          const SizedBox(height: 12),
                          
                          // Recommendation cards skeleton
                          SkeletonCard(),
                          const SizedBox(height: 12),
                          SkeletonCard(),
                          
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  print('AirQuality FutureBuilder error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: AppColors.danger),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat data: ${snapshot.error}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.danger,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _airQualityFuture = _airQualityRepository.getCurrentAirQuality();
                            });
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }else if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Tidak ada data tersedia'),
                  );
                }
                
                final airQuality = snapshot.data!;
                
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _airQualityFuture = _airQualityRepository.getCurrentAirQuality();
                      _recommendationsFuture = _recommendationRepository.getRecommendations();
                    });
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF3366CC),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Yogyakarta',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF303030),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                              DateFormat('MMM d, yyyy | hh:mm a').format(_now),
                              style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
                            ),
                            ],
                          ),
                        ).animate().fade().slideY(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 20),
                        
                        // AQI Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: const AqiDetailScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
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
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Current Air Quality',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF303030),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF757575),
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // AQI Indicator
                                    AqiIndicator(
                                      aqiValue: airQuality.aqi,
                                      size: 160,
                                      showLabel: true,
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Pollutant details
                                    if (airQuality.pollutants.containsKey('PM2_5'))
                                      _buildPollutantRow(
                                        'PM2.5', 
                                        airQuality.pollutants['PM2_5']!.value, 
                                        airQuality.pollutants['PM2_5']!.unit
                                      ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    if (airQuality.pollutants.containsKey('O3'))
                                      _buildPollutantRow(
                                        'O3', 
                                        airQuality.pollutants['O3']!.value, 
                                        airQuality.pollutants['O3']!.unit
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ).animate().fade().slideY(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 24),
                        
                        // Forecast
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Forecast',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF303030),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    SlidePageRoute(
                                      page: const ForecastScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF3366CC),
                                ),
                                child: const Text('See More'),
                              ),
                            ],
                          ),
                        ).animate(delay: 100.ms).fade().slideY(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 12),
                        
                        // Forecast cards with real data
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            scrollDirection: Axis.horizontal,
                            itemCount: _hourlyForecast.length,
                            itemBuilder: (context, index) {
                              return _buildForecastCard(_hourlyForecast[index]);
                            },
                          ),
                        ).animate(delay: 200.ms).fade().slideY(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 24),
                        
                        // Weather
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Weather',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF303030),
                                ),
                              ),
                              const SizedBox(height: 12),
                              WeatherCard(
                                temperature: airQuality.weather.temperature,
                                humidity: airQuality.weather.humidity,
                                windSpeed: airQuality.weather.windSpeed,
                                windDirection: airQuality.weather.windDirection,
                                condition: airQuality.weather.conditions,
                              ),
                            ],
                          ),
                        ).animate(delay: 300.ms).fade().slideY(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 24),
                        
                        // Recommendations
                        FutureBuilder<List<Recommendation>>(
                          future: _recommendationsFuture,
                          builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonLoading(height: 20, width: 180, borderRadius: 4),
                                  SizedBox(height: 12),
                                  SkeletonCard(),
                                  SizedBox(height: 12),
                                  SkeletonCard(),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            print('Recommendations FutureBuilder error: ${snapshot.error}');
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Recommendations',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF303030),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: AppColors.danger),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Gagal memuat rekomendasi',
                                            style: TextStyle(color: AppColors.danger),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _recommendationsFuture = _recommendationRepository.getRecommendations();
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.danger,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(40, 30),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          child: const Text('Refresh'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                            
                            final recommendations = snapshot.data!;
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Recommendations',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF303030),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            SlidePageRoute(
                                              page: const RecommendationsScreen(),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF3366CC),
                                        ),
                                        child: const Text('See All'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Show top 2 recommendations
                                  if (recommendations.isNotEmpty)
                                    RecommendationCard(
                                      title: recommendations[0].title,
                                      description: recommendations[0].description,
                                      icon: recommendations[0].iconData,
                                      severity: recommendations[0].severity,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          SlidePageRoute(
                                            page: RecommendationDetailScreen(
                                              recommendation: recommendations[0],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  
                                  if (recommendations.length > 1)
                                    RecommendationCard(
                                      title: recommendations[1].title,
                                      description: recommendations[1].description,
                                      icon: recommendations[1].iconData,
                                      severity: recommendations[1].severity,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          SlidePageRoute(
                                            page: RecommendationDetailScreen(
                                              recommendation: recommendations[1],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ).animate(delay: 400.ms).fade().slideY(begin: 0.3, end: 0);
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Best Times for Activity
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Best Times Today',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF303030),
                                ),
                              ),
                              const SizedBox(height: 12),
                              BestTimeWidget(
                                activityType: 'outdoor_activity',
                                timeRanges: [
                                  TimeRange(
                                    start: '06:00',
                                    end: '08:00',
                                    quality: 'good',
                                  ),
                                  TimeRange(
                                    start: '18:00',
                                    end: '20:00',
                                    quality: 'moderate',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate(delay: 500.ms).fade().slideY(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Placeholder tabs untuk halaman lain
            _buildPlaceholderTab(
              context, 
              Icons.map, 
              'Maps Coming Soon', 
              'This feature will be available in Sprint 3'
            ),
            
            _buildPlaceholderTab(
              context, 
              Icons.route, 
              'Routes Coming Soon', 
              'This feature will be available in Sprint 3'
            ),
            
            _buildPlaceholderTab(
              context, 
              Icons.favorite, 
              'Health Coming Soon', 
              'This feature will be available in Sprint 4'
            ),
            
            _buildPlaceholderTab(
              context, 
              Icons.person, 
              'Profile Coming Soon', 
              'This feature will be available in Sprint 4'
            ),
          ],
        ),
      ),
      // Fixed: moved bottomNavigationBar inside the Scaffold
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
      
    );
  }
}