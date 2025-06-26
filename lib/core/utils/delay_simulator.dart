// lib/core/utils/delay_simulator.dart
import 'dart:math';

class DelaySimulator {
  static Future<void> networkDelay([int minMs = 200, int maxMs = 800]) async {
    final delay = minMs + Random().nextInt(maxMs - minMs);
    await Future.delayed(Duration(milliseconds: delay));
  }
  
  static Future<void> longOperation([int minMs = 500, int maxMs = 1500]) async {
    final delay = minMs + Random().nextInt(maxMs - minMs);
    await Future.delayed(Duration(milliseconds: delay));
  }
}