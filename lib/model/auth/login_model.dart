class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class LoginResponse {
  final String token;
  final String userId;

  LoginResponse({required this.token, required this.userId});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      userId: json['userId'] ?? '',
    );
  }
}
