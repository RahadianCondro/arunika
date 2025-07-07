// lib/routes.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'data/models/route.dart';
import 'data/models/location.dart';
import 'data/models/recommendation.dart';

import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/health_profile_screen.dart';
import 'features/auth/verify_email_screen.dart';

import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/maps/map_screen.dart';
import 'features/maps/route_planning_screen.dart';
import 'features/maps/enhanced_route_planning_screen.dart';
import 'features/maps/favorite_locations_screen.dart';
import 'features/maps/route_results_screen.dart';
import 'features/health/health_dashboard_screen.dart';
import 'features/health/exposure_tracking_screen.dart';
import 'features/health/recommendations_screen.dart';
import 'features/dashboard/aqi_detail_screen.dart';
import 'features/dashboard/forecast_screen.dart';
import 'features/dashboard/recommendation_detail_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/enhanced_settings_screen.dart'; // Add the import for the enhanced settings
import 'core/utils/page_transitions.dart';


class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String healthProfile = '/health-profile';
  static const String dashboard = '/dashboard';
  static const String map = '/map';
  static const String routePlanning = '/route-planning';
  static const String enhancedRoutePlanning = '/enhanced-route-planning';
  static const String exposureTracking = '/exposure-tracking';
  static const String recommendations = '/recommendations';
  static const String healthDashboard = '/health-dashboard';
  static const String aqiDetail = '/aqi-detail';
  static const String forecast = '/forecast';
  static const String recommendationDetail = '/recommendation-detail';
  static const String settings = '/settings';
  static const String enhancedSettings = '/enhanced-settings'; // Add the new route constant
  static const String favoriteLocations = '/favorite-locations';
  static const String routeResults = '/route-results';
  static const String verifyEmail = '/verify-email';


  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      healthProfile: (context) => const HealthProfileScreen(),
      dashboard: (context) => const DashboardScreen(),
      map: (context) => const MapScreen(),
      routePlanning: (context) => const RoutePlanningScreen(),
      enhancedRoutePlanning: (context) => const EnhancedRoutePlanningScreen(),
      exposureTracking: (context) => const ExposureTrackingScreen(),
      recommendations: (context) => const RecommendationsScreen(),
      healthDashboard: (context) => const HealthDashboardScreen(),
      aqiDetail: (context) => const AqiDetailScreen(),
      forecast: (context) => const ForecastScreen(),
      settings: (context) => const SettingsScreen(),
      enhancedSettings: (context) => const EnhancedSettingsScreen(), // Add the route builder
      favoriteLocations: (context) => const FavoriteLocationsScreen(),
      verifyEmail: (context) => const VerifyEmailScreen(),

    };
  }
  
  // Navigasi sederhana
  static void navigateTo(BuildContext context, String routeName, {bool replace = false}) {
    if (replace) {
      Navigator.of(context).pushReplacementNamed(routeName);
    } else {
      Navigator.of(context).pushNamed(routeName);
    }
  }
  
  // Navigasi untuk halaman detail rekomendasi
  static void navigateToRecommendationDetail(BuildContext context, Recommendation recommendation) {
    Navigator.push(
      context,
      SlidePageRoute(
        page: RecommendationDetailScreen(
          recommendation: recommendation,
        ),
      ),
    );
  }
  
  // Navigasi ke halaman hasil rute
  static void navigateToRouteResults(
    BuildContext context, {
    required List<OptimizedRoute> routes,
    required LatLng startLocation,
    required LatLng destinationLocation,
    required String startName,
    required String destinationName,
  }) {
    Navigator.push(
      context,
      SlidePageRoute(
        page: RouteResultsScreen(
          routes: routes,
          startLocation: startLocation,
          destinationLocation: destinationLocation,
          startName: startName,
          destinationName: destinationName,
        ),
      ),
    );
  }
  
  // Navigasi ke halaman peta dengan lokasi tertentu
  static void navigateToMapWithLocation(BuildContext context, Location location) {
    Navigator.pushNamed(
      context,
      map,
      arguments: location,
    );
  }
  
  // Navigasi ke halaman perencanaan rute dengan tujuan tertentu
  static void navigateToRoutePlanningWithDestination(BuildContext context, Location destination) {
    Navigator.pushNamed(
      context,
      enhancedRoutePlanning,
      arguments: {'destination': destination},
    );
  }
  
  // Navigasi dan menghapus semua halaman sebelumnya
  static void navigateAndRemoveUntil(BuildContext context, String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
    );
  }
  
  // Navigasi ke Enhanced Settings
  static void navigateToEnhancedSettings(BuildContext context) {
    Navigator.push(
      context,
      SlidePageRoute(
        page: const EnhancedSettingsScreen(),
      ),
    );
  }
}