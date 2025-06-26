// lib/features/settings/enhanced_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_bottom_navigation_bar.dart';
import 'settings_navigator.dart';

class EnhancedSettingsScreen extends StatefulWidget {
  const EnhancedSettingsScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedSettingsScreen> createState() => _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState extends State<EnhancedSettingsScreen> {
  // App preferences
  bool _darkMode = false;
  String _language = 'Bahasa Indonesia';
  String _units = 'Metric';
  bool _useLocation = true;
  
  // Notification settings
  bool _aqiAlerts = true;
  bool _dailySummary = true;
  bool _forecasts = true;
  bool _healthRecommendations = true;
  bool _routeOptimizations = true;
  
  // Health preferences
  String _healthSensitivity = 'Medium';
  bool _useHealthProfile = true;
  
  // Route preferences
  String _preferredRouteType = 'Balanced';
  int _maxDetourPercent = 20;
  
  // Privacy settings
  String _locationTracking = 'While Using';
  bool _shareAnalytics = true;
  bool _shareAnonymousData = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Preferences section
                _buildSectionTitle('Preferensi Aplikasi'),
                
                // Dark Mode
                _buildToggleSetting(
                  'Mode Gelap',
                  'Beralih antara tema terang dan gelap',
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
                  'Bahasa',
                  'Pilih bahasa yang Anda inginkan',
                  _language,
                  ['English', 'Bahasa Indonesia'],
                  (value) {
                    setState(() {
                      _language = value!;
                    });
                  },
                  Icons.language,
                ),
                
                // Units
                _buildDropdownSetting(
                  'Satuan',
                  'Pilih sistem pengukuran',
                  _units,
                  ['Metric', 'Imperial'],
                  (value) {
                    setState(() {
                      _units = value!;
                    });
                  },
                  Icons.straighten,
                ),
                
                // Use Location
                _buildToggleSetting(
                  'Gunakan Lokasi',
                  'Izinkan aplikasi mengakses lokasi Anda untuk rekomendasi yang lebih akurat',
                  _useLocation,
                  (value) {
                    setState(() {
                      _useLocation = value;
                    });
                  },
                  Icons.location_on,
                ),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Health Preferences section
                _buildSectionTitle('Preferensi Kesehatan'),
                
                // Health Sensitivity
                _buildDropdownSetting(
                  'Sensitivitas Kesehatan',
                  'Tingkat sensitivitas terhadap polutan udara',
                  _healthSensitivity,
                  ['Low', 'Medium', 'High', 'Very High'],
                  (value) {
                    setState(() {
                      _healthSensitivity = value!;
                    });
                  },
                  Icons.health_and_safety,
                ),
                
                // Use Health Profile
                _buildToggleSetting(
                  'Gunakan Profil Kesehatan',
                  'Gunakan data profil kesehatan Anda untuk rekomendasi yang dipersonalisasi',
                  _useHealthProfile,
                  (value) {
                    setState(() {
                      _useHealthProfile = value;
                    });
                  },
                  Icons.person,
                ),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Route Preferences section
                _buildSectionTitle('Preferensi Rute'),
                
                // Preferred Route Type
                _buildDropdownSetting(
                  'Tipe Rute Pilihan',
                  'Preferensi default untuk optimasi rute',
                  _preferredRouteType,
                  ['Healthiest', 'Balanced', 'Fastest'],
                  (value) {
                    setState(() {
                      _preferredRouteType = value!;
                    });
                  },
                  Icons.route,
                ),
                
                // Max Detour Percent
                _buildSliderSetting(
                  'Maksimum Detour',
                  'Persentase maksimum penambahan jarak/waktu untuk rute yang lebih sehat',
                  _maxDetourPercent.toDouble(),
                  (value) {
                    setState(() {
                      _maxDetourPercent = value.round();
                    });
                  },
                  Icons.timer,
                  suffix: '%',
                  min: 0,
                  max: 50,
                  divisions: 10,
                ),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Notifications section
                _buildSectionTitle('Notifikasi'),
                
                // AQI Alerts
                _buildToggleSetting(
                  'Peringatan AQI',
                  'Dapatkan notifikasi ketika kualitas udara berubah signifikan',
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
                  'Rangkuman Harian',
                  'Terima laporan kualitas udara harian',
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
                  'Prakiraan',
                  'Dapatkan peringatan tentang perubahan kualitas udara mendatang',
                  _forecasts,
                  (value) {
                    setState(() {
                      _forecasts = value;
                    });
                  },
                  Icons.update,
                ),
                
                // Health Recommendations
                _buildToggleSetting(
                  'Rekomendasi Kesehatan',
                  'Terima rekomendasi kesehatan berdasarkan profil Anda dan kualitas udara',
                  _healthRecommendations,
                  (value) {
                    setState(() {
                      _healthRecommendations = value;
                    });
                  },
                  Icons.health_and_safety,
                ),
                
                // Route Optimizations
                _buildToggleSetting(
                  'Optimasi Rute',
                  'Notifikasi tentang rute alternatif dengan paparan polutan lebih rendah',
                  _routeOptimizations,
                  (value) {
                    setState(() {
                      _routeOptimizations = value;
                    });
                  },
                  Icons.directions,
                ),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Privacy section
                _buildSectionTitle('Privasi'),
                
                // Location Tracking
                _buildDropdownSetting(
                  'Pelacakan Lokasi',
                  'Kontrol kapan ARUNIKA dapat mengakses lokasi Anda',
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
                  'Bagikan Analitik',
                  'Bantu meningkatkan ARUNIKA dengan berbagi data penggunaan',
                  _shareAnalytics,
                  (value) {
                    setState(() {
                      _shareAnalytics = value;
                    });
                  },
                  Icons.analytics,
                ),
                
                // Share Anonymous Data
                _buildToggleSetting(
                  'Bagikan Data Anonim',
                  'Kontribusi data anonim untuk penelitian kualitas udara dan kesehatan',
                  _shareAnonymousData,
                  (value) {
                    setState(() {
                      _shareAnonymousData = value;
                    });
                  },
                  Icons.public,
                ),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // Data Management section
                _buildSectionTitle('Manajemen Data'),
                
                // Clear Local Data
                _buildActionSetting(
                  'Hapus Data Lokal',
                  'Hapus semua data cache dari perangkat Anda',
                  () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Hapus Data Lokal'),
                        content: Text('Apakah Anda yakin ingin menghapus semua data cache? Tindakan ini tidak dapat dibatalkan.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Clear local data
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Data lokal berhasil dihapus'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            child: Text('Hapus'),
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
                  'Ekspor Data Saya',
                  'Unduh semua data Anda dalam format JSON',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Data Anda sedang disiapkan untuk diekspor'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                  Icons.download,
                ),
                
                // View Exposure History
                _buildActionSetting(
                  'Lihat Riwayat Paparan',
                  'Tinjau riwayat paparan polutan Anda dari waktu ke waktu',
                  () {
                    // Navigate to exposure history
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fitur ini akan tersedia dalam pembaruan mendatang'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                  Icons.history,
                ),
                
                SizedBox(height: AppDimensions.spacing6),
                
                // About section
                _buildSectionTitle('Tentang'),
                
                // About ARUNIKA
                _buildActionSetting(
                  'Tentang ARUNIKA',
                  'Pelajari lebih lanjut tentang aplikasi dan tim',
                  () {
                    // Show about dialog
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
                            'Versi',
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
  
  Widget _buildSliderSetting(
    String title,
    String description,
    double value,
    void Function(double) onChanged,
    IconData icon, {
    String suffix = '',
    double min = 0,
    double max = 100,
    int divisions = 10,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Text(
                '${value.round()}$suffix',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing3),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.3),
              valueIndicatorColor: AppColors.primary,
              valueIndicatorTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: '${value.round()}$suffix',
              onChanged: onChanged,
            ),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacing4),
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
        ),
      ),
    ).animate().fade().slideY(begin: 0.3, end: 0);
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tentang ARUNIKA'),
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
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/Arunika.jpg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
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
              'Dikembangkan oleh:',
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
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}