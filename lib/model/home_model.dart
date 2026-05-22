// Pure data models for home feature
// No Flutter dependencies - UI logic handled separately
import 'package:flutter/foundation.dart';
import '../utils/status_translator.dart';

class UserModel {
  final String name;
  final String imageUrl;

  UserModel({required this.name, required this.imageUrl});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

/// Stat types for UI mapping
enum StatType { interview, review, sent, unknown }

class StatModel {
  final String count;
  final String label;
  final StatType type;

  StatModel({required this.count, required this.label, required this.type});

  factory StatModel.fromJson(Map<String, dynamic> json) {
    String label = json['label'] ?? '';

    // Determine type based on label
    StatType type = StatType.unknown;
    if (label.contains('مقابلة') ||
        label.contains('مقابلات') ||
        label.contains('Interview')) {
      type = StatType.interview;
    } else if (label.contains('مراجعة') || label.contains('Review')) {
      type = StatType.review;
    } else if (label.contains('طلب') ||
        label.contains('مرسلة') ||
        label.contains('Application') ||
        label.contains('Sent')) {
      type = StatType.sent;
    }

    return StatModel(
      count: json['count']?.toString() ?? '0',
      label: label,
      type: type,
    );
  }
}

class JobModel {
  final String id;
  final String title;
  final String company;
  final String companyLogoUrl;
  final String category;
  final String location;
  final String country;
  final String type;
  final String workMode;
  final String minSalary;
  final String maxSalary;

  // Additional detail fields
  final String? description;
  final String? currency;
  final String? postedDate;
  final String? expirationDate;
  final List<String>? skills;
  final bool? canApply;
  final String? contactNumber;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.companyLogoUrl,
    required this.category,
    required this.location,
    required this.country,
    required this.type,
    required this.workMode,
    required this.minSalary,
    required this.maxSalary,
    this.description,
    this.currency,
    this.postedDate,
    this.expirationDate,
    this.skills,
    this.canApply,
    this.contactNumber,
  });

  String get displayType => StatusTranslator.jobTypeLabel(type);

  String get displayWorkMode => StatusTranslator.workModeLabel(workMode);

  String get displayCurrency => StatusTranslator.currencyLabel(currency);

  JobModel copyWith({
    String? id,
    String? title,
    String? company,
    String? companyLogoUrl,
    String? category,
    String? location,
    String? country,
    String? type,
    String? workMode,
    String? minSalary,
    String? maxSalary,
    String? description,
    String? currency,
    String? postedDate,
    String? expirationDate,
    List<String>? skills,
    bool? canApply,
    String? contactNumber,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      category: category ?? this.category,
      location: location ?? this.location,
      country: country ?? this.country,
      type: type ?? this.type,
      workMode: workMode ?? this.workMode,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      description: description ?? this.description,
      currency: currency ?? this.currency,
      postedDate: postedDate ?? this.postedDate,
      expirationDate: expirationDate ?? this.expirationDate,
      skills: skills ?? this.skills,
      canApply: canApply ?? this.canApply,
      contactNumber: contactNumber ?? this.contactNumber,
    );
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    String companyName = '';
    String logoUrl = '';

    if (json['company'] is Map) {
      companyName = json['company']['name']?.toString() ?? '';
      logoUrl = json['company']['logoUrl']?.toString() ?? '';
    } else {
      companyName =
          json['companyName']?.toString() ?? json['company']?.toString() ?? '';
      logoUrl = json['companyLogoUrl']?.toString() ?? '';
    }

    // Parse skills list safely
    List<String>? parsedSkills;
    if (json['skills'] != null) {
      try {
        parsedSkills = (json['skills'] as List)
            .map((item) => item.toString())
            .toList();
      } catch (e) {
        debugPrint('Error parsing skills: $e');
      }
    }

    return JobModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      company: companyName,
      companyLogoUrl: logoUrl,
      category: json['category']?.toString() ?? '',
      location:
          json['governate']?.toString() ?? json['location']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      type: json['jobType']?.toString() ?? json['type']?.toString() ?? '',
      workMode:
          json['jobLocationType']?.toString() ??
          json['locationType']?.toString() ??
          json['workMode']?.toString() ??
          '',
      minSalary: json['minSalary']?.toString() ?? '',
      maxSalary: json['maxSalary']?.toString() ?? '',
      description: json['description']?.toString(),
      currency: json['currency']?.toString(),
      postedDate: json['postedDate']?.toString(),
      expirationDate: json['expirationDate']?.toString(),
      skills: parsedSkills,
      canApply: json['canApply'] as bool?,
      contactNumber:
          json['contactNumber']?.toString() ??
          json['phoneNumber']?.toString() ??
          json['phone']?.toString() ??
          json['phone_number']?.toString() ??
          (json['company'] is Map
              ? json['company']['phone']?.toString() ??
                    json['company']['contactNumber']?.toString()
              : null),
    );
  }
}
