import 'package:flutter/material.dart';
import '../../repository/login_repository.dart';
import '../../repository/profile_repository.dart';
import '../../services/notification_topic_service.dart';
import '../../services/push_notification_service.dart';
import '../../services/registration_category_sync_service.dart';
import 'package:gowork/utils/app_error_parser.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepository _repository = LoginRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final RegistrationCategorySyncService _categorySyncService =
      RegistrationCategorySyncService();
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
      await _repository.login(email, password);
      final pendingCategoryId =
          await _categorySyncService.consumePendingCategory(email);
      await _pushNotificationService?.registerCurrentToken();
      await _subscribeToUserTopics(pendingCategoryId: pendingCategoryId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = AppErrorParser.parse(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> _subscribeToUserTopics({String? pendingCategoryId}) async {
    final topicService = _notificationTopicService;
    if (topicService == null) return;

    try {
      final profile = await _profileRepository.getUserProfile();
      final categoryId =
          pendingCategoryId?.trim().isNotEmpty == true
              ? pendingCategoryId
              : profile.categoryId;
      await _categorySyncService.syncProfileCategory(
        profile: profile,
        categoryId: categoryId,
      );
      debugPrint(
        '=== LOGIN DEBUG: CATEGORY ID = ${categoryId?.isNotEmpty == true ? categoryId : 'EMPTY'} ===',
      );
      await topicService.subscribeUserTopics(categoryId: categoryId);
    } catch (e) {
      debugPrint('=== FCM TOPICS: LOGIN USER TOPICS ERROR: $e ===');
      await topicService.subscribeUserTopics(categoryId: pendingCategoryId);
    }
  }
}
