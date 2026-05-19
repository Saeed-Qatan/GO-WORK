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
    // Check if the response is nested in a 'data' array or object
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return LoginResponse(
      token:
          data['token'] ??
          data['Token'] ??
          data['accessToken'] ??
          json['token'] ??
          '',
      userId: data['userId'] ?? data['UserId'] ?? json['userId'] ?? '',
    );
  }
}
