class ResetPasswordRequest {
  final String email;
  final String code;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.email,
    required this.code,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'token': code, 'newPassword': newPassword};
  }
}
