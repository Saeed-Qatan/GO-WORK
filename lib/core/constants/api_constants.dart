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
  static const String jobCategories = 'Jobs/categories';
  static const String recommendedJobs = 'Jobs/recommendations';
  static const String searchJobs = 'Jobs/search';
  static const String jobCountries = 'Jobs/countries';
  static const String jobTypes = 'Jobs/job-types';
  static const String locationTypes = 'Jobs/location-types';
  static const String governates = 'Jobs/governates/156'; // Ensure 156 is the base governate ID
  static const String jobSkills = 'Jobs/skills'; // Appended with ?search=query
  static const String jobCurrencies = 'Jobs/currencies';
  static const String jobDetails = 'Jobs'; // Will append /{id}
  static const String applications = 'Applications';
  static const String applicationStatuses = 'Applications/statuses';
  static const String withdrawApplication = 'Applications/withdraw';
  static const String interviews = 'Account/interviews';
  static const String fetchOrders = 'Account/orders';
  static const String createOrder = 'Account/orders/create';

  // Headers عامة
  static const Map<String, String> headers = {'Accept': 'application/json'};
}
