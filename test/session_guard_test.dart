import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/routing/app_router.dart';
import 'package:gowork/utils/local_storage.dart';
import 'package:gowork/utils/session_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SessionGuard', () {
    final guard = SessionGuard();

    test('treats auth flow routes as public', () {
      expect(guard.isPublicRoute(AppRoutes.login), isTrue);
      expect(guard.isPublicRoute(AppRoutes.forgetPassword), isTrue);
      expect(guard.isPublicRoute(AppRoutes.resetPassword), isTrue);
      expect(guard.isPublicRoute(AppRoutes.verifyEmail), isTrue);
      expect(guard.isPublicRoute('${AppRoutes.onboarding}?next=/home'), isTrue);
      expect(guard.isPublicRoute(AppRoutes.home), isFalse);
    });

    test('detects expired jwt exp claim', () {
      final token = _jwtWithExp(DateTime.utc(2026, 1, 1));

      expect(
        guard.isTokenExpired(token, now: DateTime.utc(2026, 1, 2)),
        isTrue,
      );
      expect(
        guard.isTokenExpired(token, now: DateTime.utc(2025, 12, 31)),
        isFalse,
      );
    });

    test('does not treat malformed token as locally expired', () {
      expect(guard.isTokenExpired('not-a-jwt'), isFalse);
    });

    test('does not show session expired without token', () async {
      final decision = await guard.sessionDecisionForUnauthorized(
        currentRoute: AppRoutes.home,
      );

      expect(decision.hasToken, isFalse);
      expect(decision.shouldShowSessionExpired, isFalse);
    });

    test('does not show session expired on public routes', () async {
      await LocalStorage().saveString('token', _jwtWithExp(DateTime.utc(2099)));

      final decision = await guard.sessionDecisionForUnauthorized(
        currentRoute: AppRoutes.resetPassword,
      );

      expect(decision.hasToken, isTrue);
      expect(decision.shouldShowSessionExpired, isFalse);
    });

    test('shows session expired for token-backed protected route', () async {
      await LocalStorage().saveString('token', _jwtWithExp(DateTime.utc(2099)));

      final decision = await guard.sessionDecisionForUnauthorized(
        currentRoute: AppRoutes.home,
      );

      expect(decision.hasToken, isTrue);
      expect(decision.shouldShowSessionExpired, isTrue);
    });
  });
}

String _jwtWithExp(DateTime expiresAt) {
  final payload = jsonEncode({
    'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
  });
  return [
    _base64UrlJson({'alg': 'none'}),
    base64Url.encode(utf8.encode(payload)).replaceAll('=', ''),
    'signature',
  ].join('.');
}

String _base64UrlJson(Map<String, dynamic> value) {
  return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
}
