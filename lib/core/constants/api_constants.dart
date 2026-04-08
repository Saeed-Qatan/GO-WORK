class ApiConstants {
  // رابط السيرفر الأساسي
  static const String baseUrl = 'https://api.masarak.app/api/';

  // Endpoints
  static const String login = 'Account/Candidate/Login';
  static const String loginWithGoogle = 'Account/auth/login-with-google';
  static const String register = 'Account/Candidate/Register';
  static const String forgetPassword = 'Account/ForgetPassword';
  static const String resetPassword = 'Account/ResetPassword';
  static const String getUser = 'Account/user';
  static const String updateProfile = 'Account/user/update';
  static const String me = 'Account/Me';
  static const String fetchOrders = 'Account/orders';
  static const String createOrder = 'Account/orders/create';
  static const String verifyEmail = 'Account/Candidate/VerifyEmail';
  static const String resendCode = 'Account/ResendOtp';

  // New Endpoints
  static const String home = 'Account/home';
  static const String applications = 'Account/applications';
  static const String interviews = 'Account/interviews';
  static const String updateCandidateProfile =
      'Account/Candidate/UpdateProfile';
  static const String getResume = 'Account/candidate/me/resume';
  static const String uploadResume = 'Account/candidate/uploadfile';
  static const String uploadProfilePicture = 'Account/candidate/uploadfile';

  // Headers عامة
  static const Map<String, String> headers = {'Accept': 'application/json'};
}
