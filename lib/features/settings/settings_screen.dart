// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_bottom_navigation_bar.dart';
import '../../routes.dart';
import 'settings_navigator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification settings
  bool _aqiAlerts = true;
  bool _dailySummary = true;
  bool _forecasts = true;
  
  // App preferences
  bool _darkMode = false;
  String _language = 'English';
  String _units = 'Metric';
  
  // Privacy settings
  String _locationTracking = 'Always';
  bool _shareAnalytics = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
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
                // Add settings navigator
                Center(
                  child: SettingsNavigator(
                    currentScreen: 'settings',
                  ),
                ),
                // Adding spacing after the navigator
                SizedBox(height: AppDimensions.spacing4),
                
                // App Preferences section
                _buildSectionTitle('App Preferences'),
                
                // Dark Mode
                _buildToggleSetting(
                  'Dark Mode',
                  'Switch between light and dark themes',
                  _darkMode,
                  (value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                  Icons.dark_mode,
                ),
                
                // Language
                _buildDropdownSetting(
                  'Language',
                  'Select your preferred language',
                  _language,
                  ['English', 'Bahasa Indonesia', 'Español'],
                  (value) {
                    setState(() {
                      _language = value!;
                    });
                  },
                  Icons.language,
                ),
                
                // Units
                _buildDropdownSetting(
                  'Units',
                  'Choose measurement system',
                  _units,
                  ['Metric', 'Imperial'],
                  (value) {
                    setState(() {
                      _units = value!;
                    });
                  },
                  Icons.straighten,
                ),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Notifications section
                _buildSectionTitle('Notifications'),
                
                // AQI Alerts
                _buildToggleSetting(
                  'AQI Alerts',
                  'Get notified when air quality changes significantly',
                  _aqiAlerts,
                  (value) {
                    setState(() {
                      _aqiAlerts = value;
                    });
                  },
                  Icons.notifications_active,
                ),
                
                // Daily Summary
                _buildToggleSetting(
                  'Daily Summary',
                  'Receive a daily air quality report',
                  _dailySummary,
                  (value) {
                    setState(() {
                      _dailySummary = value;
                    });
                  },
                  Icons.summarize,
                ),
                
                // Forecasts
                _buildToggleSetting(
                  'Forecasts',
                  'Get alerts about upcoming air quality changes',
                  _forecasts,
                  (value) {
                    setState(() {
                      _forecasts = value;
                    });
                  },
                  Icons.update,
                ),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Privacy section
                _buildSectionTitle('Privacy'),
                
                // Location Tracking
                _buildDropdownSetting(
                  'Location Tracking',
                  'Control when ARUNIKA can access your location',
                  _locationTracking,
                  ['Always', 'While Using', 'Never'],
                  (value) {
                    setState(() {
                      _locationTracking = value!;
                    });
                  },
                  Icons.location_on,
                ),
                
                // Share Analytics
                _buildToggleSetting(
                  'Share Analytics',
                  'Help improve ARUNIKA by sharing usage data',
                  _shareAnalytics,
                  (value) {
                    setState(() {
                      _shareAnalytics = value;
                    });
                  },
                  Icons.analytics,
                ),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Data Management section
                _buildSectionTitle('Data Management'),
                
                // Clear Local Data
                _buildActionSetting(
                  'Clear Local Data',
                  'Remove all cached data from your device',
                  () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Clear Local Data'),
                        content: Text('Are you sure you want to clear all cached data? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Clear local data
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Local data cleared successfully'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            child: Text('Clear'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  Icons.delete,
                  color: AppColors.danger,
                ),
                
                // Export My Data
                _buildActionSetting(
                  'Export My Data',
                  'Download all your data in JSON format',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Your data is being prepared for export'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                  Icons.download,
                ),
                // lib/features/settings/settings_screen.dart (lanjutan)
                // About section
                SizedBox(height: AppDimensions.spacing6),
                
                _buildSectionTitle('About'),
                
                // About ARUNIKA
                _buildActionSetting(
                  'About ARUNIKA',
                  'Learn more about the app and team',
                  () {
                    // Navigate to about screen
                    _showAboutDialog();
                  },
                  Icons.info,
                ),
                
                // Version
                Container(
                  margin: EdgeInsets.only(bottom: AppDimensions.spacing3),
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
                  child: Row(
                    children: [
                      Icon(
                        Icons.offline_pin,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      SizedBox(width: AppDimensions.spacing3),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Version',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '1.1.0 (build 42)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: AppDimensions.spacing8),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppDimensions.spacing4,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppDimensions.heading4,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    ).animate().fade().slideY(begin: 0.3, end: 0);
  }

  Widget _buildToggleSetting(
    String title,
    String description,
    bool value,
    void Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacing3),
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
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),
          SizedBox(width: AppDimensions.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.3, end: 0);
  }

  Widget _buildDropdownSetting(
    String title,
    String description,
    String value,
    List<String> options,
    void Function(String?) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacing3),
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
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),
          SizedBox(width: AppDimensions.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 16,
            style: TextStyle(color: AppColors.primary),
            underline: Container(
              height: 2,
              color: AppColors.primary,
            ),
            onChanged: onChanged,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionSetting(
    String title,
    String description,
    VoidCallback onTap,
    IconData icon, {
    Color color = AppColors.primary,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacing3),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            SizedBox(width: AppDimensions.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
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
    ).animate().fade().slideY(begin: 0.3, end: 0);
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About ARUNIKA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "A",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppDimensions.spacing4),
            Text(
              'ARUNIKA',
              style: TextStyle(
                fontSize: AppDimensions.heading3,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            Text(
              'Platform Pemantauan Kualitas Udara Berbasis AI untuk Analisis Risiko Kesehatan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimensions.small,
              ),
            ),
            SizedBox(height: AppDimensions.spacing4),
            Text(
              'Developed by:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('RAHADIAN CANDRA VIMA YOGA'),
            Text('WIGA SARAH PUTRI'),
            Text('NURUL SYAMSIYAH'),
            SizedBox(height: AppDimensions.spacing2),
            Text('Universitas Ahmad Dahlan'),
            SizedBox(height: AppDimensions.spacing4),
            Text(
              '© 2025 ARUNIKA Team',
              style: TextStyle(
                fontSize: AppDimensions.small,
                color: AppColors.gray60,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}