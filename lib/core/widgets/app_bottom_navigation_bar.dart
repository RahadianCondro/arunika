// lib/core/widgets/app_bottom_navigation_bar.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../routes.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigationBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) { // Home tab
          if (currentIndex != 0) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRoutes.dashboard,
              (route) => false,
            );
          }
        } else if (index == 1) { // Map tab
          if (currentIndex != 1) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRoutes.map,
              (route) => false,
            );
          }
        } else if (index == 2) { // Route tab
          if (currentIndex != 2) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRoutes.enhancedRoutePlanning, // Gunakan enhanced route planning
              (route) => false,
            );
          }
        } else if (index == 3) { // Health tab
          if (currentIndex != 3) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRoutes.healthDashboard,
              (route) => false,
            );
          }
        } else if (index == 4) { // Settings tab (previously Profile)
          if (currentIndex != 4) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRoutes.enhancedSettings,
              (route) => false,
            );
          }
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray60,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
      ),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Peta',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.route),
          label: 'Rute',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Kesehatan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Pengaturan',
        ),
      ],
    );
  }
}