// lib/features/settings/settings_navigator.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../routes.dart';

class SettingsNavigator extends StatelessWidget {
  final String currentScreen;
  
  const SettingsNavigator({
    Key? key,
    required this.currentScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: AppDimensions.spacing6,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing2,
        vertical: AppDimensions.spacing1,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray20,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavigationButton(
            context, 
            'Dasar', 
            'settings',
            currentScreen == 'settings',
          ),
          SizedBox(width: AppDimensions.spacing2),
          _buildNavigationButton(
            context, 
            'Lanjutan', 
            'enhancedSettings',
            currentScreen == 'enhancedSettings',
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationButton(
    BuildContext context,
    String label,
    String routeName,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          // Navigate to the specified route
          if (routeName == 'settings') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.settings,
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.enhancedSettings,
              (route) => false,
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing3,
          vertical: AppDimensions.spacing2,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : AppColors.gray80,
          ),
        ),
      ),
    );
  }
}