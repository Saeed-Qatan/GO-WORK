import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:gowork/repository/delete_account_repostriy.dart';
import 'package:gowork/utils/local_storage.dart';

/// ViewModel: يُدير حالة عملية حذف الحساب
/// يُستخدم مع Provider كـ ChangeNotifier
class DeleteAccountViewModel extends ChangeNotifier {
  final DeleteAccountRepository _repository = DeleteAccountRepository();
  final LocalStorage _storage = LocalStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDeleted = false;
  bool get isDeleted => _isDeleted;

  /// POST /Account/Candidate/DeleteAccount
  /// يُنفّذ الحذف ويُنظّف الجلسة المحلية عند النجاح
  Future<void> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // حذف FCM Token من Firebase قبل حذف الحساب
      try {
        await FirebaseMessaging.instance.deleteToken();
        debugPrint('=== FCM: Token deleted before account deletion ===');
      } catch (e) {
        debugPrint('=== FCM: Error deleting token: $e ===');
      }

      // استدعاء الـ API
      final result = await _repository.deleteAccount();
      debugPrint('=== DELETE ACCOUNT SUCCESS: ${result.message} ===');

      // مسح كل بيانات الجلسة المحلية بدون استثناء (حذف الحساب نهائياً)
      await _storage.clearAll();

      _isDeleted = true;
    } catch (e) {
      debugPrint('=== ERROR DELETING ACCOUNT: $e ===');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إعادة تعيين الحالة عند الحاجة (مثلاً إذا نُظِّئ الـ Provider)
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _isDeleted = false;
    notifyListeners();
  }
}
