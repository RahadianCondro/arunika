// lib/features/health/health_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_bottom_navigation_bar.dart';
import '../../data/models/health_profile.dart';
import '../../data/repositories/health_repository.dart';
import '../../routes.dart';
import 'exposure_tracking_screen.dart';
import 'recommendations_screen.dart';

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
  final HealthRepository _repository = HealthRepository();
  late Future<HealthProfile> _profileFuture;
  late Future<Map<String, dynamic>> _healthStatsFuture;
  
  @override
  void initState() {
    super.initState();
    _profileFuture = _repository.getHealthProfile();
    _healthStatsFuture = _repository.getHealthStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kesehatan Personal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _profileFuture = _repository.getHealthProfile();
            _healthStatsFuture = _repository.getHealthStats();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHealthProfileCard(),
                SizedBox(height: AppDimensions.spacing4),
                _buildExposureSummary(),
                SizedBox(height: AppDimensions.spacing4),
                _buildRecommendationPreview(),
                SizedBox(height: AppDimensions.spacing4),
                _buildQuickActions(),
                SizedBox(height: AppDimensions.spacing6),
                _buildHealthInsights(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildHealthProfileCard() {
    return FutureBuilder<HealthProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final profile = snapshot.data ?? HealthProfile.empty();
        
        return Container(
          padding: EdgeInsets.all(AppDimensions.spacing4),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacing3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Umur: ${profile.age} tahun',
                          style: TextStyle(
                            color: AppColors.gray70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.healthProfile);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing3,
                        vertical: AppDimensions.spacing2,
                      ),
                    ),
                    child: const Text('Edit Profil'),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spacing3),
              Wrap(
                spacing: AppDimensions.spacing2,
                runSpacing: AppDimensions.spacing2,
                children: [
                  for (final condition in profile.healthConditions)
                    Chip(
                      label: Text(condition),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                      ),
                      labelStyle: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppDimensions.spacing3),
              Text(
                'Tingkat Aktivitas: ${profile.activityLevel}',
                style: TextStyle(
                  color: AppColors.gray70,
                ),
              ),
              SizedBox(height: AppDimensions.spacing1),
              Row(
                children: [
                  Text(
                    'Sensitivitas Polutan: ',
                    style: TextStyle(
                      color: AppColors.gray70,
                    ),
                  ),
                  _buildSensitivityIndicator(profile.pollutantSensitivity['PM2_5'] ?? 3.0),
                ],
              ),
            ],
          ),
        ).animate().fade().slideY(begin: 0.3, end: 0);
      },
    );
  }

  Widget _buildSensitivityIndicator(double sensitivity) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.circle,
          color: index < sensitivity.toInt()
              ? AppColors.primary
              : AppColors.gray30,
          size: 12,
        );
      }),
    );
  }

  Widget _buildExposureSummary() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _healthStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final stats = snapshot.data ?? {};
        final weeklyAQI = stats['weeklyAverageAQI'] ?? 65;
        final aqiTrend = stats['aqiTrend'] ?? 'Stabil';
        final exposureTime = stats['dailyExposureHours'] ?? 8.5;
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExposureTrackingScreen(),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(AppDimensions.spacing4),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paparan Polusi',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppColors.gray60,
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spacing3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('AQI Rata-rata', '$weeklyAQI', _getAqiColor(weeklyAQI)),
                    _buildStatItem('Tren', aqiTrend, aqiTrend == 'Membaik' 
                        ? AppColors.success 
                        : aqiTrend == 'Memburuk' 
                            ? AppColors.danger 
                            : AppColors.primary),
                    _buildStatItem('Waktu Paparan', '$exposureTime jam/hari', AppColors.primary),
                  ],
                ),
                SizedBox(height: AppDimensions.spacing3),
                LinearProgressIndicator(
                  value: weeklyAQI / 300,
                  backgroundColor: AppColors.gray20,
                  valueColor: AlwaysStoppedAnimation<Color>(_getAqiColor(weeklyAQI)),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
                SizedBox(height: AppDimensions.spacing2),
                Text(
                  _getAqiMessage(weeklyAQI),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray70,
                  ),
                ),
              ],
            ),
          ).animate(delay: 100.ms).fade().slideY(begin: 0.3, end: 0),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.gray70,
          ),
        ),
        SizedBox(height: AppDimensions.spacing1),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationPreview() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RecommendationsScreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(AppDimensions.spacing4),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rekomendasi Hari Ini',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppColors.gray60,
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spacing3),
            Container(
              padding: EdgeInsets.all(AppDimensions.spacing3),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info,
                    color: AppColors.info,
                    size: 24,
                  ),
                  SizedBox(width: AppDimensions.spacing2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Waktu Optimal untuk Aktivitas Outdoor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spacing1),
                        Text(
                          'Pagi hari (06:00-08:00) adalah waktu terbaik untuk aktivitas outdoor hari ini.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            Container(
              padding: EdgeInsets.all(AppDimensions.spacing3),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning,
                    color: AppColors.warning,
                    size: 24,
                  ),
                  SizedBox(width: AppDimensions.spacing2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hindari Area Malioboro jam 12:00-15:00',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spacing1),
                        Text(
                          'Kualitas udara diprediksi akan memburuk di area tersebut siang ini.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: 200.ms).fade().slideY(begin: 0.3, end: 0),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacing4),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi Cepat',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.spacing3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                'Rute Optimal',
                Icons.route,
                AppColors.primary,
                () => Navigator.pushNamed(context, AppRoutes.routePlanning),
              ),
              _buildActionButton(
                'Track Gejala',
                Icons.healing,
                AppColors.secondary,
                () {
                  // Navigate to symptom tracking (future development)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fitur ini akan tersedia segera!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildActionButton(
                'Lapor Polusi',
                Icons.report_problem,
                AppColors.warning,
                () {
                  // Navigate to report pollution (future development)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fitur ini akan tersedia segera!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 300.ms).fade().slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsights() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _healthStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final stats = snapshot.data ?? {};
        final correlations = stats['correlations'] ?? [];
        
        if (correlations.isEmpty) {
          return Container(
            padding: EdgeInsets.all(AppDimensions.spacing4),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insights Kesehatan',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppDimensions.spacing3),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.insights,
                        size: 48,
                        color: AppColors.gray40,
                      ),
                      SizedBox(height: AppDimensions.spacing2),
                      Text(
                        'Belum ada cukup data untuk analisis',
                        style: TextStyle(
                          color: AppColors.gray60,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spacing2),
                      Text(
                        'Terus gunakan Arunika untuk mendapatkan analisis kesehatan yang personal',
                        style: TextStyle(
                          color: AppColors.gray60,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: 400.ms).fade().slideY(begin: 0.3, end: 0);
        }
        
        return Container(
          padding: EdgeInsets.all(AppDimensions.spacing4),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Insights Kesehatan',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppDimensions.spacing3),
              for (final correlation in correlations)
                _buildCorrelationItem(
                  correlation['description'],
                  correlation['strength'],
                  correlation['icon'],
                ),
            ],
          ),
        ).animate(delay: 400.ms).fade().slideY(begin: 0.3, end: 0);
      },
    );
  }

  Widget _buildCorrelationItem(String description, double strength, IconData? iconData) {
    final icon = iconData ?? Icons.analytics;
    Color color;
    
    if (strength > 0.7) {
      color = AppColors.danger;
    } else if (strength > 0.4) {
      color = AppColors.warning;
    } else {
      color = AppColors.info;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacing3),
      padding: EdgeInsets.all(AppDimensions.spacing3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(width: AppDimensions.spacing2),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray80,
              ),
            ),
          ),
        ],
      ),
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

  String _getAqiMessage(int aqi) {
    if (aqi <= 50) {
      return 'Kualitas udara baik, ideal untuk aktivitas outdoor.';
    } else if (aqi <= 100) {
      return 'Kualitas udara sedang, masih aman untuk sebagian besar orang.';
    } else if (aqi <= 150) {
      return 'Tidak sehat bagi kelompok sensitif, pertimbangkan untuk membatasi aktivitas outdoor.';
    } else if (aqi <= 200) {
      return 'Tidak sehat, batasi aktivitas outdoor berkepanjangan.';
    } else if (aqi <= 300) {
      return 'Sangat tidak sehat, hindari aktivitas outdoor.';
    } else {
      return 'Berbahaya, tetap di dalam ruangan dengan filter udara jika memungkinkan.';
    }
  }
}