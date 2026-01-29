class ProfileModel {
  final String name;
  final String role;
  final String avatarUrl;
  final String email;
  final String phone;
  final List<String> skills;

  ProfileModel({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.email,
    required this.phone,
    required this.skills,
  });
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
}
