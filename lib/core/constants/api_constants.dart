class ApiConstants {
  // رابط السيرفر الأساسي
  static const String baseUrl = 'https://api.example.com';

  // Endpoints
  static const String login = '/auth/login';
  static const String loginWithGoogle = '/auth/login-with-google';
  static const String register = '/auth/register';
  static const String forgetPassword = '/auth/forget-password';
  static const String getUser = '/user';
  static const String updateProfile = '/user/update';
  static const String fetchOrders = '/orders';
  static const String createOrder = '/orders/create';

  // Headers عامة
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
