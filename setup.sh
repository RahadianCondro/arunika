#!/bin/bash

# Create lib directory structure
mkdir -p lib/core/{constants,theme,utils,widgets}
mkdir -p lib/data/{models,providers,repositories}
mkdir -p lib/features/{auth,dashboard,health,maps,onboarding}

# Create asset directories
mkdir -p assets/{images,icons,fonts,mock_data}

# Create test directory
mkdir -p test

# Core constants
touch lib/core/constants/app_colors.dart
touch lib/core/constants/app_dimensions.dart
touch lib/core/constants/app_strings.dart

# Core theme
touch lib/core/theme/app_theme.dart

# Core utilities
touch lib/core/utils/validators.dart

# Core widgets
touch lib/core/widgets/primary_button.dart
touch lib/core/widgets/secondary_button.dart
touch lib/core/widgets/app_text_field.dart
touch lib/core/widgets/aqi_indicator.dart

# Data models
touch lib/data/models/user.dart
touch lib/data/models/health_profile.dart
touch lib/data/models/air_quality.dart

# Data repositories
touch lib/data/repositories/auth_repository.dart
touch lib/data/repositories/air_quality_repository.dart

# Auth feature
touch lib/features/auth/login_screen.dart
touch lib/features/auth/register_screen.dart
touch lib/features/auth/health_profile_screen.dart

# Dashboard feature
touch lib/features/dashboard/dashboard_screen.dart

# Onboarding feature
touch lib/features/onboarding/splash_screen.dart
touch lib/features/onboarding/onboarding_screen.dart

# Root files
touch lib/routes.dart
touch lib/main.dart

# Mock data files
touch assets/mock_data/current_air_quality.json
touch assets/mock_data/forecast.json
touch assets/mock_data/recommendations.json

# Create a basic pubspec.yaml
cat > pubspec.yaml << 'EOL'
name: arunika
description: Platform Pemantauan Kualitas Udara Berbasis AI untuk Analisis Risiko Kesehatan

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.5
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  provider: ^6.0.5
  
  # Navigation
  auto_route: ^7.8.4
  
  # UI
  flutter_svg: ^2.0.7
  google_fonts: ^6.1.0
  flutter_animate: ^4.3.0
  lottie: ^2.7.0
  fl_chart: ^0.65.0
  
  # Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  
  # Network & Storage
  dio: ^5.3.3
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Utils
  intl: ^0.18.1
  logger: ^2.0.2
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.6
  auto_route_generator: ^7.3.2
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/mock_data/
    
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Light.ttf
          weight: 300
        - asset: assets/fonts/Poppins-Regular.ttf
          weight: 400
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
EOL

echo "ARUNIKA Sprint 1 project structure created successfully!"