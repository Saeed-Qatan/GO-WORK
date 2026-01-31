import 'package:gowork/model/application_model.dart';
import 'package:gowork/services/applications_service.dart';

class ApplicationsRepository {
  final ApplicationsService _service = ApplicationsService();

  Future<List<ApplicationModel>> getApplications() async {
    try {
      final response = await _service.getApplications();
      if (response['applications'] != null) {
        return (response['applications'] as List)
            .map((json) => ApplicationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
