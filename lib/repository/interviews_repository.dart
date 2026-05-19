import 'package:gowork/model/interview_model.dart';
import 'package:gowork/services/interviews_service.dart';

class InterviewsRepository {
  final InterviewsService _service = InterviewsService();

  Future<List<InterviewModel>> getInterviews() async {
    try {
      final response = await _service.getInterviews();

      if (response['data'] != null && response['data']['interviews'] != null) {
        return (response['data']['interviews'] as List)
            .map((json) => InterviewModel.fromJson(json))
            .toList();
      } else if (response['interviews'] != null) {
        return (response['interviews'] as List)
            .map((json) => InterviewModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> submitInterviewAction(String id, String action, {String? notes}) async {
    try {
      final response = await _service.submitInterviewAction(id, action, notes: notes);
      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
