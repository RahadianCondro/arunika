// lib/features/auth/health_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/primary_button.dart';
import '../../routes.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({Key? key}) : super(key: key);

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  int _age = 30;
  String _activityLevel = 'Moderate';
  final Map<String, bool> _healthConditions = {
    'Asthma': false,
    'Allergies': false,
    'Heart Disease': false,
    'COPD': false,
    'None': true,
  };
  
  final Map<String, double> _pollutantSensitivity = {
    'PM2.5': 3.0,
    'Ozone': 2.0,
  };
  
  bool _isLoading = false;

// lib/features/auth/health_profile_screen.dart (lanjutan)
  void _toggleHealthCondition(String condition) {
    setState(() {
      if (condition == 'None') {
        // If "None" is selected, deselect all others
        _healthConditions.forEach((key, value) {
          _healthConditions[key] = key == 'None';
        });
      } else {
        // If any other condition is selected, deselect "None"
        _healthConditions[condition] = !_healthConditions[condition]!;
        _healthConditions['None'] = false;
        
        // If no conditions are selected, select "None"
        if (_healthConditions.values.every((selected) => !selected)) {
          _healthConditions['None'] = true;
        }
      }
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // Navigate to dashboard on successful profile setup
          AppRoutes.navigateTo(context, AppRoutes.dashboard, replace: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.healthProfile),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacing6),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Let\'s set up your health profile to provide personalized recommendations.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ).animate().fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing6),
                  
                  // Age
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.age,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      SizedBox(height: AppDimensions.spacing2),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _age.toDouble(),
                              min: 1,
                              max: 100,
                              divisions: 99,
                              activeColor: AppColors.primary,
                              label: _age.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _age = value.toInt();
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 50,
                            padding: EdgeInsets.all(AppDimensions.spacing2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                              border: Border.all(color: AppColors.gray40),
                            ),
                            child: Text(
                              _age.toString(),
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate(delay: 100.ms).fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing6),
                  
                  // Health Conditions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.healthConditions,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      SizedBox(height: AppDimensions.spacing2),
                      Wrap(
                        spacing: AppDimensions.spacing3,
                        runSpacing: AppDimensions.spacing2,
                        children: _healthConditions.keys.map((condition) {
                          return FilterChip(
                            label: Text(condition),
                            selected: _healthConditions[condition]!,
                            onSelected: (_) => _toggleHealthCondition(condition),
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                            side: BorderSide(
                              color: _healthConditions[condition]!
                                  ? AppColors.primary
                                  : AppColors.gray40,
                            ),
                            labelStyle: TextStyle(
                              color: _healthConditions[condition]!
                                  ? AppColors.primary
                                  : AppColors.gray80,
                              fontWeight: _healthConditions[condition]!
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ).animate(delay: 200.ms).fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing6),
                  
                  // Activity Level
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.activityLevel,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      SizedBox(height: AppDimensions.spacing2),
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Low'),
                            value: 'Low',
                            groupValue: _activityLevel,
                            onChanged: (value) {
                              setState(() {
                                _activityLevel = value!;
                              });
                            },
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<String>(
                            title: const Text('Moderate'),
                            value: 'Moderate',
                            groupValue: _activityLevel,
                            onChanged: (value) {
                              setState(() {
                                _activityLevel = value!;
                              });
                            },
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<String>(
                            title: const Text('High'),
                            value: 'High',
                            groupValue: _activityLevel,
                            onChanged: (value) {
                              setState(() {
                                _activityLevel = value!;
                              });
                            },
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ).animate(delay: 300.ms).fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing6),
                  
                  // Pollutant Sensitivity
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.pollutantSensitivity,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      SizedBox(height: AppDimensions.spacing4),
                      
                      // PM2.5 Sensitivity
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'PM2.5:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              SizedBox(width: AppDimensions.spacing4),
                              Row(
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _pollutantSensitivity['PM2.5'] = (index + 1).toDouble();
                                      });
                                    },
                                    child: Icon(
                                      Icons.circle,
                                      color: index < _pollutantSensitivity['PM2.5']!.toInt()
                                          ? AppColors.primary
                                          : AppColors.gray40,
                                      size: 16,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimensions.spacing2),
                          
                          // Ozone Sensitivity
                          Row(
                            children: [
                              Text(
                                'Ozone:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              SizedBox(width: AppDimensions.spacing4),
                              Row(
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _pollutantSensitivity['Ozone'] = (index + 1).toDouble();
                                      });
                                    },
                                    child: Icon(
                                      Icons.circle,
                                      color: index < _pollutantSensitivity['Ozone']!.toInt()
                                          ? AppColors.primary
                                          : AppColors.gray40,
                                      size: 16,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ).animate(delay: 400.ms).fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing8),
                  
                  // Save button
                  PrimaryButton(
                    text: AppStrings.save,
                    onPressed: _saveProfile,
                    isLoading: _isLoading,
                  ).animate(delay: 500.ms).fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing6),
                  
                  // Skip for now option
                  Center(
                    child: TextButton(
                      onPressed: () {
                        AppRoutes.navigateTo(context, AppRoutes.dashboard, replace: true);
                      },
                      child: const Text('Skip for now'),
                    ),
                  ).animate(delay: 600.ms).fade(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}