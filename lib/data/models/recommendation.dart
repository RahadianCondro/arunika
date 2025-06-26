// lib/data/models/recommendation.dart
import 'package:flutter/material.dart';

class Recommendation {
  final String id;
  final String title;
  final String description;
  final String type; // 'health', 'activity', 'environment'
  final String severity; // 'Informational', 'Low', 'Moderate', 'High', 'Critical'
  final IconData iconData;
  final List<String> actions;
  final List<String> appliesTo;

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.iconData,
    required this.actions,
    required this.appliesTo,
  });

  // Create from JSON
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    // Handle the iconData conversion safely with null check and default value
    int iconCodePoint = json['iconData'] != null 
        ? (json['iconData'] is int ? json['iconData'] : 0xe093) // Default to eco icon if not numeric
        : 0xe093; // Default to eco icon if null
    
    return Recommendation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'general',
      severity: json['severity'] ?? 'Informational',
      iconData: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
      actions: json['actions'] != null 
          ? List<String>.from(json['actions']) 
          : <String>[],
      appliesTo: json['appliesTo'] != null 
          ? List<String>.from(json['appliesTo']) 
          : <String>[],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'severity': severity,
      'iconData': iconData.codePoint,
      'actions': actions,
      'appliesTo': appliesTo,
    };
  }

  // Get severity color
  Color getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'informational':
        return Colors.blue;
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}