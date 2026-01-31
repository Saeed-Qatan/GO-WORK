// Pure data models for home feature
// No Flutter dependencies - UI logic handled separately

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
  final int matchPercentage;
  final String category;
  final String location;
  final String type;
  final String workMode;
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
