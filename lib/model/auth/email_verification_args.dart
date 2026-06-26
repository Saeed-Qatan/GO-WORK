class EmailVerificationArgs {
  final String email;
  final String? password;
  final bool isForgetPassword;

  const EmailVerificationArgs({
    required this.email,
    this.password,
    this.isForgetPassword = false,
  });
}
