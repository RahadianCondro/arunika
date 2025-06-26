// lib/features/dashboard/forecast_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({Key? key}) : super(key: key);

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  // Data dummy untuk forecasting
  final String _trend = 'Improving';
  final List<FlSpot> _aqiData = [
    FlSpot(0, 75),  // Now
    FlSpot(1, 72),  // +1h
    FlSpot(2, 68),  // +2h
    FlSpot(3, 65),  // +3h
    FlSpot(4, 63),  // +4h
    FlSpot(5, 60),  // +5h
    FlSpot(6, 58),  // +6h
    FlSpot(7, 55),  // +7h
    FlSpot(8, 52),  // +8h
    FlSpot(9, 50),  // +9h
    FlSpot(10, 48), // +10h
    FlSpot(11, 45), // +11h
    FlSpot(12, 42), // +12h
    FlSpot(13, 40), // +13h
    FlSpot(14, 38), // +14h
    FlSpot(15, 42), // +15h
    FlSpot(16, 45), // +16h
    FlSpot(17, 48), // +17h
    FlSpot(18, 52), // +18h
    FlSpot(19, 55), // +19h
    FlSpot(20, 58), // +20h
    FlSpot(21, 60), // +21h
    FlSpot(22, 58), // +22h
    FlSpot(23, 56), // +23h
    FlSpot(24, 55), // +24h
  ];
  
  final List<Map<String, dynamic>> _hourlyForecast = [
    {
      'hour': '10:00',
      'aqi': 72,
      'primary': 'O3',
    },
    {
      'hour': '11:00',
      'aqi': 68,
      'primary': 'O3',
    },
    {
      'hour': '12:00',
      'aqi': 65,
      'primary': 'O3',
    },
    {
      'hour': '13:00',
      'aqi': 63,
      'primary': 'O3',
    },
    {
      'hour': '14:00',
      'aqi': 60,
      'primary': 'PM2.5',
    },
    {
      'hour': '15:00',
      'aqi': 58,
      'primary': 'PM2.5',
    },
  ];
  
  final List<Map<String, dynamic>> _dailyForecast = [
    {
      'date': 'Tomorrow',
      'min': 45,
      'max': 78,
      'category': 'Moderate',
    },
    {
      'date': 'Wed',
      'min': 40,
      'max': 65,
      'category': 'Moderate',
    },
    {
      'date': 'Thu',
      'min': 35,
      'max': 58,
      'category': 'Good',
    },
    {
      'date': 'Fri',
      'min': 42,
      'max': 70,
      'category': 'Moderate',
    },
    {
      'date': 'Sat',
      'min': 48,
      'max': 82,
      'category': 'Moderate',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality Forecast'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trend info
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
                          Text(
                            'Today\'s Trend: ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            _trend,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: AppDimensions.spacing2),
                          Icon(
                            Icons.trending_down,
                            color: AppColors.success,
                            size: 20,
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spacing3),
                      Text(
                        'Air quality is expected to improve in the next 12 hours as wind speeds increase.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Hourly Forecast title
                Text(
                  'Hourly Forecast',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate(delay: 100.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing4),
                
                // Hourly Chart
                Container(
                  height: 200,
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
                    ),
                  ),
                ).animate(delay: 200.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Hourly breakdown
                ...buildHourlyForecastWidgets().animate(delay: 300.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Daily Forecast title
                Text(
                  'Daily Forecast',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate(delay: 400.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing4),
                
                // Daily Forecast
                ...buildDailyForecastWidgets().animate(delay: 500.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing8),
                
                // Best time recommendations
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
                        'Best Time for Outdoor Activities',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spacing4),
                      Row(
                        children: [
                          _buildTimeRangeChip('06:00 - 08:00', AppColors.aqiGood),
                          SizedBox(width: AppDimensions.spacing2),
                          _buildTimeRangeChip('17:00 - 19:00', AppColors.aqiModerate),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 600.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildHourlyForecastWidgets() {
    List<Widget> widgets = [];
    
    for (int i = 0; i < _hourlyForecast.length; i++) {
      final forecast = _hourlyForecast[i];
      final hour = forecast['hour'];
      final aqi = forecast['aqi'];
      final primary = forecast['primary'];
      
      Color aqiColor;
      if (aqi <= 50) {
        aqiColor = AppColors.aqiGood;
      } else if (aqi <= 100) {
        aqiColor = AppColors.aqiModerate;
      } else if (aqi <= 150) {
        aqiColor = AppColors.aqiUnhealthySensitive;
      } else {
        aqiColor = AppColors.aqiUnhealthy;
      }
      
      widgets.add(
        Container(
          padding: EdgeInsets.all(AppDimensions.spacing3),
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
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: aqiColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    aqi.toString(),
                    style: TextStyle(
                      color: aqiColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hour,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Primary: $primary',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing3,
                  vertical: AppDimensions.spacing1,
                ),
                decoration: BoxDecoration(
                  color: aqiColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
                child: Text(
                  _getAqiCategory(aqi),
                  style: TextStyle(
                    color: aqiColor,
                    fontSize: AppDimensions.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return widgets;
  }

  String _getAqiCategory(int aqi) {
    if (aqi <= 50) return 'GOOD';
    if (aqi <= 100) return 'MODERATE';
    if (aqi <= 150) return 'UNHEALTHY FOR SENSITIVE';
    if (aqi <= 200) return 'UNHEALTHY';
    if (aqi <= 300) return 'VERY UNHEALTHY';
    return 'HAZARDOUS';
  }

  List<Widget> buildDailyForecastWidgets() {
    List<Widget> widgets = [];
    
    for (var forecast in _dailyForecast) {
      final date = forecast['date'];
      final min = forecast['min'];
      final max = forecast['max'];
      final category = forecast['category'];
      
      Color categoryColor;
      if (category == 'Good') {
        categoryColor = AppColors.aqiGood;
      } else if (category == 'Moderate') {
        categoryColor = AppColors.aqiModerate;
      } else if (category == 'Unhealthy for Sensitive Groups') {
        categoryColor = AppColors.aqiUnhealthySensitive;
      } else {
        categoryColor = AppColors.aqiUnhealthy;
      }
      
      widgets.add(
        Container(
          padding: EdgeInsets.all(AppDimensions.spacing3),
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
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  date,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.gray30,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                          ),
                        ),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width * 0.6 * ((max - min) / 100),
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.6 * (min / 100)),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spacing2),
                    Row(
                      children: [
                        Text(
                          'Min: $min',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(width: AppDimensions.spacing2),
                        Text(
                          'Max: $max',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
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
                  category.toUpperCase(),
                  style: TextStyle(
                    color: categoryColor,
                    fontSize: AppDimensions.caption,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return widgets;
  }
  
  Widget _buildTimeRangeChip(String timeRange, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing3,
        vertical: AppDimensions.spacing2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        timeRange,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Now';
        break;
      case 4:
        text = '+4h';
        break;
      case 8:
        text = '+8h';
        break;
      case 12:
        text = '+12h';
        break;
      case 16:
        text = '+16h';
        break;
      case 20:
        text = '+20h';
        break;
      case 24:
        text = '+24h';
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