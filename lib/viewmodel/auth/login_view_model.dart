import 'package:flutter/material.dart';
import '../../repository/login_repository.dart';
import '../../repository/profile_repository.dart';
import '../../services/push_notification_service.dart';
import 'package:gowork/utils/local_storage.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepository _repository = LoginRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final PushNotificationService? _pushNotificationService;

  LoginViewModel({PushNotificationService? pushNotificationService})
    : _pushNotificationService = pushNotificationService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.login(email, password);

      await LocalStorage().saveString('token', response.token);
      await LocalStorage().saveString('userId', response.userId);
      await _pushNotificationService?.registerCurrentToken();
      await _subscribeToProfileCategory();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> _subscribeToProfileCategory() async {
    final pushService = _pushNotificationService;
    if (pushService == null) return;

    try {
      final profile = await _profileRepository.getUserProfile();
      if (profile.categoryId.isEmpty) {
        debugPrint('=== FCM: PROFILE CATEGORY ID IS EMPTY ===');
        return;
      }

      final topic = 'category_${profile.categoryId}';
      await pushService.subscribeToTopic(topic);
      debugPrint('=== FCM: SUBSCRIBED TO LOGIN PROFILE TOPIC: $topic ===');
    } catch (e) {
      debugPrint('=== FCM: PROFILE TOPIC SUBSCRIBE AFTER LOGIN ERROR: $e ===');
    }
  }
}
