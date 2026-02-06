import 'package:gowork/repository/email_verification_repository.dart';

class EmailVerificationService {
  final EmailVerificationRepository _repo = EmailVerificationRepository();

  Future<void> verifyEmail(String email, String code) {
    return _repo.verifyEmail(email, code);
  }

  Future<void> resendCode(String email) {
    return _repo.resendCode(email);
  }
}
