/// Model: يمثّل الاستجابة القياسية ApiResponse<ConfirmationResponseDTO>
/// التي يُعيدها endpoint حذف الحساب
class DeleteAccountResponseModel {
  final int statusCode;
  final bool success;
  final String? message;
  final List<String> errors;

  const DeleteAccountResponseModel({
    required this.statusCode,
    required this.success,
    this.message,
    this.errors = const [],
  });

  factory DeleteAccountResponseModel.fromJson(Map<String, dynamic> json) {
    // data → { "message": "..." }
    final data = json['data'] as Map<String, dynamic>?;

    // errors قد تأتي كـ List<dynamic>
    final rawErrors = json['errors'];
    final List<String> parsedErrors = rawErrors is List
        ? rawErrors.map((e) => e.toString()).toList()
        : [];

    return DeleteAccountResponseModel(
      statusCode: json['statusCode'] as int? ?? 200,
      success: json['success'] as bool? ?? false,
      message: data?['message'] as String?,
      errors: parsedErrors,
    );
  }
}
