import 'package:gowork/services/delete_account_service.dart';
import 'package:gowork/model/delete_account_model.dart';

/// Repository: يعزل منطق تحليل الاستجابة عن الـ ViewModel
/// ويُعيد نموذج بيانات واضح بدلاً من Map خام
class DeleteAccountRepository {
  final DeleteAccountService _service = DeleteAccountService();

  /// يستدعي الـ Service ويُحوّل الاستجابة إلى [DeleteAccountResponseModel]
  /// يُعيد النموذج في حالة النجاح، ويرمي Exception في حالة الفشل
  Future<DeleteAccountResponseModel> deleteAccount() async {
    final rawResponse = await _service.deleteAccount();
    final model = DeleteAccountResponseModel.fromJson(rawResponse);

    if (!model.success) {
      final errorMsg = model.errors.isNotEmpty
          ? model.errors.join('، ')
          : 'فشل حذف الحساب';
      throw Exception(errorMsg);
    }

    return model;
  }
}
