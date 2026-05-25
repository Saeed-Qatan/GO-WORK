import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/model/application_model.dart';
import 'package:gowork/repository/applications_repository.dart';
import 'package:gowork/services/applications_service.dart';
import 'package:gowork/viewmodel/applications_view_model.dart';

class _FakeApplicationsService extends ApplicationsService {
  final Map<String, dynamic> statusesResponse;
  final Map<String, dynamic> applicationsResponse;
  int applicationsFetchCount = 0;
  int withdrawCount = 0;

  _FakeApplicationsService({
    required this.statusesResponse,
    required this.applicationsResponse,
  });

  @override
  Future<Map<String, dynamic>> getApplicationStatuses() async {
    return statusesResponse;
  }

  @override
  Future<Map<String, dynamic>> getApplications() async {
    applicationsFetchCount++;
    return applicationsResponse;
  }

  @override
  Future<Map<String, dynamic>> withdrawApplication(String applicationId) async {
    withdrawCount++;
    return {'success': true};
  }
}

class _FailingStatusesRepository implements IApplicationsRepository {
  @override
  Future<ApplicationsData> getApplicationsData() {
    throw Exception('statuses endpoint failed');
  }

  @override
  Future<List<ApplicationModel>> getApplications({
    List<ApplicationStatusModel>? statuses,
  }) async {
    return const [];
  }

  @override
  Future<List<ApplicationStatusModel>> getApplicationStatuses() async {
    return const [];
  }

  @override
  Future<void> withdrawApplication(String applicationId) async {}
}

void main() {
  test(
    'parses statuses from data.items and labels applications from backend',
    () async {
      final service = _FakeApplicationsService(
        statusesResponse: {
          'data': {
            'items': [
              {'id': 2, 'value': 'PendingReview', 'label': 'حالة من الباك اند'},
            ],
          },
        },
        applicationsResponse: {
          'data': [
            {
              'id': '1',
              'jobId': 'job-1',
              'jobTitle': 'Flutter Developer',
              'companyName': 'Masarak',
              'statusId': 2,
            },
            {
              'id': '2',
              'jobId': 'job-2',
              'jobTitle': 'Backend Developer',
              'companyName': 'Masarak',
              'status': 'Accepted',
            },
          ],
        },
      );
      final repository = ApplicationsRepository(service: service);
      final viewModel = ApplicationsViewModel(
        repository: repository,
        autoFetch: false,
      );

      await viewModel.fetchApplications();

      expect(viewModel.filterTabs, ['الكل', 'حالة من الباك اند']);
      expect(viewModel.applications, hasLength(2));
      expect(
        viewModel.applications.first.statusLabelFromBackend,
        'حالة من الباك اند',
      );

      viewModel.setFilterIndex(1);

      expect(viewModel.applications, hasLength(1));
      expect(viewModel.applications.single.id, '1');
    },
  );

  test(
    'does not create a filter tab for statuses missing from endpoint',
    () async {
      final service = _FakeApplicationsService(
        statusesResponse: {
          'statuses': [
            {'value': 'PendingReview', 'label': 'من الباك اند فقط'},
          ],
        },
        applicationsResponse: {
          'applications': [
            {'id': '1', 'jobId': 'job-1', 'status': 'PendingReview'},
            {'id': '2', 'jobId': 'job-2', 'status': 'Accepted'},
          ],
        },
      );
      final viewModel = ApplicationsViewModel(
        repository: ApplicationsRepository(service: service),
        autoFetch: false,
      );

      await viewModel.fetchApplications();

      expect(viewModel.filterTabs, ['الكل', 'من الباك اند فقط']);
    },
  );

  test('shows error state when statuses endpoint fails', () async {
    final viewModel = ApplicationsViewModel(
      repository: _FailingStatusesRepository(),
      autoFetch: false,
    );

    await viewModel.fetchApplications();

    expect(viewModel.errorMessage, isNotNull);
    expect(viewModel.filterTabs, ['الكل']);
    expect(viewModel.applications, isEmpty);
  });

  test(
    'withdraw refetches from backend without injecting a local status',
    () async {
      final service = _FakeApplicationsService(
        statusesResponse: {
          'data': [
            {'value': 'PendingReview', 'label': 'من الباك اند'},
          ],
        },
        applicationsResponse: {
          'data': [
            {'id': '1', 'jobId': 'job-1', 'status': 'PendingReview'},
          ],
        },
      );
      final viewModel = ApplicationsViewModel(
        repository: ApplicationsRepository(service: service),
        autoFetch: false,
      );

      await viewModel.fetchApplications();
      final error = await viewModel.withdrawApplication('1');

      expect(error, isNull);
      expect(service.withdrawCount, 1);
      expect(service.applicationsFetchCount, 2);
      expect(
        viewModel.applications.single.statusLabelFromBackend,
        'من الباك اند',
      );
    },
  );
}
