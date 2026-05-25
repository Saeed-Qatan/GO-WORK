class EmailVerificationArgs {
  final String email;
  final String? password;

  const EmailVerificationArgs({
    required this.email,
    this.password,
  });
}
