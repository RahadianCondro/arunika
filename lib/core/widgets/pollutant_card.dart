// lib/core/widgets/pollutant_card.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class PollutantCard extends StatelessWidget {
  final String name;
  final double value;
  final String unit;
  final String category;
  final Color color;
  final double percentage;

  const PollutantCard({
    Key? key,
    required this.name,
    required this.value,
    required this.unit,
    required this.category,
    required this.color,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Wrap name in Flexible to prevent overflow
              Flexible(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Add some spacing between name and value
              SizedBox(width: AppDimensions.spacing2),
              // Wrap value/unit in Flexible to prevent overflow
              Flexible(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$value ',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: unit,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing2),
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
                width: MediaQuery.of(context).size.width * percentage * 0.85,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing2),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing3,
                vertical: AppDimensions.spacing1,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: AppDimensions.caption,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}