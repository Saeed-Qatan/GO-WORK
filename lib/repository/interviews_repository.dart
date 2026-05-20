import '../model/interview_model.dart';
import '../services/interviews_service.dart';

/// Abstract contract for the interviews data layer.
///
/// Consumers (ViewModels) depend on this interface, never on the concrete class.
/// This enables substitution with mock implementations during testing.
abstract class IInterviewsRepository {
  /// Fetches all interviews for the current user.
  Future<List<InterviewModel>> getInterviews();

  /// Submits a confirm/cancel action for a given interview.
  ///
  /// Returns the raw response map from the backend so the ViewModel
  /// can inspect `success` and `data.message` fields.
  Future<Map<String, dynamic>> submitInterviewAction(
    String id,
    String action, {
    String? notes,
  });
}

/// Concrete implementation backed by [InterviewsService] (HTTP layer).
class InterviewsRepository implements IInterviewsRepository {
  final InterviewsService _service;

  /// [service] is injected to keep this class testable.
  InterviewsRepository({InterviewsService? service})
      : _service = service ?? InterviewsService();

  @override
  Future<List<InterviewModel>> getInterviews() async {
    final response = await _service.getInterviews();

    if (response['data']?['interviews'] != null) {
      return (response['data']['interviews'] as List)
          .map((json) => InterviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    if (response['interviews'] != null) {
      return (response['interviews'] as List)
          .map((json) => InterviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<Map<String, dynamic>> submitInterviewAction(
    String id,
    String action, {
    String? notes,
  }) {
    return _service.submitInterviewAction(id, action, notes: notes);
  }
}
