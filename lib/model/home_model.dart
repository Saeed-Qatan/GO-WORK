import 'package:flutter/material.dart';

class UserModel {
  final String name;
  final String imageUrl;

  UserModel({required this.name, required this.imageUrl});
}

class StatModel {
  final String count;
  final String label;
  final IconData icon;
  final Color color;

  StatModel({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
  });

  factory StatModel.fromJson(Map<String, dynamic> json) {
    // Map basic fields
    String label = json['label'] ?? '';
    // Determine icon and color based on label or type from backend
    // This is a client-side mapping for UI logic
    IconData icon = Icons.work;
    Color color = Colors.blue;

    if (label.contains('مقابلة') || label.contains('Interview')) {
      icon = Icons.mic;
      color = Colors.orange;
    } else if (label.contains('طلب') || label.contains('Application')) {
      icon = Icons.description;
      color = Colors.purple;
    }

    return StatModel(
      count: json['count']?.toString() ?? '0',
      label: label,
      icon: icon,
      color: color,
    );
  }
}

class JobModel {
  final String id;
  final String title;
  final String company;
  final String companyLogoUrl;
  final int matchPercentage;
  final String category;
  final String location;
  final String type; // e.g., Full-time
  final String workMode; // e.g., On-site
  final String minSalary;
  final String maxSalary;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.companyLogoUrl,
    required this.matchPercentage,
    required this.category,
    required this.location,
    required this.type,
    required this.workMode,
    required this.minSalary,
    required this.maxSalary,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      companyLogoUrl: json['companyLogoUrl'] ?? '',
      matchPercentage: json['matchPercentage'] ?? 0,
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      workMode: json['workMode'] ?? '',
      minSalary: json['minSalary']?.toString() ?? '',
      maxSalary: json['maxSalary']?.toString() ?? '',
    );
  }
}
