import 'package:flutter/material.dart';
import '../model/home_model.dart';

/// UI Helper for mapping StatType to visual elements
/// Separates UI concerns from data models
class StatUiHelper {
  /// Get icon for stat type
  static IconData getIcon(StatType type) {
    switch (type) {
      case StatType.interview:
        return Icons.calendar_today;
      case StatType.review:
        return Icons.access_time_filled;
      case StatType.sent:
        return Icons.send;
      case StatType.unknown:
        return Icons.work;
    }
  }

  /// Get color for stat type
  static Color getColor(StatType type) {
    switch (type) {
      case StatType.interview:
        return const Color(0xFF4CAF50); // Green
      case StatType.review:
        return const Color(0xFFFFC107); // Amber
      case StatType.sent:
        return const Color(0xFF2962FF); // Blue
      case StatType.unknown:
        return Colors.grey;
    }
  }
}
