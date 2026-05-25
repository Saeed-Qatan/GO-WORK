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

  test('translates english backend statuses to Arabic labels', () async {
    final service = _FakeApplicationsService(
      statusesResponse: {
        'data': [
          {'value': 'PendingReview', 'label': 'PendingReview'},
          {'value': 'Withdrawn', 'label': 'Withdrawn'},
        ],
      },
      applicationsResponse: {
        'data': [
          {'id': '1', 'jobId': 'job-1', 'status': 'PendingReview'},
          {'id': '2', 'jobId': 'job-2', 'status': 'Withdrawn'},
        ],
      },
    );
    final viewModel = ApplicationsViewModel(
      repository: ApplicationsRepository(service: service),
      autoFetch: false,
    );

    await viewModel.fetchApplications();

    expect(viewModel.filterTabs, ['الكل', 'قيد المراجعة', 'تم السحب']);
    expect(viewModel.applications.first.statusLabelFromBackend, 'قيد المراجعة');
    expect(viewModel.applications.last.statusLabelFromBackend, 'تم السحب');
  });

  test('translates numeric backend statuses using zero-based enum values', () {
    expect(ApplicationStatusModel.fromValue(0).label, 'تم التقديم');
    expect(ApplicationStatusModel.fromValue(1).label, 'قيد المراجعة');
    expect(ApplicationStatusModel.fromValue(2).label, 'تم القبول');
    expect(ApplicationStatusModel.fromValue(3).label, 'مرفوض');
    expect(ApplicationStatusModel.fromValue(4).label, 'تم السحب');
    expect(ApplicationStatusModel.fromValue(4).isWithdrawn, isTrue);
  });

  test('translates hired and missed interview statuses', () {
    expect(ApplicationStatusModel.fromValue('Hired').label, 'تم التوظيف');
    expect(ApplicationStatusModel.fromValue('Hire').label, 'تم التوظيف');
    expect(ApplicationStatusModel.fromValue(5).label, 'تم التوظيف');
    expect(
      ApplicationStatusModel.fromValue('missinterview').label,
      'لم يحضر المقابلة',
    );
    expect(
      ApplicationStatusModel.fromValue('MissInterview').label,
      'لم يحضر المقابلة',
    );
    expect(
      ApplicationStatusModel.fromValue('MissedInterview').label,
      'لم يحضر المقابلة',
    );
    expect(ApplicationStatusModel.fromValue(6).label, 'لم يحضر المقابلة');
  });

  test('displays missinterview in Arabic in tabs and cards', () async {
    final service = _FakeApplicationsService(
      statusesResponse: {
        'data': [
          {'value': 'missinterview', 'label': 'missinterview'},
        ],
      },
      applicationsResponse: {
        'data': [
          {'id': '1', 'jobId': 'job-1', 'status': 'missinterview'},
        ],
      },
    );
    final viewModel = ApplicationsViewModel(
      repository: ApplicationsRepository(service: service),
      autoFetch: false,
    );

    await viewModel.fetchApplications();

    expect(viewModel.filterTabs, ['الكل', 'لم يحضر المقابلة']);
    expect(
      viewModel.applications.single.statusLabelFromBackend,
      'لم يحضر المقابلة',
    );
  });

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
    'withdraw moves card to withdrawn tab after successful backend action',
    () async {
      final service = _FakeApplicationsService(
        statusesResponse: {
          'data': [
            {'value': 'PendingReview', 'label': 'قيد المراجعة'},
            {'value': 'Withdrawn', 'label': 'تم السحب'},
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
      viewModel.setFilterIndex(1);
      expect(viewModel.applications.single.id, '1');

      final error = await viewModel.withdrawApplication('1');

      expect(error, isNull);
      expect(service.withdrawCount, 1);
      expect(service.applicationsFetchCount, 2);
      expect(viewModel.selectedFilterIndex, 2);
      expect(viewModel.applications.single.id, '1');
      expect(viewModel.applications.single.statusLabelFromBackend, 'تم السحب');
    },
  );

  test(
    'withdraw keeps card in withdrawn tab when refresh response omits it',
    () async {
      final service = _ChangingApplicationsService(
        statusesResponse: {
          'data': [
            {'value': 'PendingReview', 'label': 'قيد المراجعة'},
            {'value': 'Withdrawn', 'label': 'تم السحب'},
          ],
        },
        responses: [
          {
            'data': [
              {'id': '1', 'jobId': 'job-1', 'status': 'PendingReview'},
            ],
          },
          {'data': <Map<String, dynamic>>[]},
        ],
      );
      final viewModel = ApplicationsViewModel(
        repository: ApplicationsRepository(service: service),
        autoFetch: false,
      );

      await viewModel.fetchApplications();
      final error = await viewModel.withdrawApplication('1');

      expect(error, isNull);
      expect(viewModel.selectedFilterIndex, 2);
      expect(viewModel.applications.single.id, '1');
      expect(viewModel.applications.single.statusLabelFromBackend, 'تم السحب');
    },
  );
}

class _ChangingApplicationsService extends ApplicationsService {
  final Map<String, dynamic> statusesResponse;
  final List<Map<String, dynamic>> responses;
  int _index = 0;

  _ChangingApplicationsService({
    required this.statusesResponse,
    required this.responses,
  });

  @override
  Future<Map<String, dynamic>> getApplicationStatuses() async {
    return statusesResponse;
  }

  @override
  Future<Map<String, dynamic>> getApplications() async {
    final safeIndex = _index >= responses.length
        ? responses.length - 1
        : _index;
    final response = responses[safeIndex];
    _index++;
    return response;
  }

  @override
  Future<Map<String, dynamic>> withdrawApplication(String applicationId) async {
    return {'success': true};
  }
}
