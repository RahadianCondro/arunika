// lib/features/auth/health_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _nameController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _loadHealthProfile();
  }

  Future<void> _loadHealthProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('health_profiles').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _age = data['age'] ?? 30;
          _activityLevel = data['activityLevel'] ?? 'Moderate';

          final conditions = List<String>.from(data['healthConditions'] ?? []);
          _healthConditions.updateAll((key, value) => conditions.contains(key));

          final sensitivity = Map<String, dynamic>.from(data['pollutantSensitivity'] ?? {});
          _pollutantSensitivity.updateAll((key, value) => sensitivity[key]?.toDouble() ?? value);
        });
      }
    }
  }

  void _toggleHealthCondition(String condition) {
    setState(() {
      if (condition == 'None') {
        _healthConditions.forEach((key, value) {
          _healthConditions[key] = key == 'None';
        });
      } else {
        _healthConditions[condition] = !_healthConditions[condition]!;
        _healthConditions['None'] = false;
        if (_healthConditions.values.every((selected) => !selected)) {
          _healthConditions['None'] = true;
        }
      }
    });
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final selectedConditions = _healthConditions.entries
          .where((entry) => entry.value && entry.key != 'None')
          .map((entry) => entry.key)
          .toList();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final data = {
          'name': _nameController.text.trim(),
          'age': _age,
          'activityLevel': _activityLevel,
          'healthConditions': selectedConditions.isEmpty ? ['None'] : selectedConditions,
          'pollutantSensitivity': _pollutantSensitivity,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('health_profiles')
            .doc(uid)
            .set(data, SetOptions(merge: true));
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      AppRoutes.navigateTo(context, AppRoutes.dashboard, replace: true);
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
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Name cannot be empty' : null,
                  ),
                  SizedBox(height: AppDimensions.spacing6),
                  Text(
                    'Let\'s set up your health profile to provide personalized recommendations.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ).animate().fade().slideY(begin: 0.5, end: 0),
                  SizedBox(height: AppDimensions.spacing6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.age, style: Theme.of(context).textTheme.labelLarge),
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
                              onChanged: (value) => setState(() => _age = value.toInt()),
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
                            child: Text(_age.toString(), textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ],
                  ).animate(delay: 100.ms).fade().slideY(begin: 0.5, end: 0),
                  SizedBox(height: AppDimensions.spacing6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.healthConditions, style: Theme.of(context).textTheme.labelLarge),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.activityLevel, style: Theme.of(context).textTheme.labelLarge),
                      SizedBox(height: AppDimensions.spacing2),
                      Column(
                        children: ['Low', 'Moderate', 'High'].map((level) {
                          return RadioListTile<String>(
                            title: Text(level),
                            value: level,
                            groupValue: _activityLevel,
                            onChanged: (value) => setState(() => _activityLevel = value!),
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                    ],
                  ).animate(delay: 300.ms).fade().slideY(begin: 0.5, end: 0),
                  SizedBox(height: AppDimensions.spacing6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.pollutantSensitivity, style: Theme.of(context).textTheme.labelLarge),
                      SizedBox(height: AppDimensions.spacing4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...['PM2.5', 'Ozone'].map((pollutant) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Text('$pollutant:', style: Theme.of(context).textTheme.bodyMedium),
                                  SizedBox(width: AppDimensions.spacing4),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return GestureDetector(
                                        onTap: () => setState(() => _pollutantSensitivity[pollutant] = (index + 1).toDouble()),
                                        child: Icon(
                                          Icons.circle,
                                          color: index < _pollutantSensitivity[pollutant]!.toInt()
                                              ? AppColors.primary
                                              : AppColors.gray40,
                                          size: 16,
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ).animate(delay: 400.ms).fade().slideY(begin: 0.5, end: 0),
                  SizedBox(height: AppDimensions.spacing8),
                  PrimaryButton(
                    text: AppStrings.save,
                    onPressed: _saveProfile,
                    isLoading: _isLoading,
                  ).animate(delay: 500.ms).fade().slideY(begin: 0.5, end: 0),
                  SizedBox(height: AppDimensions.spacing6),
                  Center(
                    child: TextButton(
                      onPressed: () => AppRoutes.navigateTo(context, AppRoutes.healthDashboard, replace: true),
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
