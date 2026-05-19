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
  final String? categoryId;

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
    this.skills = const [],
    this.categoryId,
  });

  RegisterDataModel copyWith({
    File? profilePhoto,
    File? cvFile,
    List<String>? skills,
    String? categoryId,
  }) {
    return RegisterDataModel(
      firstName: firstName,
      fatherName: fatherName,
      familyName: familyName,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      cvFile: cvFile ?? this.cvFile,
      skills: skills ?? this.skills,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
