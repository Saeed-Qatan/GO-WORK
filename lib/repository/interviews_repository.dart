import 'package:gowork/model/interview_model.dart';
import 'package:gowork/services/interviews_service.dart';

class InterviewsRepository {
  final InterviewsService _service = InterviewsService();

  Future<List<InterviewModel>> getInterviews() async {
    try {
      final response = await _service.getInterviews();
      if (response['interviews'] != null) {
        return (response['interviews'] as List)
            .map((json) => InterviewModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
