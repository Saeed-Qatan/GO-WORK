enum FeedbackType {
  complaint('2', 'شكوى'),
  suggestion('1', 'اقتراح');

  const FeedbackType(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class FeedbackRequest {
  const FeedbackRequest({required this.type, required this.message});

  final FeedbackType type;
  final String message;

  Map<String, dynamic> toJson() {
    return {'FeedbackType': type.apiValue, 'Message': message};
  }
}
