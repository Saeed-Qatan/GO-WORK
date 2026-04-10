import 'dart:io';

class EditProfileModel {
  final String firstName;
  final String middleName;
  final String lastName;
  final String jobTitle;
  final String phone;
  final List<String> skills;
  final String? avatarUrl;
  final String? cvUrl;
  final File? newAvatarFile;
  final File? newCvFile;

  const EditProfileModel({
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.jobTitle = '',
    this.phone = '',
    this.skills = const [],
    this.avatarUrl,
    this.cvUrl,
    this.newAvatarFile,
    this.newCvFile,
  });

  EditProfileModel copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? jobTitle,
    String? phone,
    List<String>? skills,
    String? avatarUrl,
    String? cvUrl,
    File? newAvatarFile,
    File? newCvFile,
  }) {
    return EditProfileModel(
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      jobTitle: jobTitle ?? this.jobTitle,
      phone: phone ?? this.phone,
      skills: skills ?? this.skills,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      cvUrl: cvUrl ?? this.cvUrl,
      newAvatarFile: newAvatarFile ?? this.newAvatarFile,
      newCvFile: newCvFile ?? this.newCvFile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'MiddleName': middleName,
      'LastName': lastName,
      'JobTitle': jobTitle,
      'PhoneNumber': phone,
      'Skills': skills,
    };
  }

  factory EditProfileModel.fromJson(Map<String, dynamic> json) {
    return EditProfileModel(
      firstName: json['FirstName'] ?? '',
      middleName: json['MiddleName'] ?? '',
      lastName: json['LastName'] ?? '',
      jobTitle: json['JobTitle'] ?? '',
      phone: json['PhoneNumber'] ?? '',
      skills: List<String>.from(json['Skills'] ?? []),
      avatarUrl: json['AvatarUrl'],
      cvUrl: json['CvUrl'],
    );
  }

  // --- Validation Logic ---

  String? validateName(String value, String fieldName) {
    if (value.trim().isEmpty) return 'الرجاء إدخال $fieldName';
    if (value.trim().length < 2) {
      return '$fieldName يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  String? validatePhone(String value) {
    if (value.trim().isEmpty) return 'الرجاء إدخال رقم الهاتف';
    // Simplified validation: check if it only contains digits and optional plus
    if (!RegExp(r'^\+?[0-9\s]+$').hasMatch(value)) {
      return 'رقم الهاتف غير صالح';
    }
    return null;
  }

  String? validateJobTitle(String value) {
    if (value.trim().isEmpty) return 'الرجاء إدخال المسمى الوظيفي';
    return null;
  }
}
