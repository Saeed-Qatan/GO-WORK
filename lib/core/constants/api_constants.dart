class ApiConstants {
  // رابط السيرفر الأساسي
  static const String baseUrl = 'https://api.masarak.app/api/';

  // ================= Auth Endpoints =================
  static const String register = 'Account/Candidate/Register';
  static const String verifyEmail = 'Account/Candidate/VerifyEmail';
  static const String login = 'Account/Candidate/Login';
  static const String forgetPassword = 'Account/ForgetPassword';
  static const String resetPassword = 'https://gowork.runasp.net/api/Account/ResetPassword';
  static const String resendOtp = 'Account/ResendOtp';
  static const String resendLink = 'Account/ResendLink';

  // ================= Profile Endpoints =================
  static const String getProfile = 'Account/Me'; 
  static const String updateProfile = 'Account/Candidate/UpdateProfile'; 
  static const String getResume = 'Account/candidate/me/resume';
  static const String updateProfilePicture = 'Account/candidate/me/profilepicture';
  static const String uploadFile = 'Account/candidate/uploadfile';

  // ================= Jobs & Other Endpoints =================
  static const String recommendedJobs = 'Jobs/recommendations';
  static const String searchJobs = 'Jobs/search';
  static const String jobDetails = 'Jobs'; // Will append /{id}
  static const String applications = 'Account/applications';
  static const String interviews = 'Account/interviews';
  static const String fetchOrders = 'Account/orders';
  static const String createOrder = 'Account/orders/create';

  // Headers عامة
  static const Map<String, String> headers = {'Accept': 'application/json'};
}
