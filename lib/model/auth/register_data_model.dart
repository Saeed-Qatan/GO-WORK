import 'dart:io';

import 'package:flutter/material.dart';


class RegisterDataModel extends ChangeNotifier {
  String firstName;
  String fatherName;
  String familyName;
  String email;
  String phone;
  String password;
  File? cvFile;
  String? fieldOfInterest;
  List<String> skills;

  RegisterDataModel({
    required this.firstName,
    required this.fatherName,
    required this.familyName,
    required this.email,
    required this.phone,
    required this.password,
    this.cvFile,
    this.fieldOfInterest,
    List<String>? skills,
  }) : skills = skills ?? [];

  void updateFirstName(String value) {
    firstName = value;
    notifyListeners();
  }

  void updateFatherName(String value) {
    fatherName = value;
    notifyListeners();
  }

  void updateFamilyName(String value) {
    familyName = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updatePhone(String value) {
    phone = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  void setCvFile(File? file) {
    cvFile = file;
    notifyListeners();
  }

  void setFieldOfInterest(String? field) {
    fieldOfInterest = field;
    notifyListeners();
  }

  void addSkill(String skill) {
    if (!skills.contains(skill)) {
      skills.add(skill);
      notifyListeners();
    }
  }

  void removeSkill(String skill) {
    skills.remove(skill);
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'fatherName': fatherName,
      'familyName': familyName,
      'email': email,
      'phone': phone,
      'password': password,
      'fieldOfInterest': fieldOfInterest,
      'skills': skills,
    };
  }
}
