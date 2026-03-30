class ProfileModel {
  final String firstName;
  final String middleName;
  final String lastName;
  final String jobTitle;
  final String avatarUrl;
  final String email;
  final String phone;
  final String cvUrl;
  final List<String> skills;

  ProfileModel({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.jobTitle,
    required this.avatarUrl,
    required this.email,
    required this.phone,
    required this.cvUrl,
    required this.skills,
  });

  /// Computed full name for display
  String get name => '$firstName $middleName $lastName'.trim();

  /// Computed role (alias for jobTitle for backward compat)
  String get role => jobTitle;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      firstName: json['firstName'] ?? json['FirstName'] ?? '',
      middleName: json['middleName'] ?? json['MiddleName'] ?? '',
      lastName: json['lastName'] ?? json['LastName'] ?? '',
      jobTitle: json['jobTitle'] ?? json['JobTitle'] ?? json['role'] ?? '',
      avatarUrl:
          json['avatarUrl'] ??
          json['profilPhotoUrl'] ??
          json['AvatarUrl'] ??
          '',
      email: json['email'] ?? json['Email'] ?? '',
      phone:
          json['phoneNo'] ??
          json['phone'] ??
          json['Phone'] ??
          json['PhoneNumber'] ??
          '',
      cvUrl: json['resumeUrl'] ?? json['cvUrl'] ?? json['CvUrl'] ?? '',
      skills: List<String>.from(json['skills'] ?? json['Skills'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'MiddleName': middleName,
      'LastName': lastName,
      'JobTitle': jobTitle,
      'Email': email,
      'PhoneNumber': phone,
      'Skills': skills,
    };
  }
}
