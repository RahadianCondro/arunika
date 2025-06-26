// lib/core/widgets/best_time_widget.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class TimeRange {
  final String start;
  final String end;
  final String quality;

  TimeRange({
    required this.start,
    required this.end,
    required this.quality,
  });
}

class BestTimeWidget extends StatelessWidget {
  final String activityType;
  final List<TimeRange> timeRanges;

  const BestTimeWidget({
    Key? key,
    required this.activityType,
    required this.timeRanges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              Icon(
                _getActivityIcon(),
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(  // Add Expanded to prevent overflow
                child: Text(
                  _getActivityTitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,  // Add text overflow
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing3),
          _buildTimelineView(context),
          SizedBox(height: AppDimensions.spacing3),
          _buildTimeRangeList(),
        ],
      ),
    );
  }

  IconData _getActivityIcon() {
    switch (activityType) {
      case 'outdoor_activity':
        return Icons.directions_run;
      case 'commute':
        return Icons.directions_car;
      case 'ventilation':
        return Icons.window;
      default:
        return Icons.access_time;
    }
  }

  String _getActivityTitle() {
    switch (activityType) {
      case 'outdoor_activity':
        return 'Waktu Terbaik untuk Aktivitas Outdoor';
      case 'commute':
        return 'Waktu Terbaik untuk Perjalanan';
      case 'ventilation':
        return 'Waktu Terbaik untuk Ventilasi';
      default:
        return 'Rekomendasi Waktu';
    }
  }

  Widget _buildTimelineView(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final timelineWidth = screenWidth - (AppDimensions.spacing4 * 4);
    
    return Container(
      height: 70,
      width: double.infinity,
      child: Stack(
        children: [
          // Timeline line
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray30,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
          ),
          
          // Time markers
          Positioned(
            top: 37,
            left: 0,
            child: _buildTimeMarker('00:00'),
          ),
          Positioned(
            top: 37,
            left: timelineWidth * 0.25,
            child: _buildTimeMarker('06:00'),
          ),
          Positioned(
            top: 37,
            left: timelineWidth * 0.5,
            child: _buildTimeMarker('12:00'),
          ),
          Positioned(
            top: 37,
            left: timelineWidth * 0.75,
            child: _buildTimeMarker('18:00'),
          ),
          Positioned(
            top: 37,
            right: 0,
            child: _buildTimeMarker('24:00'),
          ),
          
          // Time ranges
          for (var range in timeRanges) _buildTimeRangeIndicator(range, timelineWidth),
        ],
      ),
    );
  }

  Widget _buildTimeMarker(String time) {
    return Column(
      children: [
        Container(
          width: 2,
          height: 8,
          color: AppColors.gray50,
        ),
        SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.gray60,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeIndicator(TimeRange range, double timelineWidth) {
    // Convert times to hours (as fraction of 24)
    final startParts = range.start.split(':');
    final endParts = range.end.split(':');
    
    final startHour = int.parse(startParts[0]) + (startParts.length > 1 ? int.parse(startParts[1]) / 60 : 0);
    final endHour = int.parse(endParts[0]) + (endParts.length > 1 ? int.parse(endParts[1]) / 60 : 0);
    
    // Calculate positions on timeline
    final startPos = (startHour / 24) * timelineWidth;
    final endPos = (endHour / 24) * timelineWidth;
    final width = endPos - startPos;
    
    // Determine color
    Color color;
    if (range.quality.toLowerCase() == 'good') {
      color = AppColors.success;
    } else if (range.quality.toLowerCase() == 'moderate') {
      color = AppColors.warning;
    } else {
      color = AppColors.danger;
    }
    
    return Positioned(
      top: 24,
      left: startPos,
      child: Container(
        width: width,
        height: 16,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
      ),
    );
  }

  Widget _buildTimeRangeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: timeRanges.map((range) {
        Color color;
        if (range.quality.toLowerCase() == 'good') {
          color = AppColors.success;
        } else if (range.quality.toLowerCase() == 'moderate') {
          color = AppColors.warning;
        } else {
          color = AppColors.danger;
        }
        
        return Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.spacing2),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Text(
                '${range.start} - ${range.end}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Flexible(  // Add Flexible to prevent overflow
                child: Text(
                  '(${range.quality})',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,  // Add text overflow
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}