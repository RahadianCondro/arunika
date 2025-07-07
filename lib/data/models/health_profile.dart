// lib/data/models/health_profile.dart

class HealthProfile {
  final String id;
  final String name;
  final int age;
  final List<String> healthConditions;
  final String activityLevel;
  final Map<String, double> pollutantSensitivity;

  HealthProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.healthConditions,
    required this.activityLevel,
    required this.pollutantSensitivity,
  });

  // ✅ Constructor fleksibel yang bisa dikustomisasi saat dipanggil
  factory HealthProfile.empty({
    String uid = '',
    String name = 'Pengguna',
    int age = 30,
    List<String> healthConditions = const [],
    String activityLevel = 'Sedang',
    Map<String, double> pollutantSensitivity = const {
      'PM2_5': 3.0,
      'O3': 2.0,
    },
  }) {
    return HealthProfile(
      id: uid,
      name: name,
      age: age,
      healthConditions: healthConditions,
      activityLevel: activityLevel,
      pollutantSensitivity: pollutantSensitivity,
    );
  }

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 30,
      healthConditions: List<String>.from(json['healthConditions'] ?? []),
      activityLevel: json['activityLevel'] ?? 'Sedang',
      pollutantSensitivity: Map<String, double>.from(json['pollutantSensitivity'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'healthConditions': healthConditions,
      'activityLevel': activityLevel,
      'pollutantSensitivity': pollutantSensitivity,
    };
  }

  HealthProfile copyWith({
    String? id,
    String? name,
    int? age,
    List<String>? healthConditions,
    String? activityLevel,
    Map<String, double>? pollutantSensitivity,
  }) {
    return HealthProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      healthConditions: healthConditions ?? this.healthConditions,
      activityLevel: activityLevel ?? this.activityLevel,
      pollutantSensitivity: pollutantSensitivity ?? this.pollutantSensitivity,
    );
  }
}
