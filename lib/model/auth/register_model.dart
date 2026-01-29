class RegisterRequest {
  final String firstName;
  final String fatherName;
  final String lastName;
  final String email;
  final String phone;
  final String password;

  RegisterRequest({
    required this.firstName,
    required this.fatherName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'fatherName': fatherName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }
}
