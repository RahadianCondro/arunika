// lib/data/repositories/exposure_repository.dart
import '../models/exposure_history.dart';

class ExposureRepository {
  // In a real app, this would fetch data from an API
  // For now, we'll use hardcoded data based on your documentation
  
  Future<List<ExposureHistory>> getDailyExposure(DateTime startDate, DateTime endDate) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1200));
    
    // Dummy data from your documentation
    return [
      ExposureHistory(
        date: '2025-04-25',
        pollutants: {
          'PM2_5': ExposureData(average: 15.3, peak: 22.7, duration: 8.5),
          'PM10': ExposureData(average: 35.6, peak: 48.2, duration: 8.5),
          'O3': ExposureData(average: 78.4, peak: 105.6, duration: 8.5),
        },
        averageAqi: 68,
        locations: [
          LocationExposure(name: 'Home', lat: -7.797068, lon: 110.370529, aqi: 65, duration: 14.0),
          LocationExposure(name: 'Work', lat: -7.782900, lon: 110.367032, aqi: 72, duration: 8.5),
          LocationExposure(name: 'Commute', lat: -7.790000, lon: 110.368500, aqi: 85, duration: 1.5),
        ],
      ),
      ExposureHistory(
        date: '2025-04-26',
        pollutants: {
          'PM2_5': ExposureData(average: 12.8, peak: 18.4, duration: 7.0),
          'PM10': ExposureData(average: 30.2, peak: 42.5, duration: 7.0),
          'O3': ExposureData(average: 68.9, peak: 92.3, duration: 7.0),
        },
        averageAqi: 58,
        locations: [
          LocationExposure(name: 'Home', lat: -7.797068, lon: 110.370529, aqi: 55, duration: 16.0),
          LocationExposure(name: 'Market', lat: -7.795000, lon: 110.365000, aqi: 62, duration: 2.0),
          LocationExposure(name: 'Park', lat: -7.785000, lon: 110.375000, aqi: 45, duration: 3.0),
          LocationExposure(name: 'Commute', lat: -7.790000, lon: 110.368500, aqi: 70, duration: 3.0),
        ],
      ),
      ExposureHistory(
        date: '2025-04-27',
        pollutants: {
          'PM2_5': ExposureData(average: 10.5, peak: 15.8, duration: 0.0),
          'PM10': ExposureData(average: 25.6, peak: 34.2, duration: 0.0),
          'O3': ExposureData(average: 52.3, peak: 75.1, duration: 0.0),
        },
        averageAqi: 48,
        locations: [
          LocationExposure(name: 'Home', lat: -7.797068, lon: 110.370529, aqi: 48, duration: 24.0),
        ],
      ),
      ExposureHistory(
        date: '2025-04-28',
        pollutants: {
          'PM2_5': ExposureData(average: 16.9, peak: 25.2, duration: 8.0),
          'PM10': ExposureData(average: 38.4, peak: 52.7, duration: 8.0),
          'O3': ExposureData(average: 85.6, peak: 110.3, duration: 8.0),
        },
        averageAqi: 75,
        locations: [
          LocationExposure(name: 'Home', lat: -7.797068, lon: 110.370529, aqi: 70, duration: 14.0),
          LocationExposure(name: 'Work', lat: -7.782900, lon: 110.367032, aqi: 82, duration: 8.0),
          LocationExposure(name: 'Commute', lat: -7.790000, lon: 110.368500, aqi: 92, duration: 2.0),
        ],
      ),
      ExposureHistory(
        date: '2025-04-29',
        pollutants: {
          'PM2_5': ExposureData(average: 18.2, peak: 26.8, duration: 8.5),
          'PM10': ExposureData(average: 40.5, peak: 58.2, duration: 8.5),
          'O3': ExposureData(average: 90.3, peak: 118.7, duration: 8.5),
        },
        averageAqi: 82,
        locations: [
          LocationExposure(name: 'Home', lat: -7.797068, lon: 110.370529, aqi: 78, duration: 14.0),
          LocationExposure(name: 'Work', lat: -7.782900, lon: 110.367032, aqi: 85, duration: 8.5),
          LocationExposure(name: 'Commute', lat: -7.790000, lon: 110.368500, aqi: 95, duration: 1.5),
        ],
      ),
      ExposureHistory(
        date: '2025-04-30',
        pollutants: {
          'PM2_5': ExposureData(average: 13.6, peak: 20.4, duration: 7.5),
          'PM10': ExposureData(average: 32.8, peak: 45.6, duration: 7.5),
          'O3': ExposureData(average: 74.5, peak: 98.2, duration: 7.5),
        },
        averageAqi: 65,
        locations: [
          LocationExposure(name: 'Home', lat: -7.797068, lon: 110.370529, aqi: 60, duration: 15.0),
          LocationExposure(name: 'Work', lat: -7.782900, lon: 110.367032, aqi: 68, duration: 7.5),
          LocationExposure(name: 'Commute', lat: -7.790000, lon: 110.368500, aqi: 78, duration: 1.5),
        ],
      ),
      ExposureHistory(
        date: '2025-05-01',
        pollutants: {
          'PM2_5': ExposureData(average: 14.2, peak: 21.3, duration: 8.0),
          'PM10': ExposureData(average: 34.6, peak: 47.8, duration: 8.0),
          'O3': ExposureData(average: 79.8, peak: 105.2, duration: 8.0),
        },
        averageAqi: 70,
        locations: [
          LocationExposure(name: 'Home', lat: -7.797068, lon: 110.370529, aqi: 65, duration: 14.5),
          LocationExposure(name: 'Work', lat: -7.782900, lon: 110.367032, aqi: 75, duration: 8.0),
          LocationExposure(name: 'Commute', lat: -7.790000, lon: 110.368500, aqi: 82, duration: 1.5),
        ],
      ),
    ];
  }
  
  Future<Map<String, double>> getWeeklyAverages() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 900));
    
    // Dummy data from your documentation
    return {
      'PM2_5': 14.5,
      'PM10': 34.0,
      'O3': 75.7,
      'AQI': 66.6,
    };
  }
  
  Future<String> getWeeklyTrend() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Dummy data from your documentation
    return 'Stable'; // Other possible values: 'Improving', 'Worsening'
  }
}