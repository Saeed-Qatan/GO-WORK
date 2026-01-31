import 'dart:io';

class RegisterDataModel {
  final String firstName;
  final String fatherName;
  final String familyName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final File? profilePhoto;
  final File? cvFile;
  final List<String> skills;
  final int? interstedInCategoryId;

  RegisterDataModel({
    required this.firstName,
    required this.fatherName,
    required this.familyName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    this.profilePhoto,
    this.cvFile,
    List<String>? skills,
    this.interstedInCategoryId,
  }) : skills = skills ?? [];

  RegisterDataModel copyWith({
    String? firstName,
    String? fatherName,
    String? familyName,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    File? profilePhoto,
    File? cvFile,
    List<String>? skills,
    int? interstedInCategoryId,
  }) {
    return RegisterDataModel(
      firstName: firstName ?? this.firstName,
      fatherName: fatherName ?? this.fatherName,
      familyName: familyName ?? this.familyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      cvFile: cvFile ?? this.cvFile,
      skills: skills ?? this.skills,
      interstedInCategoryId:
          interstedInCategoryId ?? this.interstedInCategoryId,
    );
  }
}
