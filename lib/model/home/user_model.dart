part of 'home_model.dart';

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
