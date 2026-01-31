class ApiConstants {
  // رابط السيرفر الأساسي
  static const String baseUrl = 'https://gowork.runasp.net/';

  // Endpoints
  static const String login = 'api/Account/auth/login';
  static const String loginWithGoogle = 'api/Account/auth/login-with-google';
  static const String register = 'Candidate/Register';
  static const String forgetPassword = 'api/Account/auth/forget-password';
  static const String getUser = 'api/Account/user';
  static const String updateProfile = 'api/Account/user/update';
  static const String fetchOrders = 'api/Account/orders';
  static const String createOrder = 'api/Account/orders/create';

  // New Endpoints
  static const String home = 'api/Account/home';
  static const String applications = 'api/Account/applications';
  static const String interviews = 'api/Account/interviews';
  static const String profile = 'api/Account/user/profile';

  // Headers عامة
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
