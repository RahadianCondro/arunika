// lib/features/health/exposure_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/exposure_history.dart';
import '../../data/repositories/exposure_repository.dart';

class ExposureTrackingScreen extends StatefulWidget {
  const ExposureTrackingScreen({Key? key}) : super(key: key);

  @override
  State<ExposureTrackingScreen> createState() => _ExposureTrackingScreenState();
}

class _ExposureTrackingScreenState extends State<ExposureTrackingScreen> {

  final ExposureRepository _repository = ExposureRepository();
  
  late Future<List<ExposureHistory>> _exposureHistoryFuture;
  late Future<Map<String, double>> _weeklyAveragesFuture;
  late Future<String> _weeklyTrendFuture;
  
  String _formatNumericValue(dynamic value) {
  if (value is double) {
    return value.toStringAsFixed(1); // Hanya tampilkan 1 angka desimal
  } else if (value is int) {
    return value.toString();
  } else {
    try {
      // Coba parse sebagai double terlebih dahulu
      return double.parse(value.toString()).toStringAsFixed(1);
    } catch (e) {
      return value.toString();
    }
  }
}

  String _selectedTimeframe = 'weekly'; // daily, weekly, monthly
  String _selectedMetric = 'AQI'; // AQI, PM2_5, PM10, O3
  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _endDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    setState(() {
      _exposureHistoryFuture = _repository.getDailyExposure(_startDate, _endDate);
      _weeklyAveragesFuture = _repository.getWeeklyAverages();
      _weeklyTrendFuture = _repository.getWeeklyTrend();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exposure Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeframe selection
              Padding(
                padding: EdgeInsets.all(AppDimensions.spacing4),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.spacing3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Timeframe',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimensions.small,
                            color: AppColors.gray70,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spacing2),
                        Row(
                          children: [
                            _buildTimeframeButton('daily', 'Daily'),
                            SizedBox(width: AppDimensions.spacing2),
                            _buildTimeframeButton('weekly', 'Weekly'),
                            SizedBox(width: AppDimensions.spacing2),
                            _buildTimeframeButton('monthly', 'Monthly'),
                          ],
                        ),
                        SizedBox(height: AppDimensions.spacing3),
                        Text(
                          'Apr 25 - May 1, 2025',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Weekly Summary
              FutureBuilder<Map<String, double>>(
                future: _weeklyAveragesFuture,
                builder: (context, averagesSnapshot) {
                  return FutureBuilder<String>(
                    future: _weeklyTrendFuture,
                    builder: (context, trendSnapshot) {
                      if (averagesSnapshot.connectionState == ConnectionState.waiting ||
                          trendSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppDimensions.spacing4),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      if (averagesSnapshot.hasError || trendSnapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppDimensions.spacing4),
                            child: Text('Error loading data'),
                          ),
                        );
                      }
                      
                      final averages = averagesSnapshot.data!;
                      final trend = trendSnapshot.data!;
                      
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppDimensions.spacing4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weekly Summary',
                                  style: TextStyle(
                                    fontSize: AppDimensions.heading4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.spacing4),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatisticWidget('AQI', _formatNumericValue(averages['AQI']!), _getAqiColor(averages['AQI']!.toInt())),
                                    SizedBox(width: AppDimensions.spacing3),
                                    _buildStatisticWidget('PM2.5', '${_formatNumericValue(averages['PM2_5']!)} μg/m³', AppColors.primary),
                                    SizedBox(width: AppDimensions.spacing3),
                                    _buildStatisticWidget('PM10', '${_formatNumericValue(averages['PM10']!)} μg/m³', AppColors.primary),
                                    SizedBox(width: AppDimensions.spacing3),
                                    _buildStatisticWidget('O3', '${_formatNumericValue(averages['O3']!)} μg/m³', AppColors.primary),
                                  ],
                                ),
                              ),
                                SizedBox(height: AppDimensions.spacing4),
                                Row(
                                  children: [
                                    Icon(
                                      trend == 'Improving' ? Icons.trending_down :
                                      trend == 'Worsening' ? Icons.trending_up :
                                      Icons.trending_flat,
                                      color: trend == 'Improving' ? AppColors.success :
                                             trend == 'Worsening' ? AppColors.danger :
                                             AppColors.primary,
                                    ),
                                    SizedBox(width: AppDimensions.spacing2),
                                    Text(
                                      'Trend: $trend',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: trend == 'Improving' ? AppColors.success :
                                               trend == 'Worsening' ? AppColors.danger :
                                               AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fade().slideY(begin: 0.2, end: 0);
                    },
                  );
                },
              ),
              
              SizedBox(height: AppDimensions.spacing4),
              
              // Chart Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exposure Chart',
                      style: TextStyle(
                        fontSize: AppDimensions.heading4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedMetric,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      style: TextStyle(color: AppColors.primary),
                      underline: Container(
                        height: 2,
                        color: AppColors.primary,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMetric = newValue!;
                        });
                      },
                      items: ['AQI', 'PM2_5', 'PM10', 'O3']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.replaceAll('_', '.')),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppDimensions.spacing3),
              
              // Exposure Chart
              Container(
                height: 250,
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                child: FutureBuilder<List<ExposureHistory>>(
                  future: _exposureHistoryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading chart data'));
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data available'));
                    }
                    
                    final exposureData = snapshot.data!;
                    return _buildExposureChart(exposureData);
                  },
                ),
              ).animate().fade().slideY(begin: 0.3, end: 0, delay: Duration(milliseconds: 200)),
              
              SizedBox(height: AppDimensions.spacing6),
              
              // Daily Details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                child: Text(
                  'Daily Details',
                  style: TextStyle(
                    fontSize: AppDimensions.heading4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(height: AppDimensions.spacing3),
              
              // Daily cards
              FutureBuilder<List<ExposureHistory>>(
                future: _exposureHistoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spacing4),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spacing4),
                        child: Text('Error loading daily details'),
                      ),
                    );
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spacing4),
                        child: Text('No daily data available'),
                      ),
                    );
                  }
                  
                  final exposureData = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: exposureData.length,
                    itemBuilder: (context, index) {
                      final exposure = exposureData[index];
                      return _buildDailyExposureCard(exposure, index);
                    },
                  );
                },
              ),
              
              SizedBox(height: AppDimensions.spacing6),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTimeframeButton(String value, String label) {
    final bool isSelected = _selectedTimeframe == value;
    
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedTimeframe = value;
            
            // Adjust date range based on selected timeframe
            _endDate = DateTime.now();
            if (value == 'daily') {
              _startDate = _endDate.subtract(Duration(days: 1));
            } else if (value == 'weekly') {
              _startDate = _endDate.subtract(Duration(days: 7));
            } else if (value == 'monthly') {
              _startDate = _endDate.subtract(Duration(days: 30));
            }
            
            _loadData();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : AppColors.gray20,
          foregroundColor: isSelected ? Colors.white : AppColors.gray70,
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
        child: Text(label),
      ),
    );
  }
  
  Widget _buildStatisticWidget(String label, String value, Color color) {
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
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
  
  Widget _buildExposureChart(List<ExposureHistory> data) {
    List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < data.length; i++) {
      final exposure = data[i];
      double value;
      
      if (_selectedMetric == 'AQI') {
        value = exposure.averageAqi.toDouble();
      } else if (_selectedMetric == 'PM2_5') {
        value = exposure.pollutants['PM2_5']!.average;
      } else if (_selectedMetric == 'PM10') {
        value = exposure.pollutants['PM10']!.average;
      } else { // O3
        value = exposure.pollutants['O3']!.average;
      }
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: _selectedMetric == 'AQI' ? _getAqiColor(value.toInt()) : AppColors.primary,
              width: 15,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
      );
    }
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacing4),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxYValue(data),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.white,
                tooltipRoundedRadius: 8,
                tooltipBorder: BorderSide(
                  color: AppColors.gray40,
                  width: 1,
                ),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String tooltipText;
                  final exposure = data[group.x.toInt()];
                  final date = exposure.date;
                  
                  if (_selectedMetric == 'AQI') {
                    tooltipText = '${exposure.averageAqi} AQI';
                  } else if (_selectedMetric == 'PM2_5') {
                    tooltipText = '${_formatNumericValue(exposure.pollutants['PM2_5']!.average)} μg/m³';
                  } else if (_selectedMetric == 'PM10') {
                    tooltipText = '${_formatNumericValue(exposure.pollutants['PM10']!.average)} μg/m³';
                  } else { // O3
                    tooltipText = '${_formatNumericValue(exposure.pollutants['O3']!.average)} μg/m³';
                  }
                  
                  return BarTooltipItem(
                    '$date\n',
                    TextStyle(
                      color: AppColors.gray80,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: tooltipText,
                        style: TextStyle(
                          color: _selectedMetric == 'AQI' ? 
                            _getAqiColor(data[group.x.toInt()].averageAqi) : 
                            AppColors.primary,
                          fontWeight: FontWeight.bold,
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
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) return SizedBox();
                    
                    final exposure = data[index];
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        _getShortDate(exposure.date),
                        style: TextStyle(
                          fontSize: 10,
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
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.gray70,
                        ),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                left: BorderSide(color: AppColors.gray30),
                bottom: BorderSide(color: AppColors.gray30),
              ),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.gray20,
                strokeWidth: 1,
              ),
              drawVerticalLine: false,
            ),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }
  
  double _getMaxYValue(List<ExposureHistory> data) {
    if (data.isEmpty) return 100;
    
    if (_selectedMetric == 'AQI') {
      return data.map((e) => e.averageAqi.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2;
    } else if (_selectedMetric == 'PM2_5') {
      return data.map((e) => e.pollutants['PM2_5']!.average).reduce((a, b) => a > b ? a : b) * 1.2;
    } else if (_selectedMetric == 'PM10') {
      return data.map((e) => e.pollutants['PM10']!.average).reduce((a, b) => a > b ? a : b) * 1.2;
    } else { // O3
      return data.map((e) => e.pollutants['O3']!.average).reduce((a, b) => a > b ? a : b) * 1.2;
    }
  }
  
  String _getShortDate(String dateStr) {
    // Convert from "2025-04-25" to "Apr 25"
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    
    final date = DateTime(year, month, day);
    return DateFormat('MMM d').format(date);
  }
  
  Widget _buildDailyExposureCard(ExposureHistory exposure, int index) {
    final dateStr = exposure.date;
    final aqi = exposure.averageAqi;
    final aqiCategory = _getAqiCategory(aqi);
    final aqiColor = _getAqiColor(aqi);
    
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing4,
        vertical: AppDimensions.spacing2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      elevation: 1,
      child: InkWell(
        onTap: () => _showDailyDetails(exposure),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacing3),
          child: Row(
            children: [
              // AQI indicator
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
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing1),
                    Text(
'AQI: $aqi ($aqiCategory)',
                      style: TextStyle(
                        color: aqiColor,
                        fontSize: AppDimensions.small,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing1),
                    Text(
                      'Exposure time: ${_getExposureTime(exposure)}',
                      style: TextStyle(
                        color: AppColors.gray60,
                        fontSize: AppDimensions.caption,
                      ),
                    ),
                  ],
                ),
              ),
              // Navigate indicator
              Icon(
                Icons.chevron_right,
                color: AppColors.gray60,
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.1, end: 0, delay: Duration(milliseconds: 100 * index));
  }
  
  String _getExposureTime(ExposureHistory exposure) {
    // Find total duration from all locations
    double totalHours = 0;
    for (var location in exposure.locations) {
      totalHours += location.duration;
    }
    
    if (totalHours == 0) {
      return "No exposure";
    } else if (totalHours < 1) {
      return "${(totalHours * 60).toInt()} min";
    } else {
      return "${totalHours.toStringAsFixed(1)}h";
    }
  }
  
  void _showDailyDetails(ExposureHistory exposure) {
    final date = exposure.date;
    final aqi = exposure.averageAqi;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray40,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppDimensions.spacing2),
                    decoration: BoxDecoration(
                      color: _getAqiColor(aqi).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: _getAqiColor(aqi),
                      size: 28,
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
                            fontSize: AppDimensions.heading3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Exposure Details',
                          style: TextStyle(
                            fontSize: AppDimensions.small,
                            color: AppColors.gray60,
                          ),
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
                      color: _getAqiColor(aqi).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                      border: Border.all(
                        color: _getAqiColor(aqi),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'AQI: $aqi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getAqiColor(aqi),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDimensions.spacing4),
            
            // Pollutant Exposure
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
              child: Text(
                'Pollutant Exposure:',
                style: TextStyle(
                  fontSize: AppDimensions.heading4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: AppDimensions.spacing3),
            
            // PM2.5
            if (exposure.pollutants.containsKey('PM2_5'))
              _buildPollutantExposureBar(
                'PM2.5',
                exposure.pollutants['PM2_5']!.average,
                exposure.pollutants['PM2_5']!.peak,
                'μg/m³',
                35.0, // WHO guideline
              ),
              
            // PM10
            if (exposure.pollutants.containsKey('PM10'))
              _buildPollutantExposureBar(
                'PM10',
                exposure.pollutants['PM10']!.average,
                exposure.pollutants['PM10']!.peak,
                'μg/m³',
                50.0, // WHO guideline
              ),
              
            // O3
            if (exposure.pollutants.containsKey('O3'))
              _buildPollutantExposureBar(
                'Ozone (O₃)',
                exposure.pollutants['O3']!.average,
                exposure.pollutants['O3']!.peak,
                'μg/m³',
                100.0, // WHO guideline
              ),
            
            SizedBox(height: AppDimensions.spacing6),
            
            // Location Exposure
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
              child: Text(
                'Location Exposure:',
                style: TextStyle(
                  fontSize: AppDimensions.heading4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: AppDimensions.spacing3),
            
            // Location pie chart
            Container(
              height: 200,
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
              child: _buildLocationChart(exposure.locations),
            ),
            
            SizedBox(height: AppDimensions.spacing4),
            
            // Location details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                child: ListView.builder(
                  itemCount: exposure.locations.length,
                  itemBuilder: (context, index) {
                    final location = exposure.locations[index];
                    return _buildLocationExposureItem(location);
                  },
                ),
              ),
            ),
            
            // Action buttons
            Padding(
              padding: EdgeInsets.all(AppDimensions.spacing4),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.share),
                      label: Text('Share Report'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacing3),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to recommendations based on this day's exposure
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.favorite),
                      label: Text('Get Advice'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
                      ),
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
  
  Widget _buildPollutantExposureBar(String name, double average, double peak, String unit, double guideline) {
    // Calculate percentage for progress bar (capped at 100%)
    final avgPercentage = (average / guideline * 100).clamp(0, 100);
    final peakPercentage = (peak / guideline * 100).clamp(0, 100);
    
    // Determine status color based on average percentage
    Color statusColor;
    
    if (avgPercentage <= 50) {
      statusColor = AppColors.aqiGood;
    } else if (avgPercentage <= 100) {
      statusColor = AppColors.aqiModerate;
    } else if (avgPercentage <= 150) {
      statusColor = AppColors.aqiUnhealthySensitive;
    } else {
      statusColor = AppColors.aqiUnhealthy;
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing4,
        vertical: AppDimensions.spacing2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
              'Rata-rata: ${_formatNumericValue(average)} $unit | Puncak: ${_formatNumericValue(peak)} $unit',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: AppDimensions.small,
              ),
            ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing2),
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.gray20,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            child: Stack(
              children: [
                // Average bar
                FractionallySizedBox(
                  widthFactor: avgPercentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                  ),
                ),
                // Peak marker
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.87 * (peakPercentage / 100) - 5,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.spacing1),
          Text(
            'WHO guideline: $guideline $unit',
            style: TextStyle(
              color: AppColors.gray60,
              fontSize: AppDimensions.caption,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationChart(List<LocationExposure> locations) {
    // Generate data for pie chart
    List<PieChartSectionData> sections = [];
    
    // Define colors for different locations
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.success,
      AppColors.warning,
    ];
    
    // Calculate total duration
    double totalDuration = 0;
    for (var location in locations) {
      totalDuration += location.duration;
    }
    
    // Create sections for each location
    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];
      final percentage = (location.duration / totalDuration * 100);
      
      sections.add(
        PieChartSectionData(
          value: location.duration,
          title: '${percentage.toStringAsFixed(0)}%',
          color: colors[i % colors.length],
          radius: 90,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < locations.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: AppDimensions.spacing2),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacing2),
                      Expanded(
                        child: Text(
                          locations[i].name,
                          style: TextStyle(
                            fontSize: AppDimensions.small,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLocationExposureItem(LocationExposure location) {
    return Card(
      elevation: 0,
      color: AppColors.gray10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      margin: EdgeInsets.only(bottom: AppDimensions.spacing2),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing3,
          vertical: AppDimensions.spacing2,
        ),
        child: Row(
          children: [
            Icon(
              _getLocationIcon(location.name),
              color: AppColors.primary,
            ),
            SizedBox(width: AppDimensions.spacing2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${location.duration}h exposure',
                    style: TextStyle(
                      fontSize: AppDimensions.small,
                      color: AppColors.gray70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing2,
                vertical: AppDimensions.spacing1,
              ),
              decoration: BoxDecoration(
                color: _getAqiColor(location.aqi).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Text(
                'AQI: ${location.aqi}',
                style: TextStyle(
                  fontSize: AppDimensions.small,
                  fontWeight: FontWeight.bold,
                  color: _getAqiColor(location.aqi),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getLocationIcon(String name) {
    if (name.toLowerCase().contains('home')) {
      return Icons.home;
    } else if (name.toLowerCase().contains('work')) {
      return Icons.work;
    } else if (name.toLowerCase().contains('commute')) {
      return Icons.commute;
    } else if (name.toLowerCase().contains('market') || name.toLowerCase().contains('mall')) {
      return Icons.shopping_cart;
    } else if (name.toLowerCase().contains('park')) {
      return Icons.park;
    } else if (name.toLowerCase().contains('gym')) {
      return Icons.fitness_center;
    } else {
      return Icons.location_on;
    }
  }
  
  void _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _loadData();
      });
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
  
  String _getAqiCategory(int aqi) {
    if (aqi <= 50) {
      return 'Good';
    } else if (aqi <= 100) {
      return 'Moderate';
    } else if (aqi <= 150) {
      return 'Unhealthy for Sensitive';
    } else if (aqi <= 200) {
      return 'Unhealthy';
    } else if (aqi <= 300) {
      return 'Very Unhealthy';
    } else {
      return 'Hazardous';
    }
  }
}