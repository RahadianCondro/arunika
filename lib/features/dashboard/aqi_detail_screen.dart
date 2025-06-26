// lib/features/dashboard/aqi_detail_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/aqi_indicator.dart';
import '../../core/widgets/pollutant_card.dart';
import '../../data/models/air_quality.dart';
import '../../data/repositories/air_quality_repository.dart';

class AqiDetailScreen extends StatefulWidget {
  const AqiDetailScreen({Key? key}) : super(key: key);

  @override
  State<AqiDetailScreen> createState() => _AqiDetailScreenState();
}

class _AqiDetailScreenState extends State<AqiDetailScreen> with SingleTickerProviderStateMixin {
  final AirQualityRepository _repository = AirQualityRepository();
  late TabController _tabController;
  
  // Dummy data for historical tab
  final List<Map<String, dynamic>> _historicalData = [
    {'date': 'Apr 25', 'aqi': 68, 'category': 'Moderate'},
    {'date': 'Apr 26', 'aqi': 58, 'category': 'Moderate'},
    {'date': 'Apr 27', 'aqi': 48, 'category': 'Good'},
    {'date': 'Apr 28', 'aqi': 75, 'category': 'Moderate'},
    {'date': 'Apr 29', 'aqi': 82, 'category': 'Moderate'},
    {'date': 'Apr 30', 'aqi': 65, 'category': 'Moderate'},
    {'date': 'May 1', 'aqi': 70, 'category': 'Moderate'},
  ];
  
  // Data dummy untuk grafik 24 jam
  final List<FlSpot> _aqiData = [
    FlSpot(0, 70),  // 12 AM
    FlSpot(2, 63),  // 2 AM
    FlSpot(4, 58),  // 4 AM
    FlSpot(6, 62),  // 6 AM
    FlSpot(8, 70),  // 8 AM
    FlSpot(10, 78), // 10 AM
    FlSpot(12, 80), // 12 PM
    FlSpot(14, 82), // 2 PM
    FlSpot(16, 79), // 4 PM
    FlSpot(18, 75), // 6 PM
    FlSpot(20, 72), // 8 PM
    FlSpot(22, 68), // 10 PM
    FlSpot(24, 65), // 12 AM (next day)
  ];

  late Future<AirQuality> _airQualityFuture;
  String _selectedPollutant = 'PM2_5';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _airQualityFuture = _repository.getCurrentAirQuality();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    } else {
      return AppColors.aqiVeryUnhealthy;
    }
  }
  
  // Added function to get pollutant category color based on Indonesian category
  Color _getPollutantCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'baik':
        return AppColors.success;
      case 'sedang':
        return AppColors.warning;
      case 'tidak sehat':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }
  
  // Added function to convert any numeric value to a formatted string
  String _formatNumericValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(1); // Only show 1 decimal place
    } else if (value is int) {
      return value.toString();
    } else {
      try {
        // Try to parse as double first
        return double.parse(value.toString()).toStringAsFixed(1);
      } catch (e) {
        return value.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share AQI information
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Berbagi belum diterapkan')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Saat ini'),
            Tab(text: '24 Jam'),
            Tab(text: 'History'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.gray60,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: FutureBuilder<AirQuality>(
        future: _airQualityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: AppColors.danger),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _airQualityFuture = _repository.getCurrentAirQuality();
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('No data available'),
            );
          }
          
          final airQuality = snapshot.data!;
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Current Tab
              _buildCurrentTab(airQuality),
              
              // 24 Hour Tab
              _build24HourTab(),
              
              // Historical Tab
              _buildHistoricalTab(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentTab(AirQuality airQuality) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _airQualityFuture = _repository.getCurrentAirQuality();
        });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppDimensions.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AQI Indicator
            Center(
              child: AqiIndicator(
                aqiValue: airQuality.aqi,
                size: 150,
                showLabel: true,
              ),
            ).animate().fade().scale(alignment: Alignment.center),
            
            SizedBox(height: AppDimensions.spacing4),
            
            // AQI Impact
            Center(
              child: Container(
                padding: EdgeInsets.all(AppDimensions.spacing3),
                decoration: BoxDecoration(
                  color: AppColors.gray20,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Text(
                  'Dapat memengaruhi individu yang sensitif.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ).animate(delay: 100.ms).fade().slideY(begin: 0.3, end: 0),
            
            SizedBox(height: AppDimensions.spacing6),
            
            // Last Updated
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terakhir Diperbarui: 1 Mei, 09:30 WIB',
                  style: TextStyle(
                    color: AppColors.gray60,
                    fontSize: AppDimensions.small,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _airQualityFuture = _repository.getCurrentAirQuality();
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ).animate(delay: 150.ms).fade(),
            
            SizedBox(height: AppDimensions.spacing6),
            
            // Pollutants title
            Text(
              'Pollutants',
              style: Theme.of(context).textTheme.titleLarge,
            ).animate(delay: 200.ms).fade().slideY(begin: 0.3, end: 0),
            
            SizedBox(height: AppDimensions.spacing4),
            
            // Pollutants list
            for (var entry in airQuality.pollutants.entries)
              _buildPollutantCard(
                name: _getPollutantName(entry.key),
                value: _formatNumericValue(entry.value.value),
                unit: entry.value.unit,
                category: _translateCategory(entry.value.category),
                pollutantType: entry.key,
                percentage: _calculatePercentage(entry.key, entry.value.value),
              ).animate(delay: 300.ms).fade().slideY(begin: 0.3, end: 0),
            
            SizedBox(height: AppDimensions.spacing6),
            
            // Health impact
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppDimensions.spacing4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      SizedBox(width: AppDimensions.spacing2),
                      Text(
                        'Dampak Kesehatan',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacing3),
                  Text(
                    'Tingkat kualitas udara yang sedang dapat menyebabkan dampak kesehatan yang merugikan bagi kelompok yang sensitif, termasuk individu dengan kondisi pernapasan seperti asma. Pertimbangkan untuk membatasi aktivitas di luar ruangan yang berkepanjangan selama jam-jam puncak polusi (11.00-15.00).',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: AppDimensions.spacing3),
                  _buildHealthEffectsTable(),
                ],
              ),
            ).animate(delay: 400.ms).fade().slideY(begin: 0.3, end: 0),
            
            SizedBox(height: AppDimensions.spacing8),
          ],
        ),
      ),
    );
  }
  
  // Custom pollutant card to replace the existing one with fixes
  Widget _buildPollutantCard({
    required String name,
    required String value,
    required String unit,
    required String category,
    required String pollutantType,
    required double percentage,
  }) {
    // Get the appropriate color based on the category
    final Color categoryColor = _getPollutantCategoryColor(category);
    
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacing3),
      padding: EdgeInsets.all(AppDimensions.spacing3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing3,
                  vertical: AppDimensions.spacing1,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: categoryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing3),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$value $unit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing2),
          Stack(
            children: [
              // Background bar
              Container(
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.gray20,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // Progress bar with appropriate color
              Container(
                width: percentage * (MediaQuery.of(context).size.width - 80) / 100,
                height: 10,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Helper function to properly translate category names
  String _translateCategory(String englishCategory) {
    switch (englishCategory.toLowerCase()) {
      case 'good':
        return 'BAIK';
      case 'moderate':
        return 'SEDANG';
      case 'unhealthy for sensitive':
      case 'unhealthy for sensitive groups':
      case 'unhealthy':
        return 'TIDAK SEHAT';
      case 'very unhealthy':
        return 'SANGAT TIDAK SEHAT';
      case 'hazardous':
        return 'BERBAHAYA';
      default:
        return englishCategory.toUpperCase();
    }
  }
  
  // Helper function to get proper pollutant names
  String _getPollutantName(String pollutantCode) {
    switch (pollutantCode) {
      case 'PM2_5':
        return 'Particulate Matter < 2.5μm';
      case 'PM10':
        return 'Particulate Matter < 10μm';
      case 'O3':
        return 'Ozone';
      case 'NO2':
        return 'Nitrogen Dioxide';
      case 'SO2':
        return 'Sulfur Dioxide';
      case 'CO':
        return 'Carbon Monoxide';
      default:
        return pollutantCode;
    }
  }
  
  // Helper function to calculate percentage for progress bars
double _calculatePercentage(String pollutantType, dynamic value) {
  double numValue = 0;
  if (value is double) {
    numValue = value;
  } else if (value is int) {
    numValue = value.toDouble();
  } else {
    try {
      numValue = double.parse(value.toString());
    } catch (e) {
      return 0;
    }
  }
  
  // Calculate percentage based on pollutant type and standard values
  switch (pollutantType) {
    case 'PM2_5':
      // 0-15 is good (0-30%), 15-30 is moderate (30-60%), >30 is unhealthy (60-100%)
      if (numValue <= 15) {
        return (numValue / 15) * 30;
      } else if (numValue <= 30) {
        return 30 + ((numValue - 15) / 15) * 30;
      } else {
        return math.min(60 + ((numValue - 30) / 30) * 40, 100);
      }
    case 'PM10':
      // 0-50 is good (0-30%), 50-100 is moderate (30-60%), >100 is unhealthy (60-100%)
      if (numValue <= 50) {
        return (numValue / 50) * 30;
      } else if (numValue <= 100) {
        return 30 + ((numValue - 50) / 50) * 30;
      } else {
        return math.min(60 + ((numValue - 100) / 100) * 40, 100);
      }
    case 'O3':
      // 0-50 is good (0-30%), 50-100 is moderate (30-60%), >100 is unhealthy (60-100%)
      if (numValue <= 50) {
        return (numValue / 50) * 30;
      } else if (numValue <= 100) {
        return 30 + ((numValue - 50) / 50) * 30;
      } else {
        return math.min(60 + ((numValue - 100) / 100) * 40, 100);
      }
    case 'NO2':
      // 0-30 is good (0-30%), 30-60 is moderate (30-60%), >60 is unhealthy (60-100%)
      if (numValue <= 30) {
        return (numValue / 30) * 30;
      } else if (numValue <= 60) {
        return 30 + ((numValue - 30) / 30) * 30;
      } else {
        return math.min(60 + ((numValue - 60) / 60) * 40, 100);
      }
    default:
      // Generic scale for other pollutants
      if (numValue <= 50) {
        return (numValue / 50) * 50;
      } else {
        return math.min(50 + ((numValue - 50) / 50) * 50, 100);
      }
  }
}

  Widget _build24HourTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Air Quality - Last 24 Hours',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fade().slideY(begin: 0.3, end: 0),
          
          SizedBox(height: AppDimensions.spacing4),
          
          // Pollutant selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPollutantChip('PM2_5', 'PM2.5'),
                SizedBox(width: AppDimensions.spacing2),
                _buildPollutantChip('PM10', 'PM10'),
                SizedBox(width: AppDimensions.spacing2),
                _buildPollutantChip('O3', 'Ozone'),
                SizedBox(width: AppDimensions.spacing2),
                _buildPollutantChip('NO2', 'NO2'),
                SizedBox(width: AppDimensions.spacing2),
                _buildPollutantChip('AQI', 'AQI'),
              ],
            ),
          ).animate(delay: 100.ms).fade().slideY(begin: 0.3, end: 0),
          
          SizedBox(height: AppDimensions.spacing6),
          
          // 24h Chart
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: EdgeInsets.all(AppDimensions.spacing4),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.gray30,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.gray30,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 4,
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: leftTitleWidgets,
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.gray40),
                ),
                minX: 0,
                maxX: 24,
                minY: 0,
                maxY: 120,
                lineBarsData: [
                  LineChartBarData(
                    spots: _aqiData,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    tooltipRoundedRadius: 8,
                    tooltipBorder: BorderSide(
                      color: AppColors.gray40,
                      width: 1,
                    ),
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          '${touchedSpot.y.toInt()} AQI',
                          TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ).animate(delay: 200.ms).fade().slideY(begin: 0.3, end: 0),
          
          SizedBox(height: AppDimensions.spacing6),
          
          // Statistics
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppDimensions.spacing4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '24-Hour Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppDimensions.spacing4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatistic('Avg', '68', AppColors.primary),
                    _buildStatistic('Min', '48', AppColors.success),
                    _buildStatistic('Max', '82', AppColors.danger),
                    _buildStatistic('Now', '75', AppColors.warning),
                  ],
                ),
                SizedBox(height: AppDimensions.spacing4),
                Row(
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: AppColors.success,
                      size: 20,
                    ),
                    SizedBox(width: AppDimensions.spacing2),
                    Text(
                      'Trend: Improving',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: 300.ms).fade().slideY(begin: 0.3, end: 0),
          
          SizedBox(height: AppDimensions.spacing6),
          
          // Peak hours
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppDimensions.spacing4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peak Hours',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppDimensions.spacing3),
                Text(
                  'Jam dengan tingkat polusi tertinggi:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: AppDimensions.spacing3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPeakHour('12 PM', '80'),
                    _buildPeakHour('2 PM', '82'),
                    _buildPeakHour('4 PM', '79'),
                  ],
                ),
                SizedBox(height: AppDimensions.spacing3),
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacing3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      SizedBox(width: AppDimensions.spacing2),
                      Expanded(
                        child: Text(
                          'Consider limiting outdoor activities between 12 PM - 4 PM.',
                          style: TextStyle(
                            color: AppColors.gray80,
                            fontSize: AppDimensions.small,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: 400.ms).fade().slideY(begin: 0.3, end: 0),
          
          SizedBox(height: AppDimensions.spacing8),
        ],
      ),
    );
  }

  Widget _buildHistoricalTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Air Quality History',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fade().slideY(begin: 0.3, end: 0),
          
          SizedBox(height: AppDimensions.spacing4),
          
Container(
  height: 300,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
  ),
  padding: EdgeInsets.all(AppDimensions.spacing4),
  child: BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 100,
      minY: 0,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.white,
          tooltipRoundedRadius: 8,
          tooltipBorder: BorderSide(
            color: AppColors.gray40,
            width: 1,
          ),
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${_historicalData[groupIndex]['date']}\n',
              const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'AQI: ${_historicalData[groupIndex]['aqi']}',
                  style: TextStyle(
                    color: _getAqiColor(_historicalData[groupIndex]['aqi']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  _historicalData[value.toInt()]['date'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray70,
                  ),
                ),
              );
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray70,
                  ),
                ),
              );
            },
            reservedSize: 42,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.gray30,
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: AppColors.gray40),
      ),
      barGroups: _historicalData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        final aqi = data['aqi'] as int;
        
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: aqi.toDouble(),
              color: _getAqiColor(aqi),
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        );
      }).toList(),
    ),
  ),
).animate(delay: 100.ms).fade().slideY(begin: 0.3, end: 0),

SizedBox(height: AppDimensions.spacing6),

// Weekly summary
Container(
  width: double.infinity,
  padding: EdgeInsets.all(AppDimensions.spacing4),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Weekly Summary',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: AppDimensions.spacing4),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatistic('Avg', '66.6', AppColors.primary),
          _buildStatistic('Min', '48', AppColors.success),
          _buildStatistic('Max', '82', AppColors.danger),
        ],
      ),
      SizedBox(height: AppDimensions.spacing4),
      Row(
        children: [
          Icon(
            Icons.trending_flat,
            color: AppColors.primary,
            size: 20,
          ),
          SizedBox(width: AppDimensions.spacing2),
          Text(
            'Trend: Stable',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(height: AppDimensions.spacing4),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Averages:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray80,
                  ),
                ),
                SizedBox(height: AppDimensions.spacing2),
                Text('PM2.5: 14.5 μg/m³'),
                Text('PM10: 34.0 μg/m³'),
                Text('O3: 75.7 μg/m³'),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(AppDimensions.spacing3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Air Quality Assessment',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing2),
                  Text(
                    'Secara keseluruhan, kualitas udara tetap dalam kategori Sedang hampir setiap hari minggu ini, dengan satu hari Baik (27 Apr).',
                    style: TextStyle(
                      color: AppColors.gray80,
                      fontSize: AppDimensions.small,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  ),
).animate(delay: 200.ms).fade().slideY(begin: 0.3, end: 0),

SizedBox(height: AppDimensions.spacing6),

// Daily details
Text(
  'Daily Details',
  style: Theme.of(context).textTheme.titleLarge,
).animate(delay: 300.ms).fade().slideY(begin: 0.3, end: 0),

SizedBox(height: AppDimensions.spacing3),

// Daily detail cards
...List.generate(_historicalData.length, (index) => _buildDailyDetailCard(
  _historicalData[index]['date'] as String,
  _historicalData[index]['aqi'] as int,
  _historicalData[index]['category'] as String,
  index % 2 == 0 ? '8h' : '7.5h', // Dummy exposure time
)).animate(delay: 400.ms).fade().slideY(begin: 0.3, end: 0),

SizedBox(height: AppDimensions.spacing8),
      ],
    ),
  );
}

Widget _buildHealthEffectsTable() {
  return Table(
    border: TableBorder.all(
      color: AppColors.gray30,
      width: 1,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
    ),
    columnWidths: const {
      0: FlexColumnWidth(1),
      1: FlexColumnWidth(3),
    },
    children: [
      TableRow(
        decoration: BoxDecoration(
          color: AppColors.gray20,
        ),
        children: [
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacing2),
              child: const Text(
                'Kelompok',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacing2),
              child: const Text(
                'Dampak Kesehatan',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacing2),
              child: const Text(
                'Umum',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacing2),
              child: const Text(
                'Gejala yang diharapkan hanya sedikit atau tidak ada',
              ),
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacing2),
              child: const Text(
                'Peka',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacing2),
              child: const Text(
                'Gejala pernapasan seperti batuk atau sesak napas mungkin terjadi',
              ),
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacing2),
              child: const Text(
                'Anak-anak',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacing2),
              child: const Text(
                'Pertimbangkan untuk mengurangi aktivitas di luar ruangan dalam jangka waktu lama',
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildPollutantChip(String code, String label) {
  final bool isSelected = _selectedPollutant == code;
  
  return ChoiceChip(
    label: Text(label),
    selected: isSelected,
    onSelected: (selected) {
      if (selected) {
        setState(() {
          _selectedPollutant = code;
        });
      }
    },
    selectedColor: AppColors.primary.withOpacity(0.2),
    backgroundColor: Colors.grey[200],
    labelStyle: TextStyle(
      color: isSelected ? AppColors.primary : Colors.black87,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    ),
  );
}

Widget _buildStatistic(String label, String value, Color color) {
  return Column(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: AppDimensions.small,
          color: AppColors.gray60,
        ),
      ),
      SizedBox(height: AppDimensions.spacing1),
      Text(
        value,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ],
  );
}

Widget _buildPeakHour(String hour, String aqi) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spacing3,
      vertical: AppDimensions.spacing2,
    ),
    decoration: BoxDecoration(
      color: AppColors.danger.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
    child: Column(
      children: [
        Text(
          hour,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.gray80,
          ),
        ),
        Text(
          'AQI: $aqi',
          style: TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDailyDetailCard(String date, int aqi, String category, String exposureTime) {
  return Container(
    margin: EdgeInsets.only(bottom: AppDimensions.spacing3),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        onTap: () {
          // Navigate to daily detail view
        },
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacing3),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getAqiColor(aqi).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    aqi.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getAqiColor(aqi),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing1),
                    Text(
                      'AQI: $aqi ($category)',
                      style: TextStyle(
                        color: _getAqiColor(aqi),
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing1),
                    Text(
                      'Exposure time: $exposureTime',
                      style: TextStyle(
                        color: AppColors.gray60,
                        fontSize: AppDimensions.small,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.gray60,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  String text;
  switch (value.toInt()) {
    case 0:
      text = '12AM';
      break;
    case 4:
      text = '4AM';
      break;
    case 8:
      text = '8AM';
      break;
    case 12:
      text = '12PM';
      break;
    case 16:
      text = '4PM';
      break;
    case 20:
      text = '8PM';
      break;
    case 24:
      text = '12AM';
      break;
    default:
      return Container();
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: AppColors.gray70,
      ),
    ),
  );
}

Widget leftTitleWidgets(double value, TitleMeta meta) {
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(
      value.toInt().toString(),
      style: TextStyle(
        fontSize: 12,
        color: AppColors.gray70,
      ),
    ),
  );
}
}