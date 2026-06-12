import 'dart:convert';

import 'package:gowork/routing/app_router.dart';
import 'package:gowork/utils/local_storage.dart';

class SessionGuard {
  SessionGuard({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  static const Set<String> publicRoutes = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.registerInfo,
    AppRoutes.registerPhoto,
    AppRoutes.registerCV,
    AppRoutes.verifyEmail,
    AppRoutes.forgetPassword,
    AppRoutes.resetPassword,
    AppRoutes.sessionExpired,
  };

  Future<String?> currentToken() async {
    final token = await _storage.getString('token');
    final trimmedToken = token?.trim();
    return trimmedToken == null || trimmedToken.isEmpty ? null : trimmedToken;
  }

  Future<bool> hasActiveToken() async => await currentToken() != null;

  Future<SessionDecision> sessionDecisionForUnauthorized({
    required String? currentRoute,
  }) async {
    final token = await currentToken();
    if (token == null) {
      return const SessionDecision.expiredSessionRouteAllowed(
        shouldShowSessionExpired: false,
        hasToken: false,
      );
    }

    if (isPublicRoute(currentRoute)) {
      return SessionDecision.expiredSessionRouteAllowed(
        shouldShowSessionExpired: false,
        hasToken: true,
        isTokenExpired: isTokenExpired(token),
      );
    }

    return SessionDecision.expiredSessionRouteAllowed(
      shouldShowSessionExpired: true,
      hasToken: true,
      isTokenExpired: isTokenExpired(token),
    );
  }

  bool isPublicRoute(String? route) {
    final path = _normalizeRoute(route);
    if (path == null) return false;
    return publicRoutes.contains(path);
  }

  bool isTokenExpired(String token, {DateTime? now}) {
    final payload = decodeJwtPayload(token);
    final exp = payload?['exp'];
    final expiresAt = _expirationFromClaim(exp);
    if (expiresAt == null) return false;
    return !(now ?? DateTime.now().toUtc()).isBefore(expiresAt);
  }

  Map<String, dynamic>? decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = json.decode(payload);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  DateTime? _expirationFromClaim(dynamic exp) {
    final seconds = exp is int ? exp : int.tryParse(exp?.toString() ?? '');
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    );
  }

  String? _normalizeRoute(String? route) {
    final trimmed = route?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    final path = uri?.path.isNotEmpty == true ? uri!.path : trimmed;
    return path.startsWith('/') ? path : '/$path';
  }
}

class SessionDecision {
  final bool shouldShowSessionExpired;
  final bool hasToken;
  final bool isTokenExpired;

  const SessionDecision.expiredSessionRouteAllowed({
    required this.shouldShowSessionExpired,
    required this.hasToken,
    this.isTokenExpired = false,
  });
}
