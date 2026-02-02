class ApiConstants {
  // رابط السيرفر الأساسي
  static const String baseUrl = 'https://gowork.runasp.net/api/';

  // Endpoints
  static const String login = 'Account/auth/login';
  static const String loginWithGoogle = 'Account/auth/login-with-google';
  static const String register = 'Account/Candidate/Register';
  static const String forgetPassword = 'Account/auth/forget-password';
  static const String getUser = 'Account/user';
  static const String updateProfile = 'Account/user/update';
  static const String fetchOrders = 'Account/orders';
  static const String createOrder = 'Account/orders/create';

  // New Endpoints
  static const String home = 'Account/home';
  static const String applications = 'Account/applications';
  static const String interviews = 'Account/interviews';
  static const String profile = 'Account/user/profile';

  // Headers عامة
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
