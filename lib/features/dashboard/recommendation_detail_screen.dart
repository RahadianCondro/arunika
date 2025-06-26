// lib/features/dashboard/recommendation_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/recommendation.dart';

class RecommendationDetailScreen extends StatelessWidget {
  final Recommendation recommendation;
  
  const RecommendationDetailScreen({
    Key? key,
    required this.recommendation,
  }) : super(key: key);

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'important':
        return AppColors.danger;
      case 'moderate':
        return AppColors.warning;
      case 'low':
      case 'informational':
        return AppColors.info;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle potential null recommendation (defensive programming)
    if (recommendation == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recommendation Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: AppColors.danger),
              const SizedBox(height: 16),
              const Text(
                'Recommendation data not available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final Color severityColor = _getSeverityColor(recommendation.severity);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(recommendation.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDimensions.spacing4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        recommendation.iconData,
                        color: severityColor,
                        size: 36,
                      ),
                      SizedBox(width: AppDimensions.spacing3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendation.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: severityColor,
                              ),
                            ),
                            Text(
                              recommendation.severity.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: severityColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate(delay: 100.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing3),
                
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDimensions.spacing4),
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
                  child: Text(
                    recommendation.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ).animate(delay: 200.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Recommended Actions
                Text(
                  'Recommended Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate(delay: 300.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing3),
                
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDimensions.spacing4),
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
                    children: recommendation.actions.map((action) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppDimensions.spacing3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 20,
                            ),
                            SizedBox(width: AppDimensions.spacing2),
                            Expanded(
                              child: Text(
                                action,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ).animate(delay: 400.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Applies To
                Text(
                  'Applies To',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate(delay: 500.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing3),
                
                Wrap(
                  spacing: AppDimensions.spacing2,
                  runSpacing: AppDimensions.spacing2,
                  children: recommendation.appliesTo.map((item) {
                    return Chip(
                      label: Text(
                        _capitalizeFirst(item),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    );
                  }).toList(),
                ).animate(delay: 600.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Feedback
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDimensions.spacing4),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Was this helpful?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: AppDimensions.spacing3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // Handle feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Thank you for your feedback!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            icon: Icon(Icons.thumb_up),
                            label: Text('Yes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          SizedBox(width: AppDimensions.spacing4),
                          OutlinedButton.icon(
                            onPressed: () {
                              // Handle feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Thank you for your feedback!'),
                                  backgroundColor: AppColors.info,
                                ),
                              );
                            },
                            icon: Icon(Icons.thumb_down),
                            label: Text('No'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 700.ms).fade().slideY(begin: 0.3, end: 0),
                
                SizedBox(height: AppDimensions.spacing8),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
}