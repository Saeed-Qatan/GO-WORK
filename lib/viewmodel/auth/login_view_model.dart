import 'package:flutter/material.dart';
import '../../repository/login_repository.dart';
import '../../repository/profile_repository.dart';
import '../../services/notification_topic_service.dart';
import '../../services/push_notification_service.dart';
import 'package:gowork/utils/local_storage.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepository _repository = LoginRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final PushNotificationService? _pushNotificationService;
  final NotificationTopicService? _notificationTopicService;

  LoginViewModel({
    PushNotificationService? pushNotificationService,
    NotificationTopicService? notificationTopicService,
  }) : _pushNotificationService = pushNotificationService,
       _notificationTopicService = notificationTopicService;

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
      await _subscribeToUserTopics();

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

  Future<void> _subscribeToUserTopics() async {
    final topicService = _notificationTopicService;
    if (topicService == null) return;

    try {
      final profile = await _profileRepository.getUserProfile();
      await topicService.subscribeUserTopics(categoryId: profile.categoryId);
    } catch (e) {
      debugPrint('=== FCM TOPICS: LOGIN USER TOPICS ERROR: $e ===');
      await topicService.subscribeUserTopics(categoryId: null);
    }
  }
}
